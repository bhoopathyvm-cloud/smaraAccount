#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import CryptoKit
import Foundation
import Network
import Security

/// Network-framework TLS byte streams (design D3).
///
/// Dart keeps the length-prefixed JSON framing and the pinning decision. The
/// `sec_protocol_options` verify block hands every peer leaf certificate (DER
/// and its CryptoKit SHA-256 fingerprint) back to Dart through the
/// `verifyPeer` method call and completes the handshake with Dart's answer.
/// TLS 1.2 is the minimum so Dart's BoringSSL peers interoperate.
final class TlsHandler: NSObject, FlutterStreamHandler {
    private let channel: FlutterMethodChannel
    private let identity: KeychainIdentityHandler
    private let queue = DispatchQueue(label: "com.smara.apple_crypto.tls")
    private var sink: FlutterEventSink?
    private var connections: [Int: NWConnection] = [:]
    private var listeners: [Int: NWListener] = [:]
    private var closedIds = Set<Int>()
    private var nextId = 1

    init(channel: FlutterMethodChannel, identity: KeychainIdentityHandler) {
        self.channel = channel
        self.identity = identity
    }

    // MARK: FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    private func emit(_ event: [String: Any]) {
        DispatchQueue.main.async { self.sink?(event) }
    }

    // MARK: Method calls

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        queue.async {
            do {
                switch call.method {
                case "connect":
                    try self.connect(args, result: result)
                case "listen":
                    try self.listen(args, result: result)
                case "send":
                    try self.send(args, result: result)
                case "close":
                    let id = try PluginArgs.int(args, "id")
                    self.connections[id]?.cancel()
                    self.reply(result, nil)
                case "stopListening":
                    let id = try PluginArgs.int(args, "id")
                    self.listeners.removeValue(forKey: id)?.cancel()
                    self.reply(result, nil)
                default:
                    self.reply(result, FlutterMethodNotImplemented)
                }
            } catch {
                self.reply(result, PluginArgs.flutterError(error))
            }
        }
    }

    private func reply(_ result: @escaping FlutterResult, _ value: Any?) {
        DispatchQueue.main.async { result(value) }
    }

    // MARK: TLS options

    private func tlsOptions(
        identityLabel: String?, verifyHandle: Int, server: Bool, requestClientCertificate: Bool
    ) throws -> NWProtocolTLS.Options {
        let tls = NWProtocolTLS.Options()
        let options = tls.securityProtocolOptions
        sec_protocol_options_set_min_tls_protocol_version(options, .TLSv12)
        if let label = identityLabel {
            let secIdentity = try identity.identity(label: label)
            guard let localIdentity = sec_identity_create(secIdentity) else {
                throw PluginError(code: "no_identity", message: "sec_identity_create failed for '\(label)'.")
            }
            sec_protocol_options_set_local_identity(options, localIdentity)
        }
        if server {
            if requestClientCertificate {
                // Ask for a client certificate but let Dart decide: a peer
                // without one reaches Dart as "no certificate" and is refused
                // for sync there, exactly as the Dart transport does.
                sec_protocol_options_set_peer_authentication_required(options, true)
                sec_protocol_options_set_peer_authentication_optional(options, true)
            } else {
                sec_protocol_options_set_peer_authentication_required(options, false)
            }
        }
        let channel = self.channel
        sec_protocol_options_set_verify_block(
            options,
            { _, trustRef, complete in
                let trust = sec_trust_copy_ref(trustRef).takeRetainedValue()
                guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
                    let leaf = chain.first
                else {
                    // No certificate presented: acceptable only when the
                    // server did not require one. Dart sees `peer == null`.
                    complete(server && !requestClientCertificate)
                    return
                }
                let der = SecCertificateCopyData(leaf) as Data
                let fingerprint = HexEncoding.hex(Data(SHA256.hash(data: der)))
                DispatchQueue.main.async {
                    channel.invokeMethod(
                        "verifyPeer",
                        arguments: [
                            "handle": verifyHandle,
                            "der": PluginArgs.typed(der),
                            "fingerprint": fingerprint,
                        ]
                    ) { reply in
                        complete((reply as? Bool) ?? false)
                    }
                }
            }, queue)
        return tls
    }

    private func parameters(tls: NWProtocolTLS.Options, timeoutSeconds: Int?) -> NWParameters {
        let tcp = NWProtocolTCP.Options()
        tcp.noDelay = true
        if let timeout = timeoutSeconds {
            tcp.connectionTimeout = timeout
        }
        let parameters = NWParameters(tls: tls, tcp: tcp)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = false
        return parameters
    }

    // MARK: Connect

    private func connect(_ args: [String: Any], result: @escaping FlutterResult) throws {
        let handle = try PluginArgs.int(args, "handle")
        let host = try PluginArgs.string(args, "host")
        let port = try PluginArgs.int(args, "port")
        let timeoutMs = (args["timeoutMs"] as? Int) ?? 8000
        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(clamping: port)) else {
            throw PluginError(code: "bad_args", message: "Invalid port \(port).")
        }
        let tls = try tlsOptions(
            identityLabel: args["identityLabel"] as? String, verifyHandle: handle,
            server: false, requestClientCertificate: false)
        let parameters = parameters(tls: tls, timeoutSeconds: max(1, timeoutMs / 1000))
        let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: parameters)
        let id = register(connection)
        var settled = false
        let settle: (Result<[String: Any], Error>) -> Void = { outcome in
            if settled { return }
            settled = true
            switch outcome {
            case .success(let info):
                self.reply(result, info)
            case .failure(let error):
                connection.cancel()
                self.reply(result, PluginArgs.flutterError(error))
            }
        }
        queue.asyncAfter(deadline: .now() + .milliseconds(timeoutMs)) {
            settle(.failure(PluginError(code: "timeout", message: "TLS connect to \(host):\(port) timed out.")))
        }
        start(connection, id: id) { outcome in
            settle(outcome)
        }
    }

    // MARK: Listen

    private func listen(_ args: [String: Any], result: @escaping FlutterResult) throws {
        let port = try PluginArgs.int(args, "port")
        let label = try PluginArgs.string(args, "identityLabel")
        let requestClientCertificate = PluginArgs.bool(args, "requestClientCertificate", default: true)
        let loopbackOnly = PluginArgs.bool(args, "loopbackOnly", default: false)
        let listenerId = nextId
        nextId += 1
        let tls = try tlsOptions(
            identityLabel: label, verifyHandle: listenerId, server: true,
            requestClientCertificate: requestClientCertificate)
        let parameters = parameters(tls: tls, timeoutSeconds: nil)
        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(clamping: port)) else {
            throw PluginError(code: "bad_args", message: "Invalid port \(port).")
        }
        let listener: NWListener
        if loopbackOnly {
            // Tests: loopback only, port taken from the endpoint.
            parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: nwPort)
            listener = try NWListener(using: parameters)
        } else {
            // No required local endpoint: the listener accepts on every
            // interface over both IPv4 and IPv6 (#226).
            listener = try NWListener(using: parameters, on: nwPort)
        }
        listeners[listenerId] = listener
        var settled = false
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                if settled { return }
                settled = true
                self.reply(result, ["id": listenerId, "port": Int(listener.port?.rawValue ?? 0)])
            case .failed(let error):
                self.listeners.removeValue(forKey: listenerId)
                if settled { return }
                settled = true
                self.reply(result, FlutterError(code: "listen_failed", message: "\(error)", details: nil))
            default:
                break
            }
        }
        listener.newConnectionHandler = { connection in
            let id = self.register(connection)
            self.start(connection, id: id) { outcome in
                switch outcome {
                case .success(var info):
                    info["type"] = "connection"
                    info["listenerId"] = listenerId
                    self.emit(info)
                case .failure:
                    // A refused pin or a port scanner: nothing to report.
                    connection.cancel()
                }
            }
        }
        listener.start(queue: queue)
    }

    // MARK: Send

    private func send(_ args: [String: Any], result: @escaping FlutterResult) throws {
        let id = try PluginArgs.int(args, "id")
        let bytes = try PluginArgs.bytes(args, "bytes")
        guard let connection = connections[id] else {
            throw PluginError(code: "closed", message: "TLS connection \(id) is closed.")
        }
        connection.send(
            content: bytes,
            completion: .contentProcessed { error in
                if let error = error {
                    self.reply(result, FlutterError(code: "send_failed", message: "\(error)", details: nil))
                } else {
                    self.reply(result, nil)
                }
            })
    }

    // MARK: Connection lifecycle

    private func register(_ connection: NWConnection) -> Int {
        let id = nextId
        nextId += 1
        connections[id] = connection
        return id
    }

    private func start(
        _ connection: NWConnection, id: Int, onSettled: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        var ready = false
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                if ready { return }
                ready = true
                onSettled(.success(self.peerInfo(connection, id: id)))
                self.receiveLoop(connection, id: id)
            case .failed(let error):
                if ready {
                    self.emit(["type": "error", "id": id, "message": "\(error)"])
                    self.finish(id)
                } else {
                    onSettled(.failure(PluginError(code: "connect_failed", message: "\(error)")))
                }
                connection.cancel()
            case .waiting(let error):
                if !ready {
                    // No route (peer asleep or off the Wi-Fi): fail now
                    // rather than wait for the connect timeout.
                    onSettled(.failure(PluginError(code: "connect_failed", message: "\(error)")))
                    connection.cancel()
                }
            case .cancelled:
                if ready {
                    self.finish(id)
                } else {
                    onSettled(.failure(PluginError(code: "cancelled", message: "TLS connection cancelled.")))
                }
                self.connections.removeValue(forKey: id)
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    private func finish(_ id: Int) {
        if closedIds.insert(id).inserted {
            emit(["type": "closed", "id": id])
        }
        connections.removeValue(forKey: id)
    }

    private func receiveLoop(_ connection: NWConnection, id: Int) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1 << 16) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self.emit(["type": "data", "id": id, "bytes": PluginArgs.typed(data)])
            }
            if let error = error {
                self.emit(["type": "error", "id": id, "message": "\(error)"])
                self.finish(id)
                connection.cancel()
                return
            }
            if isComplete {
                self.finish(id)
                connection.cancel()
                return
            }
            self.receiveLoop(connection, id: id)
        }
    }

    /// The established connection's peer certificate (from the TLS metadata)
    /// and remote address, in the shape Dart's `AppleTlsConnection` reads.
    private func peerInfo(_ connection: NWConnection, id: Int) -> [String: Any] {
        var info: [String: Any] = ["id": id]
        if let metadata = connection.metadata(definition: NWProtocolTLS.definition) as? NWProtocolTLS.Metadata {
            var der: Data?
            sec_protocol_metadata_access_peer_certificate_chain(metadata.securityProtocolMetadata) { secCertificate in
                if der == nil {
                    let certificate = sec_certificate_copy_ref(secCertificate).takeRetainedValue()
                    der = SecCertificateCopyData(certificate) as Data
                }
            }
            if let der = der {
                info["peerDer"] = PluginArgs.typed(der)
                info["peerFingerprint"] = HexEncoding.hex(Data(SHA256.hash(data: der)))
            }
        }
        let endpoint = connection.currentPath?.remoteEndpoint ?? connection.endpoint
        if case .hostPort(let host, let port) = endpoint {
            info["remoteAddress"] = Self.describe(host)
            info["remotePort"] = Int(port.rawValue)
        }
        return info
    }

    private static func describe(_ host: NWEndpoint.Host) -> String {
        switch host {
        case .ipv4(let address):
            return "\(address)"
        case .ipv6(let address):
            return "\(address)"
        case .name(let name, _):
            return name
        @unknown default:
            return "\(host)"
        }
    }
}

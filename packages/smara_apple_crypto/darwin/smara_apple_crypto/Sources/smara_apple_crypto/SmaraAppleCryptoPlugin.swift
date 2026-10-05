#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Foundation

/// Entry point of the in-repo Apple plugin (OpenSpec `os-provided-encryption`).
///
/// Three method channels, one per concern, all executed by Apple frameworks:
/// - `smara_apple_crypto/crypto`: CryptoKit and CommonCrypto primitives.
/// - `smara_apple_crypto/identity`: the device TLS identity in the Keychain.
/// - `smara_apple_crypto/tls` (+ `tls_events`): Network-framework TLS.
public class SmaraAppleCryptoPlugin: NSObject, FlutterPlugin {
    private let crypto: CryptoPrimitivesHandler
    private let identity: KeychainIdentityHandler
    private let tls: TlsHandler

    /// Keeps the handlers alive for the life of the engine.
    private static var shared: SmaraAppleCryptoPlugin?

    init(crypto: CryptoPrimitivesHandler, identity: KeychainIdentityHandler, tls: TlsHandler) {
        self.crypto = crypto
        self.identity = identity
        self.tls = tls
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger = registrar.messenger()
        #else
        let messenger = registrar.messenger
        #endif
        let cryptoChannel = FlutterMethodChannel(
            name: "smara_apple_crypto/crypto", binaryMessenger: messenger)
        let identityChannel = FlutterMethodChannel(
            name: "smara_apple_crypto/identity", binaryMessenger: messenger)
        let tlsChannel = FlutterMethodChannel(
            name: "smara_apple_crypto/tls", binaryMessenger: messenger)
        let tlsEvents = FlutterEventChannel(
            name: "smara_apple_crypto/tls_events", binaryMessenger: messenger)

        let identity = KeychainIdentityHandler()
        let crypto = CryptoPrimitivesHandler()
        let tls = TlsHandler(channel: tlsChannel, identity: identity)
        let plugin = SmaraAppleCryptoPlugin(crypto: crypto, identity: identity, tls: tls)

        cryptoChannel.setMethodCallHandler(crypto.handle)
        identityChannel.setMethodCallHandler(identity.handle)
        tlsChannel.setMethodCallHandler(tls.handle)
        tlsEvents.setStreamHandler(tls)
        shared = plugin
    }
}

/// A failure reported to Dart as a `PlatformException` with a stable code.
struct PluginError: Error {
    let code: String
    let message: String
}

enum PluginArgs {
    static func bytes(_ args: [String: Any], _ key: String) throws -> Data {
        guard let typed = args[key] as? FlutterStandardTypedData else {
            throw PluginError(code: "bad_args", message: "Missing byte argument '\(key)'.")
        }
        return typed.data
    }

    static func optionalBytes(_ args: [String: Any], _ key: String) -> Data? {
        (args[key] as? FlutterStandardTypedData)?.data
    }

    static func string(_ args: [String: Any], _ key: String) throws -> String {
        guard let value = args[key] as? String else {
            throw PluginError(code: "bad_args", message: "Missing string argument '\(key)'.")
        }
        return value
    }

    static func int(_ args: [String: Any], _ key: String) throws -> Int {
        if let value = args[key] as? Int { return value }
        if let value = args[key] as? NSNumber { return value.intValue }
        throw PluginError(code: "bad_args", message: "Missing integer argument '\(key)'.")
    }

    static func bool(_ args: [String: Any], _ key: String, default fallback: Bool) -> Bool {
        (args[key] as? Bool) ?? fallback
    }

    static func typed(_ data: Data) -> FlutterStandardTypedData {
        FlutterStandardTypedData(bytes: data)
    }

    static func flutterError(_ error: Error) -> FlutterError {
        if let known = error as? PluginError {
            return FlutterError(code: known.code, message: known.message, details: nil)
        }
        return FlutterError(code: "apple_crypto_error", message: "\(error)", details: nil)
    }
}

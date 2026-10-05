#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import CommonCrypto
import CryptoKit
import Foundation

/// CryptoKit and CommonCrypto primitives (design D2). Work runs off the
/// platform thread; results are delivered on it.
final class CryptoPrimitivesHandler {
    private let queue = DispatchQueue(
        label: "com.smara.apple_crypto.primitives", qos: .userInitiated, attributes: .concurrent)

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        queue.async {
            do {
                let value = try self.dispatch(call.method, args)
                DispatchQueue.main.async { result(value) }
            } catch {
                let flutterError = PluginArgs.flutterError(error)
                DispatchQueue.main.async { result(flutterError) }
            }
        }
    }

    private func dispatch(_ method: String, _ args: [String: Any]) throws -> Any? {
        switch method {
        case "aesGcmSeal":
            return try aesGcmSeal(args)
        case "aesGcmOpen":
            return try aesGcmOpen(args)
        case "pbkdf2HmacSha256":
            return try pbkdf2(args)
        case "ed25519Generate":
            let key = Curve25519.Signing.PrivateKey()
            return [
                "seed": PluginArgs.typed(key.rawRepresentation),
                "publicKey": PluginArgs.typed(key.publicKey.rawRepresentation),
            ]
        case "ed25519PublicKey":
            let key = try Curve25519.Signing.PrivateKey(
                rawRepresentation: try PluginArgs.bytes(args, "seed"))
            return PluginArgs.typed(key.publicKey.rawRepresentation)
        case "ed25519Sign":
            let key = try Curve25519.Signing.PrivateKey(
                rawRepresentation: try PluginArgs.bytes(args, "seed"))
            let signature = try key.signature(for: try PluginArgs.bytes(args, "message"))
            return PluginArgs.typed(signature)
        case "ed25519Verify":
            guard
                let key = try? Curve25519.Signing.PublicKey(
                    rawRepresentation: try PluginArgs.bytes(args, "publicKey"))
            else { return false }
            return key.isValidSignature(
                try PluginArgs.bytes(args, "signature"), for: try PluginArgs.bytes(args, "message"))
        case "hmacSha256":
            let mac = HMAC<SHA256>.authenticationCode(
                for: try PluginArgs.bytes(args, "message"),
                using: SymmetricKey(data: try PluginArgs.bytes(args, "key")))
            return PluginArgs.typed(Data(mac))
        case "sha256":
            return PluginArgs.typed(Data(SHA256.hash(data: try PluginArgs.bytes(args, "data"))))
        case "sha256Many":
            guard let inputs = args["inputs"] as? [Any] else {
                throw PluginError(code: "bad_args", message: "Missing 'inputs'.")
            }
            return try inputs.map { item -> FlutterStandardTypedData in
                guard let typed = item as? FlutterStandardTypedData else {
                    throw PluginError(code: "bad_args", message: "sha256Many inputs must be bytes.")
                }
                return PluginArgs.typed(Data(SHA256.hash(data: typed.data)))
            }
        default:
            return FlutterMethodNotImplemented
        }
    }

    private func aesGcmSeal(_ args: [String: Any]) throws -> [String: Any] {
        let key = SymmetricKey(data: try PluginArgs.bytes(args, "key"))
        let plain = try PluginArgs.bytes(args, "plainText")
        let aad = PluginArgs.optionalBytes(args, "aad") ?? Data()
        let nonce: AES.GCM.Nonce
        if let given = PluginArgs.optionalBytes(args, "nonce") {
            nonce = try AES.GCM.Nonce(data: given)
        } else {
            nonce = AES.GCM.Nonce()
        }
        let sealed = try AES.GCM.seal(plain, using: key, nonce: nonce, authenticating: aad)
        return [
            "nonce": PluginArgs.typed(Data(sealed.nonce)),
            "cipherText": PluginArgs.typed(sealed.ciphertext),
            "tag": PluginArgs.typed(sealed.tag),
        ]
    }

    private func aesGcmOpen(_ args: [String: Any]) throws -> FlutterStandardTypedData {
        let key = SymmetricKey(data: try PluginArgs.bytes(args, "key"))
        let aad = PluginArgs.optionalBytes(args, "aad") ?? Data()
        let box = try AES.GCM.SealedBox(
            nonce: try AES.GCM.Nonce(data: try PluginArgs.bytes(args, "nonce")),
            ciphertext: try PluginArgs.bytes(args, "cipherText"),
            tag: try PluginArgs.bytes(args, "tag"))
        do {
            return PluginArgs.typed(try AES.GCM.open(box, using: key, authenticating: aad))
        } catch CryptoKitError.authenticationFailure {
            throw PluginError(code: "authentication_failed", message: "AES-GCM tag did not verify.")
        }
    }

    private func pbkdf2(_ args: [String: Any]) throws -> FlutterStandardTypedData {
        let password = [UInt8](try PluginArgs.bytes(args, "password"))
        let salt = [UInt8](try PluginArgs.bytes(args, "salt"))
        let iterations = try PluginArgs.int(args, "iterations")
        let keyLength = try PluginArgs.int(args, "keyLength")
        guard iterations > 0, keyLength > 0 else {
            throw PluginError(code: "bad_args", message: "PBKDF2 needs positive iterations and length.")
        }
        var derived = [UInt8](repeating: 0, count: keyLength)
        // CommonCrypto rejects null pointers; an empty password or salt is
        // passed as a zero-length view of a one-byte buffer.
        let passwordBuffer: [Int8] = password.isEmpty ? [0] : password.map { Int8(bitPattern: $0) }
        let saltBuffer: [UInt8] = salt.isEmpty ? [0] : salt
        let status = passwordBuffer.withUnsafeBufferPointer { pw in
            saltBuffer.withUnsafeBufferPointer { s in
                derived.withUnsafeMutableBufferPointer { out in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        pw.baseAddress, password.count,
                        s.baseAddress, salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        out.baseAddress, keyLength)
                }
            }
        }
        guard status == kCCSuccess else {
            throw PluginError(code: "pbkdf2_failed", message: "CCKeyDerivationPBKDF status \(status).")
        }
        return PluginArgs.typed(Data(derived))
    }
}

enum HexEncoding {
    static func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}

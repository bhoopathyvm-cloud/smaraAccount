/// Typed Dart wrapper over the `smara_apple_crypto` method channels.
///
/// See README.md: on iOS and macOS every call here is executed by an Apple
/// framework. The app's `AppleCryptoBackend`, `AppleDeviceCertificateStore`
/// and `AppleTlsSocketFactory` are built on these classes.
library;

export 'src/apple_crypto.dart';
export 'src/apple_keychain_identity.dart';
export 'src/apple_tls.dart';

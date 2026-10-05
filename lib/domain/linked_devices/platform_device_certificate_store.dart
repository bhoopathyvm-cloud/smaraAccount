import 'package:flutter/foundation.dart';

import '../crypto/crypto_backend.dart';
import '../crypto/secure_key_storage.dart';
import 'apple_device_certificate_store.dart';
import 'device_certificate_store.dart';
import 'persisting_device_certificate_store.dart';

/// The device identity store for [platform] (default: the running
/// platform): [AppleDeviceCertificateStore] on iOS and macOS, where the
/// operating system creates and keeps the identity, and
/// [PersistingDeviceCertificateStore] elsewhere.
DeviceCertificateStore createPlatformDeviceCertificateStore({
  required SecureKeyStorage secureStorage,
  TargetPlatform? platform,
}) {
  final target = platform ?? defaultTargetPlatform;
  if (!kIsWeb && isApplePlatform(target)) {
    return AppleDeviceCertificateStore(secureStorage: secureStorage);
  }
  return PersistingDeviceCertificateStore(secureStorage: secureStorage);
}

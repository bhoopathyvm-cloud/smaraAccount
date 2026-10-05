#
# CocoaPods fallback for projects that do not use Swift Package Manager.
# The Swift sources are shared with darwin/smara_apple_crypto/Package.swift.
#
Pod::Spec.new do |s|
  s.name             = 'smara_apple_crypto'
  s.version          = '1.0.0'
  s.summary          = 'Smara cryptography, TLS and device identity through Apple frameworks.'
  s.description      = <<-DESC
In-repo iOS/macOS plugin so the App Store builds of Smara encrypt only through
the operating system (CryptoKit, CommonCrypto, Security, Network).
                       DESC
  s.homepage         = 'https://github.com/bhoopathyvm-cloud/smaraAccount'
  s.license          = { :type => 'MIT', :text => 'See the repository LICENSE file.' }
  s.author           = { 'Smara' => 'bhoopathyvm@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'smara_apple_crypto/Sources/smara_apple_crypto/**/*.swift'
  s.resource_bundles = {
    'smara_apple_crypto_privacy' => ['smara_apple_crypto/Sources/smara_apple_crypto/PrivacyInfo.xcprivacy']
  }
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.frameworks = 'CryptoKit', 'Network', 'Security'
  s.swift_version = '5.9'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end

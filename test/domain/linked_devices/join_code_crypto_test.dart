import 'package:smara_accounting/domain/linked_devices/join_code_crypto.dart';
import 'package:test/test.dart';

void main() {
  const code = 'K7QF3M9P';
  final inviterKey = List<int>.filled(32, 1);
  final joinerKey = List<int>.filled(32, 2);
  final inviterNonce = List<int>.filled(16, 3);
  final joinerNonce = List<int>.filled(16, 4);

  test('both sides derive the same 6-digit check code', () {
    final a = JoinCodeCrypto.checkCode(
      code: code,
      inviterPublicKey: inviterKey,
      joinerPublicKey: joinerKey,
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    final b = JoinCodeCrypto.checkCode(
      code: 'k7qf-3m9p',
      inviterPublicKey: inviterKey,
      joinerPublicKey: joinerKey,
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    expect(a.length, 6);
    expect(int.tryParse(a), isNotNull);
    expect(a, b);
  });

  test('tampered public key changes the check code', () {
    final good = JoinCodeCrypto.checkCode(
      code: code,
      inviterPublicKey: inviterKey,
      joinerPublicKey: joinerKey,
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    final bad = JoinCodeCrypto.checkCode(
      code: code,
      inviterPublicKey: List<int>.filled(32, 9),
      joinerPublicKey: joinerKey,
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    expect(bad, isNot(good));
  });

  test('code proof is stable and differs when code differs', () {
    final proof = JoinCodeCrypto.codeProof(
      code: code,
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    final again = JoinCodeCrypto.codeProof(
      code: 'k7qf3m9p',
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    expect(proof, again);
    final other = JoinCodeCrypto.codeProof(
      code: 'AAAAAAAA',
      inviterNonce: inviterNonce,
      joinerNonce: joinerNonce,
    );
    expect(other, isNot(proof));
  });
}

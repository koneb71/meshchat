import 'package:flutter_test/flutter_test.dart';
import 'package:meshchat/crypto/sender_keys.dart';

void main() {
  test('Sender key create/next/rotate', () async {
    final SenderKeysService svc = SenderKeysService();
    final SenderKeyState st0 = await svc.create();
    final (SenderKeyState st1, _, __) = await svc.nextMessageKey(st0);
    expect(st1.counter, 1);
    final SenderKeyState st2 = await svc.rotate(st1);
    expect(st2.counter, 0);
  });
}



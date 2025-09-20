import 'dart:convert';
import 'dart:typed_data';

String hex(Uint8List data) {
  final StringBuffer buffer = StringBuffer();
  for (final int b in data) {
    buffer.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

Uint8List hexToBytes(String hex) {
  final String cleaned = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  final Uint8List result = Uint8List(cleaned.length ~/ 2);
  for (int i = 0; i < cleaned.length; i += 2) {
    result[i ~/ 2] = int.parse(cleaned.substring(i, i + 2), radix: 16);
  }
  return result;
}

Uint8List concatBytes(List<Uint8List> parts) {
  final int total = parts.fold(0, (int a, Uint8List b) => a + b.length);
  final Uint8List out = Uint8List(total);
  int offset = 0;
  for (final Uint8List p in parts) {
    out.setRange(offset, offset + p.length, p);
    offset += p.length;
  }
  return out;
}

Uint8List utf8Bytes(String s) => Uint8List.fromList(utf8.encode(s));



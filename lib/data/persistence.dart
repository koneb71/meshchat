import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStore {
  Future<Directory> _appDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  Future<File> _file(String name) async {
    final Directory dir = await _appDir();
    return File('${dir.path}/$name');
  }

  Future<List<dynamic>> readJsonList(String name) async {
    try {
      final File f = await _file(name);
      if (!await f.exists()) return <dynamic>[];
      final String s = await f.readAsString();
      if (s.isEmpty) return <dynamic>[];
      final dynamic v = jsonDecode(s);
      if (v is List<dynamic>) return v;
      return <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  Future<Map<String, dynamic>> readJsonMap(String name) async {
    try {
      final File f = await _file(name);
      if (!await f.exists()) return <String, dynamic>{};
      final String s = await f.readAsString();
      if (s.isEmpty) return <String, dynamic>{};
      final dynamic v = jsonDecode(s);
      if (v is Map<String, dynamic>) return v;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> writeJson(String name, Object data) async {
    final File f = await _file(name);
    await f.writeAsString(jsonEncode(data), flush: true);
  }
}



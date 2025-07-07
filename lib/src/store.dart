import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Store {
  static File? _file;
  static Map<String, dynamic> _cache = {}; // In-memory cache
  static bool _initialized = false;

  static final Map<String, Function(Map<String, dynamic>)> _typeRegistry = {};

  static void register<T>(T Function(Map<String, dynamic>) fromJson) {
    final typeName = T.toString();
    _typeRegistry[typeName] = fromJson;
  }

  static bool _isPrimitive(dynamic value) {
    return value is int ||
        value is double ||
        value is String ||
        value is bool ||
        value is List ||
        value is Map;
  }

  static Future<Directory> _getAppDirectory() async {
    if (Platform.isWindows) {
      final dir = Directory(
        '${Platform.environment['UserProfile']}\\AppData\\Roaming\\SimpleStore',
      );
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
      return dir;
    } else if (Platform.isLinux || Platform.isMacOS) {
      final dir = Directory('${Directory.current.path}/.simple_store');
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
      return dir;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await _getAppDirectory();
    final path = '${dir.path}/store.json';
    _file = File(path);

    if (!(await _file!.exists())) {
      await _file!.writeAsString(jsonEncode({}));
    }

    return _file!;
  }

  static Future<void> init() async {
    if (_initialized) return;
    final file = await _getFile();
    final content = await file.readAsString();
    _cache = jsonDecode(content) as Map<String, dynamic>;
    _initialized = true;
  }

  static void save(String key, dynamic value) {
    dynamic encodedValue = value;
    final typeName = value.runtimeType.toString();

    if (!_isPrimitive(value)) {
      try {
        if (value is List) {
          encodedValue = value.map((e) {
            try {
              return _isPrimitive(e) ? e : e.toJson();
            } catch (_) {
              return e;
            }
          }).toList();
        } else {
          encodedValue = value.toJson();
        }
      } catch (e) {
        debugPrint('⚠️ Failed to encode "$key" to JSON: $e');
      }
    }

    _cache[key] = {'value': encodedValue, 'type': typeName};
    _persist();
  }

  static T? get<T>(String key) {
    if (!_cache.containsKey(key)) return null;

    final stored = _cache[key];
    final type = stored['type'];
    final value = stored['value'];

    if (_typeRegistry.containsKey(type)) {
      return _typeRegistry[type]!(value) as T;
    }

    if (type != null && type.toString().startsWith("List<")) {
      final innerType = type.substring(5, type.length - 1);
      final converter = _typeRegistry[innerType];
      if (converter != null && value is List) {
        return value.map((e) => converter(e)).toList() as T;
      }
    }

    return value as T;
  }

 
static List<T> getList<T>(String key) {
  if (!_cache.containsKey(key)) return [];

  final stored = _cache[key];
  final value = stored['value'];

  if (value is List) {
    final String typeName = T.toString();
    final converter = _typeRegistry[typeName];

    if (converter != null) {
      return value.map<T>((e) {
        if (e is T) return e;
        if (e is Map<String, dynamic>) return converter(e) as T;
        throw Exception("🛑 Cannot convert element to $typeName");
      }).toList();
    } else {
      // لو النوع بسيط مش محتاج تحويل
      return List<T>.from(value);
    }
  }

  throw Exception("❌ Stored value for '$key' is not a List");
}


  static void delete(String key) {
    _cache.remove(key);
    _persist();
  }

  static void clear() {
    _cache = {};
    _persist();
  }

  static bool contains(String key) {
    return _cache.containsKey(key);
  }

  static Future<void> _persist() async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(_cache));
  }
}

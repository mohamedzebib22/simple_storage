// Revised smart_store implementation
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

class Store {
  static final Map<String, dynamic> _cache = {}; // In-memory cache
  static final Map<String, Function(Map<String, dynamic>)> _typeRegistry = {};
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await _getAppDirectory();
    final files = await dir.list().toList();

    for (final file in files) {
      if (file is File && file.path.endsWith('.dat')) {
        final key = file.uri.pathSegments.last.replaceAll('.dat', '');
        try {
          final bytes = await file.readAsBytes();
          final data = deserialize(bytes);
          if (data is Map && data.containsKey('value') && data.containsKey('type')) {
            _cache[key] = data;
          }
        } catch (e) {
          debugPrint('⚠️ Skipping corrupted file ${file.path}: $e');
        }
      }
    }
    _initialized = true;
  }

  static Future<Directory> _getAppDirectory() async {
    if (Platform.isWindows) {
      final dir = Directory('${Platform.environment['UserProfile']}\\AppData\\Roaming\\smart_store');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } else if (Platform.isLinux || Platform.isMacOS) {
      final dir = Directory('${Directory.current.path}/.smart_store');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Future<File> _fileForKey(String key) async {
    final dir = await _getAppDirectory();
    return File('${dir.path}/$key.dat');
  }

  static void register<T>(T Function(Map<String, dynamic>) fromJson) {
    _typeRegistry[T.toString()] = fromJson;
  }

  static bool _isPrimitive(dynamic value) {
    return value is int ||
        value is double ||
        value is String ||
        value is bool ||
        value is List ||
        value is Map;
  }

  static void save(String key, dynamic value) {
    final typeName = value.runtimeType.toString();
    dynamic encodedValue;

    try {
      if (_isPrimitive(value)) {
        encodedValue = value;
      } else if (value is List) {
        encodedValue = value.map((e) {
          if (_isPrimitive(e)) return e;
          try {
            return e.toJson();
          } catch (_) {
            throw Exception("Element of type \${e.runtimeType} can't be serialized");
          }
        }).toList();
      } else {
        try {
          encodedValue = value.toJson();
        } catch (_) {
          throw Exception("Type $typeName can't be serialized. Missing toJson().");
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to encode "$key": $e');
      return;
    }

    final data = {'value': encodedValue, 'type': typeName};
    _cache[key] = data;

    Future(() async {
      try {
        final file = await _fileForKey(key);
        await file.writeAsBytes(serialize(data));
      } catch (e) {
        debugPrint('❌ Failed to write file for "$key": $e');
      }
    });
  }

  static void saveList<T>(String key, List<T> list) {
    final typeName = 'List<${T.toString()}>';
    List encodedList = [];
    try {
      encodedList = list.map((e) {
        if (_isPrimitive(e)) return e;
        try {
          return (e as dynamic).toJson();
        } catch (_) {
          throw Exception("Element of type \${e.runtimeType} can't be serialized");
        }
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to encode "$key" list: $e');
      return;
    }

    final data = {'value': encodedList, 'type': typeName};
    _cache[key] = data;

    Future(() async {
      try {
        final file = await _fileForKey(key);
        await file.writeAsBytes(serialize(data));
      } catch (e) {
        debugPrint('❌ Failed to write file for "$key": $e');
      }
    });
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
      final typeName = T.toString();
      final converter = _typeRegistry[typeName];

      if (converter != null) {
        return value.map<T>((e) {
          if (e is T) return e;
          if (e is Map<String, dynamic>) return converter(e) as T;
          throw Exception("🛑 Cannot convert element to $typeName");
        }).toList();
      } else {
        return List<T>.from(value);
      }
    }

    throw Exception("❌ Stored value for '$key' is not a List");
  }

  static void delete(String key) async {
    _cache.remove(key);
    try {
      final file = await _fileForKey(key);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('⚠️ Failed to delete file for "$key": $e');
    }
  }

  static void clear() async {
    _cache.clear();
    final dir = await _getAppDirectory();
    try {
      final files = await dir.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.dat')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to clear directory: $e');
    }
  }

  static bool contains(String key) => _cache.containsKey(key);
}

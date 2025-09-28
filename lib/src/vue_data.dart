import 'package:flutter/foundation.dart';

/// Vue2风格的响应式数据管理
class VueData extends ChangeNotifier {
  final Map<String, dynamic> _data = {};
  final Map<String, Type> _types = {};
  
  /// 初始化数据
  void initData(Map<String, dynamic> initialData) {
    _data.clear();
    _types.clear();
    _data.addAll(initialData);
    
    // 记录每个key的类型
    for (final entry in initialData.entries) {
      if (entry.value != null) {
        _types[entry.key] = entry.value.runtimeType;
      }
    }
    
    notifyListeners();
  }
  
  /// 获取数据 - 带类型安全检查
  T get<T>(String key) {
    if (!_data.containsKey(key)) {
      throw VueDataException('Key "$key" not found in data');
    }
    
    final value = _data[key];
    if (value == null) return value as T;
    
    // 类型检查
    if (!_isAssignableType<T>(value)) {
      throw VueDataException(
        'Type mismatch for key "$key": expected $T but got ${value.runtimeType}'
      );
    }
    
    return value as T;
  }
  
  /// 安全获取数据 - 返回nullable
  T? getSafe<T>(String key) {
    if (!_data.containsKey(key)) return null;
    
    final value = _data[key];
    if (value == null) return null;
    
    if (!_isAssignableType<T>(value)) return null;
    
    return value as T;
  }
  
  /// 获取数据或默认值
  T getOrDefault<T>(String key, T defaultValue) {
    final value = getSafe<T>(key);
    return value ?? defaultValue;
  }
  
  /// 设置数据 - 带类型检查
  void set<T>(String key, T value) {
    // 如果已存在类型记录，进行类型检查
    if (_types.containsKey(key) && value != null) {
      final expectedType = _types[key]!;
      if (!_isTypeCompatible(value.runtimeType, expectedType)) {
        throw VueDataException(
          'Type mismatch for key "$key": expected $expectedType but got ${value.runtimeType}'
        );
      }
    }
    
    if (_data[key] != value) {
      _data[key] = value;
      if (value != null) {
        _types[key] = value.runtimeType;
      }
      notifyListeners();
    }
  }
  
  /// 批量设置数据 - 带类型检查
  void setAll(Map<String, dynamic> data) {
    bool hasChanged = false;
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // 类型检查
      if (_types.containsKey(key) && value != null) {
        final expectedType = _types[key]!;
        if (!_isTypeCompatible(value.runtimeType, expectedType)) {
          throw VueDataException(
            'Type mismatch for key "$key": expected $expectedType but got ${value.runtimeType}'
          );
        }
      }
      
      if (_data[key] != value) {
        _data[key] = value;
        if (value != null) {
          _types[key] = value.runtimeType;
        }
        hasChanged = true;
      }
    }
    
    if (hasChanged) {
      notifyListeners();
    }
  }
  
  /// 更新对象的某个属性（深度访问）
  void updateProperty<T>(String key, String property, T value) {
    final obj = _data[key];
    if (obj == null) {
      throw VueDataException('Object with key "$key" not found');
    }
    
    if (obj is Map<String, dynamic>) {
      if (obj[property] != value) {
        obj[property] = value;
        notifyListeners();
      }
    } else {
      throw VueDataException('Key "$key" is not a Map object');
    }
  }
  
  /// 获取对象的某个属性
  T getProperty<T>(String key, String property) {
    final obj = _data[key];
    if (obj == null) {
      throw VueDataException('Object with key "$key" not found');
    }
    
    if (obj is Map<String, dynamic>) {
      if (!obj.containsKey(property)) {
        throw VueDataException('Property "$property" not found in object "$key"');
      }
      return obj[property] as T;
    } else {
      throw VueDataException('Key "$key" is not a Map object');
    }
  }
  
  /// 获取所有数据
  Map<String, dynamic> get all => Map.unmodifiable(_data);
  
  /// 获取所有类型信息
  Map<String, Type> get types => Map.unmodifiable(_types);
  
  /// 检查是否包含某个key
  bool has(String key) => _data.containsKey(key);
  
  /// 获取key的类型
  Type? getType(String key) => _types[key];
  
  /// 删除数据
  void remove(String key) {
    if (_data.containsKey(key)) {
      _data.remove(key);
      _types.remove(key);
      notifyListeners();
    }
  }
  
  /// 清空所有数据
  void clear() {
    if (_data.isNotEmpty || _types.isNotEmpty) {
      _data.clear();
      _types.clear();
      notifyListeners();
    }
  }
  
  /// 类型兼容性检查
  bool _isTypeCompatible(Type actual, Type expected) {
    if (actual == expected) return true;
    
    // 处理数字类型兼容性
    if ((expected == num || expected == double) && (actual == int || actual == double)) {
      return true;
    }
    if (expected == int && actual == int) return true;
    
    // 处理集合类型兼容性
    if (expected.toString().startsWith('List<') && actual.toString().startsWith('List<')) {
      return true;
    }
    if (expected.toString().startsWith('Map<') && actual.toString().startsWith('Map<')) {
      return true;
    }
    
    return false;
  }
  
  /// 类型分配检查
  bool _isAssignableType<T>(dynamic value) {
    if (value == null) return true;
    
    // 基本类型检查
    switch (T) {
      case String:
        return value is String;
      case int:
        return value is int;
      case double:
        return value is double || value is int; // int可以赋值给double
      case num:
        return value is num;
      case bool:
        return value is bool;
      case List:
        return value is List;
      case Map:
        return value is Map;
      default:
        return value is T;
    }
  }
}

/// Vue数据异常类
class VueDataException implements Exception {
  final String message;
  const VueDataException(this.message);
  
  @override
  String toString() => 'VueDataException: $message';
}

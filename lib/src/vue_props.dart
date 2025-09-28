/// Vue2风格的Props管理
class VueProps {
  final Map<String, dynamic> _props = {};
  final Map<String, PropDefinition> _definitions = {};
  
  /// 定义prop属性
  void define(String name, {
    required Type type,
    dynamic defaultValue,
    bool required = false,
    Function? validator,
  }) {
    _definitions[name] = PropDefinition(
      type: type,
      defaultValue: defaultValue,
      required: required,
      validator: validator,
    );
  }
  
  /// 批量定义props
  void defineAll(Map<String, PropDefinition> definitions) {
    _definitions.addAll(definitions);
  }
  
  /// 设置props值（通常在组件创建时调用）
  void setProps(Map<String, dynamic> props) {
    _props.clear();
    
    // 验证和设置props
    for (final entry in _definitions.entries) {
      final name = entry.key;
      final definition = entry.value;
      
      if (props.containsKey(name)) {
        final value = props[name];
        
        // 类型检查
        if (!_isTypeMatch(value, definition.type)) {
          throw Exception('Prop "$name" expected ${definition.type} but got ${value.runtimeType}');
        }
        
        // 自定义验证
        if (definition.validator != null && !definition.validator!(value)) {
          throw Exception('Prop "$name" validation failed for value: $value');
        }
        
        _props[name] = value;
      } else if (definition.required) {
        throw Exception('Required prop "$name" is missing');
      } else if (definition.defaultValue != null) {
        _props[name] = definition.defaultValue;
      }
    }
    
    // 检查是否有未定义的props
    for (final propName in props.keys) {
      if (!_definitions.containsKey(propName)) {
        throw Exception('Unknown prop "$propName"');
      }
    }
  }
  
  /// 获取prop值
  T get<T>(String name) {
    if (!_props.containsKey(name)) {
      throw Exception('Prop "$name" not found');
    }
    return _props[name] as T;
  }
  
  /// 检查prop是否存在
  bool has(String name) => _props.containsKey(name);
  
  /// 获取所有props
  Map<String, dynamic> get all => Map.unmodifiable(_props);
  
  /// 获取所有prop定义
  Map<String, PropDefinition> get definitions => Map.unmodifiable(_definitions);
  
  /// 类型匹配检查
  bool _isTypeMatch(dynamic value, Type expectedType) {
    if (value == null) return true; // null可以赋值给任何类型
    
    switch (expectedType) {
      case String:
        return value is String;
      case int:
        return value is int;
      case double:
        return value is double;
      case bool:
        return value is bool;
      case List:
        return value is List;
      case Map:
        return value is Map;
      default:
        return value.runtimeType == expectedType;
    }
  }
}

/// Prop定义
class PropDefinition {
  final Type type;
  final dynamic defaultValue;
  final bool required;
  final Function? validator;
  
  const PropDefinition({
    required this.type,
    this.defaultValue,
    this.required = false,
    this.validator,
  });
}

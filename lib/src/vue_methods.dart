import 'vue_data.dart';

/// Vue2风格的方法管理
class VueMethods {
  final Map<String, Function> _methods = {};
  late final VueData _data;
  
  VueMethods(VueData data) : _data = data;
  
  /// 注册方法
  void register(String name, Function method) {
    _methods[name] = method;
  }
  
  /// 批量注册方法
  void registerAll(Map<String, Function> methods) {
    _methods.addAll(methods);
  }
  
  /// 调用方法
  T call<T>(String name, [List<dynamic>? args]) {
    if (!_methods.containsKey(name)) {
      throw Exception('Method "$name" not found');
    }
    
    final method = _methods[name]!;
    
    // 创建方法上下文，让方法可以访问data
    final context = MethodContext(_data);
    
    if (args == null || args.isEmpty) {
      return Function.apply(method, [context]) as T;
    } else {
      return Function.apply(method, [context, ...args]) as T;
    }
  }
  
  /// 检查方法是否存在
  bool has(String name) => _methods.containsKey(name);
  
  /// 获取所有方法名
  List<String> get methodNames => _methods.keys.toList();
  
  /// 移除方法
  void remove(String name) {
    _methods.remove(name);
  }
  
  /// 清空所有方法
  void clear() {
    _methods.clear();
  }
}

/// 方法执行上下文，提供对data的访问
class MethodContext {
  final VueData _data;
  
  MethodContext(this._data);
  
  /// 获取data中的值（类型安全）
  T getData<T>(String key) => _data.get<T>(key);
  
  /// 安全获取data中的值
  T? getDataSafe<T>(String key) => _data.getSafe<T>(key);
  
  /// 获取data中的值或默认值
  T getDataOrDefault<T>(String key, T defaultValue) => _data.getOrDefault<T>(key, defaultValue);
  
  /// 设置data中的值（类型安全）
  void setData<T>(String key, T value) => _data.set<T>(key, value);
  
  /// 批量设置data
  void setAllData(Map<String, dynamic> data) => _data.setAll(data);
  
  /// 更新对象属性（深度访问）
  void updateProperty<T>(String key, String property, T value) => 
      _data.updateProperty<T>(key, property, value);
  
  /// 获取对象属性
  T getProperty<T>(String key, String property) => 
      _data.getProperty<T>(key, property);
  
  /// 检查是否包含某个key
  bool hasData(String key) => _data.has(key);
  
  /// 获取key的类型
  Type? getDataType(String key) => _data.getType(key);
  
  /// 获取所有data
  Map<String, dynamic> get allData => _data.all;
  
  /// 获取所有类型信息
  Map<String, Type> get allDataTypes => _data.types;
}

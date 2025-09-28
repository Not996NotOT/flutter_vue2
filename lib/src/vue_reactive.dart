import 'package:flutter/foundation.dart';

/// 响应式对象基类
abstract class ReactiveObject extends ChangeNotifier {
  /// 将对象转换为Map
  Map<String, dynamic> toMap();
  
  /// 从Map创建对象
  void fromMap(Map<String, dynamic> map);
  
  /// 更新对象并通知监听者
  void update(void Function() updateFn) {
    updateFn();
    notifyListeners();
  }
}

/// 响应式包装器，用于包装任意对象使其变为响应式
class Reactive<T> extends ChangeNotifier {
  T _value;
  
  Reactive(this._value);
  
  /// 获取值
  T get value => _value;
  
  /// 设置值并通知更新
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
  
  /// 更新值（用于复杂对象的部分更新）
  void update(T Function(T current) updater) {
    final newValue = updater(_value);
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
  
  /// 如果值是Map，提供属性访问
  U? getProperty<U>(String key) {
    if (_value is Map<String, dynamic>) {
      return (_value as Map<String, dynamic>)[key] as U?;
    }
    throw ReactiveException('Value is not a Map, cannot access property "$key"');
  }
  
  /// 如果值是Map，提供属性设置
  void setProperty<U>(String key, U value) {
    if (_value is Map<String, dynamic>) {
      final map = _value as Map<String, dynamic>;
      if (map[key] != value) {
        map[key] = value;
        notifyListeners();
      }
    } else {
      throw ReactiveException('Value is not a Map, cannot set property "$key"');
    }
  }
  
  /// 如果值是List，提供索引访问
  U? getIndex<U>(int index) {
    if (_value is List) {
      final list = _value as List;
      if (index >= 0 && index < list.length) {
        return list[index] as U?;
      }
      return null;
    }
    throw ReactiveException('Value is not a List, cannot access index $index');
  }
  
  /// 如果值是List，提供索引设置
  void setIndex<U>(int index, U value) {
    if (_value is List) {
      final list = _value as List;
      if (index >= 0 && index < list.length && list[index] != value) {
        list[index] = value;
        notifyListeners();
      }
    } else {
      throw ReactiveException('Value is not a List, cannot set index $index');
    }
  }
  
  /// 如果值是List，添加元素
  void add<U>(U item) {
    if (_value is List<U>) {
      (_value as List<U>).add(item);
      notifyListeners();
    } else {
      throw ReactiveException('Value is not a List<${U.toString()}>, cannot add item');
    }
  }
  
  /// 如果值是List，移除元素
  bool remove<U>(U item) {
    if (_value is List<U>) {
      final removed = (_value as List<U>).remove(item);
      if (removed) {
        notifyListeners();
      }
      return removed;
    } else {
      throw ReactiveException('Value is not a List<${U.toString()}>, cannot remove item');
    }
  }
}

/// 创建响应式对象的工厂方法
class ReactiveFactory {
  /// 创建响应式变量
  static Reactive<T> ref<T>(T initialValue) {
    return Reactive<T>(initialValue);
  }
  
  /// 创建响应式Map
  static Reactive<Map<String, dynamic>> reactiveMap([Map<String, dynamic>? initialValue]) {
    return Reactive<Map<String, dynamic>>(initialValue ?? {});
  }
  
  /// 创建响应式List
  static Reactive<List<T>> reactiveList<T>([List<T>? initialValue]) {
    return Reactive<List<T>>(initialValue ?? <T>[]);
  }
  
  /// 将普通对象转换为响应式对象
  static Reactive<T> reactive<T>(T value) {
    return Reactive<T>(value);
  }
}

/// 响应式异常类
class ReactiveException implements Exception {
  final String message;
  const ReactiveException(this.message);
  
  @override
  String toString() => 'ReactiveException: $message';
}

/// 混入类，为自定义类提供响应式能力
mixin ReactiveMixin on ChangeNotifier {
  /// 更新并通知
  void reactiveUpdate(void Function() updateFn) {
    updateFn();
    notifyListeners();
  }
  
  /// 设置属性并通知（需要子类实现具体的属性设置逻辑）
  void setReactiveProperty<T>(String propertyName, T value);
  
  /// 获取属性（需要子类实现具体的属性获取逻辑）
  T getReactiveProperty<T>(String propertyName);
}



# Flutter Vue2

一个为Flutter提供类似Vue2语法的响应式组件库。

[English](README.md) | [日本語ドキュメント](README_JP.md)

## 特性

- 🎯 **Data**: 响应式数据管理，类似Vue2的data选项
- 🔧 **Methods**: 方法管理，类似Vue2的methods选项  
- 📦 **Props**: 属性传递和验证，类似Vue2的props选项
- 🔄 **响应式**: 自动UI更新，当data变化时自动重新渲染
- 🎨 **灵活**: 支持继承和函数式两种组件创建方式
- 🛡️ **类型安全**: 完整的泛型支持和类型检查
- 🏗️ **复杂类型**: 支持自定义对象、深层嵌套和响应式对象
- ⚡ **高性能**: 智能的变化检测和优化的更新机制

## 安装

在 `pubspec.yaml` 中添加依赖:

```yaml
dependencies:
  flutter_vue2:
    path: ../flutter_vue2  # 或者从pub.dev安装
```

## 快速开始

### 方式1: 继承 VueComponent

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

class CounterComponent extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'count': 0,
      'message': '点击按钮增加计数',
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'increment': (MethodContext ctx) {
        final currentCount = ctx.getData<int>('count');
        ctx.setData('count', currentCount + 1);
        ctx.setData('message', '当前计数: ${currentCount + 1}');
      },
    };
  }
  
  @override
  Widget build(BuildContext context, VueComponentInstance instance) {
    return Column(
      children: [
        Text(instance.data.get<String>('message')),
        Text('${instance.data.get<int>('count')}'),
        ElevatedButton(
          onPressed: () => instance.methods.call('increment'),
          child: Text('+'),
        ),
      ],
    );
  }
}
```

### 方式2: 使用 Vue.component

```dart
Vue.component(
  initialData: {
    'count': 0,
  },
  methods: {
    'increment': (MethodContext ctx) {
      final count = ctx.getData<int>('count');
      ctx.setData('count', count + 1);
    },
  },
  builder: (instance) {
    return Column(
      children: [
        Text('${instance.data.get<int>('count')}'),
        ElevatedButton(
          onPressed: () => instance.methods.call('increment'),
          child: Text('+'),
        ),
      ],
    );
  },
)
```

## 核心概念

### Data (数据)

Data用于管理组件的响应式状态，类似Vue2的data选项:

```dart
@override
Map<String, dynamic> data() {
  return {
    'count': 0,
    'message': 'Hello Vue2',
    'items': <String>[],
    'user': {
      'name': '张三',
      'age': 25,
    },
  };
}
```

在方法中访问和修改data:

```dart
// 获取数据
final count = ctx.getData<int>('count');
final message = ctx.getData<String>('message');

// 设置单个数据
ctx.setData('count', count + 1);

// 批量设置数据
ctx.setAllData({
  'count': 10,
  'message': '批量更新',
});
```

### Methods (方法)

Methods用于定义组件的行为逻辑，类似Vue2的methods选项:

```dart
@override
Map<String, Function> methods() {
  return {
    // 无参数方法
    'reset': (MethodContext ctx) {
      ctx.setData('count', 0);
    },
    
    // 带参数方法
    'updateUser': (MethodContext ctx, String name, int age) {
      ctx.setAllData({
        'user': {
          'name': name,
          'age': age,
        },
      });
    },
    
    // 异步方法
    'fetchData': (MethodContext ctx) async {
      // 模拟API调用
      await Future.delayed(Duration(seconds: 1));
      ctx.setData('loading', false);
    },
  };
}
```

调用方法:

```dart
// 无参数调用
instance.methods.call('reset');

// 带参数调用
instance.methods.call('updateUser', ['李四', 30]);
```

### Props (属性)

Props用于父组件向子组件传递数据，类似Vue2的props选项:

```dart
@override
Map<String, PropDefinition> propsDefinition() {
  return {
    // 必需的字符串属性
    'title': PropDefinition(
      type: String, 
      required: true
    ),
    
    // 带默认值的整数属性
    'count': PropDefinition(
      type: int, 
      defaultValue: 0
    ),
    
    // 带验证的属性
    'email': PropDefinition(
      type: String,
      validator: (value) => value.contains('@'),
    ),
  };
}
```

在组件中使用props:

```dart
@override
Widget build(BuildContext context, VueComponentInstance instance) {
  final title = instance.props.get<String>('title');
  final count = instance.props.get<int>('count');
  
  return Column(
    children: [
      Text(title),
      Text('Count: $count'),
    ],
  );
}
```

传递props:

```dart
MyComponent(
  props: {
    'title': '标题',
    'count': 10,
    'email': 'user@example.com',
  },
)
```

## 高级功能

### 复杂类型支持

```dart
// 自定义用户类
class User {
  String name;
  int age;
  List<String> hobbies;
  
  User({required this.name, required this.age, required this.hobbies});
  
  User copyWith({String? name, int? age, List<String>? hobbies}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      hobbies: hobbies ?? this.hobbies,
    );
  }
}

class UserComponent extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'user': User(name: '张三', age: 25, hobbies: ['编程', '阅读']),
      'users': <User>[],
      'userMap': <String, User>{},
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'updateUser': (MethodContext ctx, String newName) {
        final user = ctx.getData<User>('user');
        ctx.setData('user', user.copyWith(name: newName));
      },
      
      'addHobby': (MethodContext ctx, String hobby) {
        final user = ctx.getData<User>('user');
        final newHobbies = List<String>.from(user.hobbies)..add(hobby);
        ctx.setData('user', user.copyWith(hobbies: newHobbies));
      },
    };
  }
}
```

### 响应式对象

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

// 使用Reactive包装器
Vue.component(
  initialData: {
    'counter': ReactiveFactory.ref(0),
    'user': ReactiveFactory.reactiveMap({
      'name': '李四',
      'age': 30,
    }),
    'items': ReactiveFactory.reactiveList<String>(['苹果', '香蕉']),
  },
  methods: {
    'increment': (MethodContext ctx) {
      final counter = ctx.getData<Reactive<int>>('counter');
      counter.value++; // 自动触发UI更新
    },
    
    'updateUserName': (MethodContext ctx, String newName) {
      final user = ctx.getData<Reactive<Map<String, dynamic>>>('user');
      user.setProperty('name', newName); // 深度响应式
    },
    
    'addItem': (MethodContext ctx, String item) {
      final items = ctx.getData<Reactive<List<String>>>('items');
      items.add(item); // 列表变化自动响应
    },
  },
  builder: (instance) {
    final counter = instance.data.get<Reactive<int>>('counter');
    final user = instance.data.get<Reactive<Map<String, dynamic>>>('user');
    
    return Column(
      children: [
        Text('计数: ${counter.value}'),
        Text('用户: ${user.getProperty<String>('name')}'),
        // ... 其他UI
      ],
    );
  },
)
```

### 类型安全的数据访问

```dart
// 类型安全的访问
final userName = instance.data.get<String>('userName');
final userAge = instance.data.get<int>('userAge');
final userList = instance.data.get<List<User>>('users');

// 安全访问（返回null如果不存在或类型不匹配）
final userName = instance.data.getSafe<String>('userName');

// 带默认值的访问
final userName = instance.data.getOrDefault<String>('userName', '默认用户');

// 深度对象属性访问
instance.data.updateProperty<String>('user', 'name', '新名字');
final userName = instance.data.getProperty<String>('user', 'name');
```

## API 参考

### VueData

- `get<T>(String key)`: 获取数据（类型安全）
- `getSafe<T>(String key)`: 安全获取数据
- `getOrDefault<T>(String key, T defaultValue)`: 获取数据或默认值
- `set<T>(String key, T value)`: 设置数据（类型安全）
- `setAll(Map<String, dynamic> data)`: 批量设置数据
- `updateProperty<T>(String key, String property, T value)`: 更新对象属性
- `getProperty<T>(String key, String property)`: 获取对象属性
- `has(String key)`: 检查是否包含某个key
- `getType(String key)`: 获取key的类型
- `remove(String key)`: 删除数据
- `clear()`: 清空所有数据

### VueMethods

- `call<T>(String name, [List<dynamic>? args])`: 调用方法
- `has(String name)`: 检查方法是否存在
- `register(String name, Function method)`: 注册方法

### VueProps

- `get<T>(String name)`: 获取prop值
- `has(String name)`: 检查prop是否存在
- `define(String name, {...})`: 定义prop

### MethodContext

方法执行上下文，提供对data的访问:

- `getData<T>(String key)`: 获取data中的值（类型安全）
- `getDataSafe<T>(String key)`: 安全获取data中的值
- `getDataOrDefault<T>(String key, T defaultValue)`: 获取data中的值或默认值
- `setData<T>(String key, T value)`: 设置data中的值（类型安全）
- `setAllData(Map<String, dynamic> data)`: 批量设置data
- `updateProperty<T>(String key, String property, T value)`: 更新对象属性
- `getProperty<T>(String key, String property)`: 获取对象属性

## 完整示例

查看以下示例文件：
- `example/main.dart` - 基础使用示例
- `example/complex_types_example.dart` - 复杂类型和响应式对象示例

## 许可证

MIT License

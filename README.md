# Flutter Vue2

A Flutter library that provides Vue2-like syntax for reactive component development.

[中文文档](README_CN.md) | [日本語ドキュメント](README_JP.md)

## Features

- 🎯 **Data**: Reactive data management, similar to Vue2's data option
- 🔧 **Methods**: Method management, similar to Vue2's methods option  
- 📦 **Props**: Property passing and validation, similar to Vue2's props option
- 🔄 **Reactive**: Automatic UI updates when data changes
- 🎨 **Flexible**: Support for both inheritance and functional component creation
- 🛡️ **Type Safe**: Complete generic support and type checking
- 🏗️ **Complex Types**: Support for custom objects, deep nesting and reactive objects
- ⚡ **High Performance**: Smart change detection and optimized update mechanism

## Installation

Add dependency in `pubspec.yaml`:

```yaml
dependencies:
  flutter_vue2:
    path: ../flutter_vue2  # or install from pub.dev
```

## Quick Start

### Method 1: Inherit VueComponent

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

class CounterComponent extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'count': 0,
      'message': 'Click button to increment count',
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'increment': (MethodContext ctx) {
        final currentCount = ctx.getData<int>('count');
        ctx.setData('count', currentCount + 1);
        ctx.setData('message', 'Current count: ${currentCount + 1}');
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

### Method 2: Use Vue.component

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

## Core Concepts

### Data

Data manages the reactive state of components, similar to Vue2's data option:

```dart
@override
Map<String, dynamic> data() {
  return {
    'count': 0,
    'message': 'Hello Vue2',
    'items': <String>[],
    'user': {
      'name': 'John',
      'age': 25,
    },
  };
}
```

Access and modify data in methods:

```dart
// Get data
final count = ctx.getData<int>('count');
final message = ctx.getData<String>('message');

// Set single data
ctx.setData('count', count + 1);

// Set multiple data
ctx.setAllData({
  'count': 10,
  'message': 'Batch update',
});
```

### Methods

Methods define component behavior logic, similar to Vue2's methods option:

```dart
@override
Map<String, Function> methods() {
  return {
    // Method without parameters
    'reset': (MethodContext ctx) {
      ctx.setData('count', 0);
    },
    
    // Method with parameters
    'updateUser': (MethodContext ctx, String name, int age) {
      ctx.setAllData({
        'user': {
          'name': name,
          'age': age,
        },
      });
    },
    
    // Async method
    'fetchData': (MethodContext ctx) async {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      ctx.setData('loading', false);
    },
  };
}
```

Call methods:

```dart
// Call without parameters
instance.methods.call('reset');

// Call with parameters
instance.methods.call('updateUser', ['Jane', 30]);
```

### Props

Props pass data from parent to child components, similar to Vue2's props option:

```dart
@override
Map<String, PropDefinition> propsDefinition() {
  return {
    // Required string property
    'title': PropDefinition(
      type: String, 
      required: true
    ),
    
    // Integer property with default value
    'count': PropDefinition(
      type: int, 
      defaultValue: 0
    ),
    
    // Property with validation
    'email': PropDefinition(
      type: String,
      validator: (value) => value.contains('@'),
    ),
  };
}
```

Use props in components:

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

Pass props:

```dart
MyComponent(
  props: {
    'title': 'Title',
    'count': 10,
    'email': 'user@example.com',
  },
)
```

## Advanced Features

### Complex Type Support

```dart
// Custom user class
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
      'user': User(name: 'John', age: 25, hobbies: ['Programming', 'Reading']),
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

### Reactive Objects

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

// Use Reactive wrapper
Vue.component(
  initialData: {
    'counter': ReactiveFactory.ref(0),
    'user': ReactiveFactory.reactiveMap({
      'name': 'Jane',
      'age': 30,
    }),
    'items': ReactiveFactory.reactiveList<String>(['Apple', 'Banana']),
  },
  methods: {
    'increment': (MethodContext ctx) {
      final counter = ctx.getData<Reactive<int>>('counter');
      counter.value++; // Automatically triggers UI update
    },
    
    'updateUserName': (MethodContext ctx, String newName) {
      final user = ctx.getData<Reactive<Map<String, dynamic>>>('user');
      user.setProperty('name', newName); // Deep reactivity
    },
    
    'addItem': (MethodContext ctx, String item) {
      final items = ctx.getData<Reactive<List<String>>>('items');
      items.add(item); // List changes automatically respond
    },
  },
  builder: (instance) {
    final counter = instance.data.get<Reactive<int>>('counter');
    final user = instance.data.get<Reactive<Map<String, dynamic>>>('user');
    
    return Column(
      children: [
        Text('Count: ${counter.value}'),
        Text('User: ${user.getProperty<String>('name')}'),
        // ... other UI
      ],
    );
  },
)
```

### Type-Safe Data Access

```dart
// Type-safe access
final userName = instance.data.get<String>('userName');
final userAge = instance.data.get<int>('userAge');
final userList = instance.data.get<List<User>>('users');

// Safe access (returns null if not exists or type mismatch)
final userName = instance.data.getSafe<String>('userName');

// Access with default value
final userName = instance.data.getOrDefault<String>('userName', 'Default User');

// Deep object property access
instance.data.updateProperty<String>('user', 'name', 'New Name');
final userName = instance.data.getProperty<String>('user', 'name');
```

## API Reference

### VueData

- `get<T>(String key)`: Get data (type safe)
- `getSafe<T>(String key)`: Safe get data
- `getOrDefault<T>(String key, T defaultValue)`: Get data or default value
- `set<T>(String key, T value)`: Set data (type safe)
- `setAll(Map<String, dynamic> data)`: Set multiple data
- `updateProperty<T>(String key, String property, T value)`: Update object property
- `getProperty<T>(String key, String property)`: Get object property
- `has(String key)`: Check if key exists
- `getType(String key)`: Get key type
- `remove(String key)`: Remove data
- `clear()`: Clear all data

### VueMethods

- `call<T>(String name, [List<dynamic>? args])`: Call method
- `has(String name)`: Check if method exists
- `register(String name, Function method)`: Register method

### VueProps

- `get<T>(String name)`: Get prop value
- `has(String name)`: Check if prop exists
- `define(String name, {...})`: Define prop

### MethodContext

Method execution context, provides access to data:

- `getData<T>(String key)`: Get data value (type safe)
- `getDataSafe<T>(String key)`: Safe get data value
- `getDataOrDefault<T>(String key, T defaultValue)`: Get data value or default
- `setData<T>(String key, T value)`: Set data value (type safe)
- `setAllData(Map<String, dynamic> data)`: Set multiple data
- `updateProperty<T>(String key, String property, T value)`: Update object property
- `getProperty<T>(String key, String property)`: Get object property

## Complete Examples

Check the following example files:
- `example/main.dart` - Basic usage examples
- `example/complex_types_example.dart` - Complex types and reactive objects examples

## License

MIT License
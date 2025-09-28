# Flutter Vue2

FlutterでVue2のような構文を提供するリアクティブコンポーネントライブラリ。

[English](README.md) | [中文文档](README_CN.md)

## 特徴

- 🎯 **Data**: Vue2のdataオプションのようなリアクティブデータ管理
- 🔧 **Methods**: Vue2のmethodsオプションのようなメソッド管理  
- 📦 **Props**: Vue2のpropsオプションのようなプロパティ渡しと検証
- 🔄 **リアクティブ**: データ変更時の自動UI更新
- 🎨 **柔軟性**: 継承と関数型の両方のコンポーネント作成方式をサポート
- 🛡️ **型安全**: 完全なジェネリクスサポートと型チェック
- 🏗️ **複雑な型**: カスタムオブジェクト、深いネスト、リアクティブオブジェクトをサポート
- ⚡ **高性能**: スマートな変更検出と最適化された更新メカニズム

## インストール

`pubspec.yaml`に依存関係を追加:

```yaml
dependencies:
  flutter_vue2:
    path: ../flutter_vue2  # またはpub.devからインストール
```

## クイックスタート

### 方法1: VueComponentを継承

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

class CounterComponent extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'count': 0,
      'message': 'ボタンをクリックしてカウントを増加',
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'increment': (MethodContext ctx) {
        final currentCount = ctx.getData<int>('count');
        ctx.setData('count', currentCount + 1);
        ctx.setData('message', '現在のカウント: ${currentCount + 1}');
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

### 方法2: Vue.componentを使用

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

## コア概念

### Data（データ）

DataはVue2のdataオプションのようにコンポーネントのリアクティブ状態を管理します:

```dart
@override
Map<String, dynamic> data() {
  return {
    'count': 0,
    'message': 'Hello Vue2',
    'items': <String>[],
    'user': {
      'name': '田中',
      'age': 25,
    },
  };
}
```

メソッド内でのdataアクセスと変更:

```dart
// データ取得
final count = ctx.getData<int>('count');
final message = ctx.getData<String>('message');

// 単一データ設定
ctx.setData('count', count + 1);

// 一括データ設定
ctx.setAllData({
  'count': 10,
  'message': '一括更新',
});
```

### Methods（メソッド）

MethodsはVue2のmethodsオプションのようにコンポーネントの動作ロジックを定義します:

```dart
@override
Map<String, Function> methods() {
  return {
    // パラメータなしメソッド
    'reset': (MethodContext ctx) {
      ctx.setData('count', 0);
    },
    
    // パラメータありメソッド
    'updateUser': (MethodContext ctx, String name, int age) {
      ctx.setAllData({
        'user': {
          'name': name,
          'age': age,
        },
      });
    },
    
    // 非同期メソッド
    'fetchData': (MethodContext ctx) async {
      // API呼び出しをシミュレート
      await Future.delayed(Duration(seconds: 1));
      ctx.setData('loading', false);
    },
  };
}
```

メソッド呼び出し:

```dart
// パラメータなし呼び出し
instance.methods.call('reset');

// パラメータあり呼び出し
instance.methods.call('updateUser', ['佐藤', 30]);
```

### Props（プロパティ）

PropsはVue2のpropsオプションのように親コンポーネントから子コンポーネントへデータを渡します:

```dart
@override
Map<String, PropDefinition> propsDefinition() {
  return {
    // 必須の文字列プロパティ
    'title': PropDefinition(
      type: String, 
      required: true
    ),
    
    // デフォルト値付きの整数プロパティ
    'count': PropDefinition(
      type: int, 
      defaultValue: 0
    ),
    
    // バリデーション付きプロパティ
    'email': PropDefinition(
      type: String,
      validator: (value) => value.contains('@'),
    ),
  };
}
```

コンポーネント内でのprops使用:

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

props渡し:

```dart
MyComponent(
  props: {
    'title': 'タイトル',
    'count': 10,
    'email': 'user@example.com',
  },
)
```

## 高度な機能

### 複雑な型のサポート

```dart
// カスタムユーザークラス
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
      'user': User(name: '田中', age: 25, hobbies: ['プログラミング', '読書']),
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

### リアクティブオブジェクト

```dart
import 'package:flutter_vue2/flutter_vue2.dart';

// Reactiveラッパーを使用
Vue.component(
  initialData: {
    'counter': ReactiveFactory.ref(0),
    'user': ReactiveFactory.reactiveMap({
      'name': '佐藤',
      'age': 30,
    }),
    'items': ReactiveFactory.reactiveList<String>(['りんご', 'バナナ']),
  },
  methods: {
    'increment': (MethodContext ctx) {
      final counter = ctx.getData<Reactive<int>>('counter');
      counter.value++; // 自動的にUI更新をトリガー
    },
    
    'updateUserName': (MethodContext ctx, String newName) {
      final user = ctx.getData<Reactive<Map<String, dynamic>>>('user');
      user.setProperty('name', newName); // 深いリアクティブ
    },
    
    'addItem': (MethodContext ctx, String item) {
      final items = ctx.getData<Reactive<List<String>>>('items');
      items.add(item); // リスト変更の自動応答
    },
  },
  builder: (instance) {
    final counter = instance.data.get<Reactive<int>>('counter');
    final user = instance.data.get<Reactive<Map<String, dynamic>>>('user');
    
    return Column(
      children: [
        Text('カウント: ${counter.value}'),
        Text('ユーザー: ${user.getProperty<String>('name')}'),
        // ... その他のUI
      ],
    );
  },
)
```

### 型安全なデータアクセス

```dart
// 型安全なアクセス
final userName = instance.data.get<String>('userName');
final userAge = instance.data.get<int>('userAge');
final userList = instance.data.get<List<User>>('users');

// 安全なアクセス（存在しないか型が一致しない場合はnullを返す）
final userName = instance.data.getSafe<String>('userName');

// デフォルト値付きアクセス
final userName = instance.data.getOrDefault<String>('userName', 'デフォルトユーザー');

// 深いオブジェクトプロパティアクセス
instance.data.updateProperty<String>('user', 'name', '新しい名前');
final userName = instance.data.getProperty<String>('user', 'name');
```

## API リファレンス

### VueData

- `get<T>(String key)`: データ取得（型安全）
- `getSafe<T>(String key)`: 安全なデータ取得
- `getOrDefault<T>(String key, T defaultValue)`: データ取得またはデフォルト値
- `set<T>(String key, T value)`: データ設定（型安全）
- `setAll(Map<String, dynamic> data)`: 一括データ設定
- `updateProperty<T>(String key, String property, T value)`: オブジェクトプロパティ更新
- `getProperty<T>(String key, String property)`: オブジェクトプロパティ取得
- `has(String key)`: キーの存在確認
- `getType(String key)`: キーの型取得
- `remove(String key)`: データ削除
- `clear()`: 全データクリア

### VueMethods

- `call<T>(String name, [List<dynamic>? args])`: メソッド呼び出し
- `has(String name)`: メソッド存在確認
- `register(String name, Function method)`: メソッド登録

### VueProps

- `get<T>(String name)`: prop値取得
- `has(String name)`: prop存在確認
- `define(String name, {...})`: prop定義

### MethodContext

メソッド実行コンテキスト、dataへのアクセスを提供:

- `getData<T>(String key)`: dataの値取得（型安全）
- `getDataSafe<T>(String key)`: dataの安全な値取得
- `getDataOrDefault<T>(String key, T defaultValue)`: dataの値取得またはデフォルト値
- `setData<T>(String key, T value)`: dataの値設定（型安全）
- `setAllData(Map<String, dynamic> data)`: dataの一括設定
- `updateProperty<T>(String key, String property, T value)`: オブジェクトプロパティ更新
- `getProperty<T>(String key, String property)`: オブジェクトプロパティ取得

## 完全な例

以下のサンプルファイルを参照してください：
- `example/main.dart` - 基本的な使用例
- `example/complex_types_example.dart` - 複雑な型とリアクティブオブジェクトの例

## ライセンス

MIT License

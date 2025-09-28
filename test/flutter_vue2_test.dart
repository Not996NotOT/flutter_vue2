import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vue2/flutter_vue2.dart';

// 测试用的自定义类
class TestUser {
  String name;
  int age;
  List<String> hobbies;
  
  TestUser({required this.name, required this.age, required this.hobbies});
  
  TestUser copyWith({String? name, int? age, List<String>? hobbies}) {
    return TestUser(
      name: name ?? this.name,
      age: age ?? this.age,
      hobbies: hobbies ?? List.from(this.hobbies),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestUser &&
        other.name == name &&
        other.age == age;
  }
  
  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

void main() {
  group('VueData Tests', () {
    late VueData vueData;
    
    setUp(() {
      vueData = VueData();
    });
    
    tearDown(() {
      vueData.dispose();
    });
    
    test('should initialize data correctly', () {
      vueData.initData({'count': 0, 'message': 'hello'});
      
      expect(vueData.get<int>('count'), 0);
      expect(vueData.get<String>('message'), 'hello');
    });
    
    test('should set and get data correctly', () {
      vueData.initData({'count': 0});
      vueData.set('count', 5);
      
      expect(vueData.get<int>('count'), 5);
    });
    
    test('should check if key exists', () {
      vueData.initData({'count': 0});
      
      expect(vueData.has('count'), true);
      expect(vueData.has('nonexistent'), false);
    });
    
    test('should remove data correctly', () {
      vueData.initData({'count': 0, 'message': 'hello'});
      vueData.remove('count');
      
      expect(vueData.has('count'), false);
      expect(vueData.has('message'), true);
    });
  });
  
  group('VueMethods Tests', () {
    late VueData vueData;
    late VueMethods vueMethods;
    
    setUp(() {
      vueData = VueData();
      vueMethods = VueMethods(vueData);
      vueData.initData({'count': 0});
    });
    
    tearDown(() {
      vueData.dispose();
    });
    
    test('should register and call methods', () {
      vueMethods.register('increment', (MethodContext ctx) {
        final count = ctx.getData<int>('count');
        ctx.setData('count', count + 1);
      });
      
      vueMethods.call('increment');
      expect(vueData.get<int>('count'), 1);
    });
    
    test('should call methods with parameters', () {
      vueMethods.register('add', (MethodContext ctx, int value) {
        final count = ctx.getData<int>('count');
        ctx.setData('count', count + value);
      });
      
      vueMethods.call('add', [5]);
      expect(vueData.get<int>('count'), 5);
    });
    
    test('should check if method exists', () {
      vueMethods.register('test', (MethodContext ctx) {});
      
      expect(vueMethods.has('test'), true);
      expect(vueMethods.has('nonexistent'), false);
    });
  });
  
  group('VueProps Tests', () {
    late VueProps vueProps;
    
    setUp(() {
      vueProps = VueProps();
    });
    
    test('should define and validate props', () {
      vueProps.define('name', type: String, required: true);
      vueProps.define('age', type: int, defaultValue: 18);
      
      vueProps.setProps({'name': '张三', 'age': 25});
      
      expect(vueProps.get<String>('name'), '张三');
      expect(vueProps.get<int>('age'), 25);
    });
    
    test('should use default values', () {
      vueProps.define('age', type: int, defaultValue: 18);
      vueProps.setProps({});
      
      expect(vueProps.get<int>('age'), 18);
    });
    
    test('should throw error for missing required props', () {
      vueProps.define('name', type: String, required: true);
      
      expect(() => vueProps.setProps({}), throwsException);
    });
    
    test('should validate prop types', () {
      vueProps.define('age', type: int);
      
      expect(() => vueProps.setProps({'age': 'not a number'}), throwsException);
    });
    
    test('should run custom validators', () {
      vueProps.define('email', 
        type: String, 
        validator: (value) => value.toString().contains('@')
      );
      
      expect(() => vueProps.setProps({'email': 'invalid-email'}), throwsException);
      
      vueProps.setProps({'email': 'valid@email.com'});
      expect(vueProps.get<String>('email'), 'valid@email.com');
    });
  });
  
  group('Complex Types Tests', () {
    late VueData vueData;
    
    setUp(() {
      vueData = VueData();
    });
    
    tearDown(() {
      vueData.dispose();
    });
    
    test('should handle custom objects', () {
      final user = TestUser(name: 'John', age: 25, hobbies: ['coding']);
      vueData.initData({'user': user});
      
      final retrievedUser = vueData.get<TestUser>('user');
      expect(retrievedUser.name, 'John');
      expect(retrievedUser.age, 25);
      expect(retrievedUser.hobbies, ['coding']);
    });
    
    test('should handle complex nested objects', () {
      final complexData = {
        'users': <TestUser>[
          TestUser(name: 'Alice', age: 30, hobbies: ['reading']),
          TestUser(name: 'Bob', age: 25, hobbies: ['gaming']),
        ],
        'userMap': <String, TestUser>{
          'admin': TestUser(name: 'Admin', age: 35, hobbies: ['managing']),
        },
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'preferences': {
            'language': 'en',
            'timezone': 'UTC',
          },
        },
      };
      
      vueData.initData(complexData);
      
      final users = vueData.get<List<TestUser>>('users');
      expect(users.length, 2);
      expect(users[0].name, 'Alice');
      
      final userMap = vueData.get<Map<String, TestUser>>('userMap');
      expect(userMap['admin']?.name, 'Admin');
      
      final settings = vueData.get<Map<String, dynamic>>('settings');
      expect(settings['theme'], 'dark');
    });
    
    test('should handle deep property access', () {
      vueData.initData({
        'user': {
          'name': 'John',
          'age': 25,
          'settings': {
            'theme': 'light',
          },
        },
      });
      
      vueData.updateProperty<String>('user', 'name', 'Jane');
      final userName = vueData.getProperty<String>('user', 'name');
      expect(userName, 'Jane');
      
      // 测试更新年龄
      vueData.updateProperty<int>('user', 'age', 30);
      final userAge = vueData.getProperty<int>('user', 'age');
      expect(userAge, 30);
    });
    
    test('should handle type safety with getSafe', () {
      vueData.initData({'count': 42, 'name': 'test'});
      
      // 正确类型
      expect(vueData.getSafe<int>('count'), 42);
      expect(vueData.getSafe<String>('name'), 'test');
      
      // 错误类型应该返回null
      expect(vueData.getSafe<String>('count'), null);
      expect(vueData.getSafe<int>('name'), null);
      
      // 不存在的key应该返回null
      expect(vueData.getSafe<String>('nonexistent'), null);
    });
    
    test('should handle getOrDefault', () {
      vueData.initData({'count': 42});
      
      expect(vueData.getOrDefault<int>('count', 0), 42);
      expect(vueData.getOrDefault<int>('nonexistent', 100), 100);
      expect(vueData.getOrDefault<String>('count', 'default'), 'default'); // 类型不匹配
    });
    
    test('should throw VueDataException for invalid operations', () {
      vueData.initData({'count': 42});
      
      // 获取不存在的key
      expect(() => vueData.get<String>('nonexistent'), throwsA(isA<VueDataException>()));
      
      // 类型不匹配
      expect(() => vueData.get<String>('count'), throwsA(isA<VueDataException>()));
      
      // 深度访问不存在的对象
      expect(() => vueData.getProperty<String>('nonexistent', 'name'), throwsA(isA<VueDataException>()));
    });
  });
  
  group('Reactive Objects Tests', () {
    test('should create reactive ref', () {
      final counter = ReactiveFactory.ref(0);
      var notified = false;
      
      counter.addListener(() {
        notified = true;
      });
      
      counter.value = 5;
      expect(counter.value, 5);
      expect(notified, true);
    });
    
    test('should create reactive map', () {
      final reactiveMap = ReactiveFactory.reactiveMap({'name': 'John', 'age': 25});
      var notified = false;
      
      reactiveMap.addListener(() {
        notified = true;
      });
      
      reactiveMap.setProperty('name', 'Jane');
      expect(reactiveMap.getProperty<String>('name'), 'Jane');
      expect(notified, true);
    });
    
    test('should create reactive list', () {
      final reactiveList = ReactiveFactory.reactiveList<String>(['apple', 'banana']);
      var notified = false;
      
      reactiveList.addListener(() {
        notified = true;
      });
      
      reactiveList.add('orange');
      expect(reactiveList.value.length, 3);
      expect(reactiveList.value.contains('orange'), true);
      expect(notified, true);
    });
    
    test('should handle reactive list operations', () {
      final reactiveList = ReactiveFactory.reactiveList<String>(['apple', 'banana']);
      
      // 添加元素
      reactiveList.add('orange');
      expect(reactiveList.value, ['apple', 'banana', 'orange']);
      
      // 移除元素
      final removed = reactiveList.remove('banana');
      expect(removed, true);
      expect(reactiveList.value, ['apple', 'orange']);
      
      // 索引访问
      expect(reactiveList.getIndex<String>(0), 'apple');
      
      // 索引设置
      reactiveList.setIndex(0, 'grape');
      expect(reactiveList.value[0], 'grape');
    });
    
    test('should throw ReactiveException for invalid operations', () {
      final counter = ReactiveFactory.ref(42);
      
      // 尝试在非Map对象上访问属性
      expect(() => counter.getProperty<String>('name'), throwsA(isA<ReactiveException>()));
      
      // 尝试在非List对象上访问索引
      expect(() => counter.getIndex<int>(0), throwsA(isA<ReactiveException>()));
    });
  });
  
  group('Integration Tests', () {
    test('should work with VueData and Reactive together', () {
      final vueData = VueData();
      final counter = ReactiveFactory.ref(0);
      final userMap = ReactiveFactory.reactiveMap({'name': 'John'});
      
      vueData.initData({
        'counter': counter,
        'user': userMap,
        'regularData': 'test',
      });
      
      // 测试响应式对象
      final retrievedCounter = vueData.get<Reactive<int>>('counter');
      expect(retrievedCounter.value, 0);
      
      retrievedCounter.value = 10;
      expect(vueData.get<Reactive<int>>('counter').value, 10);
      
      // 测试响应式Map
      final retrievedUser = vueData.get<Reactive<Map<String, dynamic>>>('user');
      expect(retrievedUser.getProperty<String>('name'), 'John');
      
      retrievedUser.setProperty('name', 'Jane');
      expect(vueData.get<Reactive<Map<String, dynamic>>>('user').getProperty<String>('name'), 'Jane');
      
      // 测试普通数据
      expect(vueData.get<String>('regularData'), 'test');
      
      vueData.dispose();
    });
  });
}



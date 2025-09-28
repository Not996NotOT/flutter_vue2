import 'package:flutter/material.dart';

import '../lib/flutter_vue2.dart';

void main() {
  runApp(ComplexTypesApp());
}

class ComplexTypesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vue2 复杂类型示例',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ComplexTypesDemo(),
    );
  }
}

class ComplexTypesDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('复杂类型支持示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            UserProfileExample(),
            SizedBox(height: 20),
            TodoListExample(),
            SizedBox(height: 20),
            ReactiveObjectExample(),
          ],
        ),
      ),
    );
  }
}

/// 用户资料类型定义
class User {
  String name;
  int age;
  String email;
  List<String> hobbies;
  Map<String, dynamic> settings;
  
  User({
    required this.name,
    required this.age,
    required this.email,
    required this.hobbies,
    required this.settings,
  });
  
  User copyWith({
    String? name,
    int? age,
    String? email,
    List<String>? hobbies,
    Map<String, dynamic>? settings,
  }) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      hobbies: hobbies ?? List.from(this.hobbies),
      settings: settings ?? Map.from(this.settings),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'hobbies': hobbies,
      'settings': settings,
    };
  }
  
  @override
  String toString() => 'User(name: $name, age: $age, email: $email)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.name == name &&
        other.age == age &&
        other.email == email;
  }
  
  @override
  int get hashCode => name.hashCode ^ age.hashCode ^ email.hashCode;
}

/// 用户资料管理组件
class UserProfileExample extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'user': User(
        name: '张三',
        age: 25,
        email: 'zhangsan@example.com',
        hobbies: ['编程', '阅读', '音乐'],
        settings: {
          'theme': 'dark',
          'notifications': true,
          'language': 'zh-CN',
        },
      ),
      'editingField': '',
      'tempValue': '',
      'loading': false,
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'updateUserName': (MethodContext ctx, String newName) {
        final user = ctx.getData<User>('user');
        final updatedUser = user.copyWith(name: newName);
        ctx.setData('user', updatedUser);
      },
      
      'updateUserAge': (MethodContext ctx, int newAge) {
        final user = ctx.getData<User>('user');
        ctx.setData('user', user.copyWith(age: newAge));
      },
      
      'addHobby': (MethodContext ctx, String hobby) {
        final user = ctx.getData<User>('user');
        final newHobbies = List<String>.from(user.hobbies)..add(hobby);
        ctx.setData('user', user.copyWith(hobbies: newHobbies));
      },
      
      'removeHobby': (MethodContext ctx, String hobby) {
        final user = ctx.getData<User>('user');
        final newHobbies = List<String>.from(user.hobbies)..remove(hobby);
        ctx.setData('user', user.copyWith(hobbies: newHobbies));
      },
      
      'updateSetting': (MethodContext ctx, String key, dynamic value) {
        final user = ctx.getData<User>('user');
        final newSettings = Map<String, dynamic>.from(user.settings);
        newSettings[key] = value;
        ctx.setData('user', user.copyWith(settings: newSettings));
      },
      
      'startEdit': (MethodContext ctx, String field) {
        ctx.setData('editingField', field);
        final user = ctx.getData<User>('user');
        switch (field) {
          case 'name':
            ctx.setData('tempValue', user.name);
            break;
          case 'age':
            ctx.setData('tempValue', user.age.toString());
            break;
          case 'email':
            ctx.setData('tempValue', user.email);
            break;
        }
      },
      
      'saveEdit': (MethodContext ctx) {
        final field = ctx.getData<String>('editingField');
        final tempValue = ctx.getData<String>('tempValue');
        final user = ctx.getData<User>('user');
        
        switch (field) {
          case 'name':
            ctx.setData('user', user.copyWith(name: tempValue));
            break;
          case 'age':
            final age = int.tryParse(tempValue) ?? user.age;
            ctx.setData('user', user.copyWith(age: age));
            break;
          case 'email':
            ctx.setData('user', user.copyWith(email: tempValue));
            break;
        }
        
        ctx.setData('editingField', '');
        ctx.setData('tempValue', '');
      },
      
      'cancelEdit': (MethodContext ctx) {
        ctx.setData('editingField', '');
        ctx.setData('tempValue', '');
      },
    };
  }
  
  @override
  Widget build(BuildContext context, VueComponentInstance instance) {
    final user = instance.data.get<User>('user');
    final editingField = instance.data.get<String>('editingField');
    final tempValue = instance.data.get<String>('tempValue');
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用户资料管理', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            
            // 用户基本信息
            _buildEditableField(instance, '姓名', 'name', user.name, editingField, tempValue),
            _buildEditableField(instance, '年龄', 'age', user.age.toString(), editingField, tempValue),
            _buildEditableField(instance, '邮箱', 'email', user.email, editingField, tempValue),
            
            SizedBox(height: 16),
            
            // 爱好列表
            Text('爱好:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              children: user.hobbies.map((hobby) => Chip(
                label: Text(hobby),
                onDeleted: () => instance.methods.call('removeHobby', [hobby]),
              )).toList(),
            ),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: '添加新爱好'),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        instance.methods.call('addHobby', [value]);
                      }
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 设置
            Text('设置:', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text('深色主题'),
              value: user.settings['theme'] == 'dark',
              onChanged: (value) => instance.methods.call('updateSetting', [
                'theme', 
                value ? 'dark' : 'light'
              ]),
            ),
            SwitchListTile(
              title: Text('通知'),
              value: user.settings['notifications'] ?? false,
              onChanged: (value) => instance.methods.call('updateSetting', [
                'notifications', 
                value
              ]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEditableField(
    VueComponentInstance instance,
    String label,
    String field,
    String value,
    String editingField,
    String tempValue,
  ) {
    final isEditing = editingField == field;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('$label:')),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: TextEditingController(text: tempValue),
                    onChanged: (value) => instance.data.set('tempValue', value),
                    onSubmitted: (_) => instance.methods.call('saveEdit'),
                  )
                : Text(value),
          ),
          if (isEditing) ...[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => instance.methods.call('saveEdit'),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => instance.methods.call('cancelEdit'),
            ),
          ] else
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => instance.methods.call('startEdit', [field]),
            ),
        ],
      ),
    );
  }
}

/// Todo项目类型
class TodoItem {
  final String id;
  String title;
  String description;
  bool completed;
  DateTime createdAt;
  DateTime? completedAt;
  
  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    required this.createdAt,
    this.completedAt,
  });
  
  TodoItem copyWith({
    String? title,
    String? description,
    bool? completed,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Todo列表组件
class TodoListExample extends VueComponent {
  @override
  Map<String, dynamic> data() {
    return {
      'todos': <TodoItem>[
        TodoItem(
          id: '1',
          title: '学习Flutter Vue2',
          description: '深入了解响应式编程',
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: '2',
          title: '实现复杂类型支持',
          description: '支持自定义对象和泛型',
          completed: true,
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          completedAt: DateTime.now().subtract(Duration(minutes: 30)),
        ),
      ],
      'newTodoTitle': '',
      'filter': 'all', // all, active, completed
    };
  }
  
  @override
  Map<String, Function> methods() {
    return {
      'addTodo': (MethodContext ctx) {
        final title = ctx.getData<String>('newTodoTitle').trim();
        if (title.isEmpty) return;
        
        final todos = ctx.getData<List<TodoItem>>('todos');
        final newTodo = TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: '',
          createdAt: DateTime.now(),
        );
        
        ctx.setData('todos', [...todos, newTodo]);
        ctx.setData('newTodoTitle', '');
      },
      
      'toggleTodo': (MethodContext ctx, String id) {
        final todos = ctx.getData<List<TodoItem>>('todos');
        final updatedTodos = todos.map((todo) {
          if (todo.id == id) {
            return todo.copyWith(
              completed: !todo.completed,
              completedAt: !todo.completed ? DateTime.now() : null,
            );
          }
          return todo;
        }).toList();
        
        ctx.setData('todos', updatedTodos);
      },
      
      'removeTodo': (MethodContext ctx, String id) {
        final todos = ctx.getData<List<TodoItem>>('todos');
        final updatedTodos = todos.where((todo) => todo.id != id).toList();
        ctx.setData('todos', updatedTodos);
      },
      
      'setFilter': (MethodContext ctx, String filter) {
        ctx.setData('filter', filter);
      },
    };
  }
  
  @override
  Widget build(BuildContext context, VueComponentInstance instance) {
    final todos = instance.data.get<List<TodoItem>>('todos');
    final newTodoTitle = instance.data.get<String>('newTodoTitle');
    final filter = instance.data.get<String>('filter');
    
    // 根据过滤器筛选todos
    final filteredTodos = todos.where((todo) {
      switch (filter) {
        case 'active':
          return !todo.completed;
        case 'completed':
          return todo.completed;
        default:
          return true;
      }
    }).toList();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Todo列表', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            
            // 添加新todo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: newTodoTitle),
                    decoration: InputDecoration(hintText: '添加新任务'),
                    onChanged: (value) => instance.data.set('newTodoTitle', value),
                    onSubmitted: (_) => instance.methods.call('addTodo'),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => instance.methods.call('addTodo'),
                  child: Text('添加'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 过滤器
            Row(
              children: [
                _buildFilterChip(instance, '全部', 'all', filter),
                SizedBox(width: 8),
                _buildFilterChip(instance, '进行中', 'active', filter),
                SizedBox(width: 8),
                _buildFilterChip(instance, '已完成', 'completed', filter),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Todo列表
            ...filteredTodos.map((todo) => ListTile(
              leading: Checkbox(
                value: todo.completed,
                onChanged: (_) => instance.methods.call('toggleTodo', [todo.id]),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: todo.description.isNotEmpty ? Text(todo.description) : null,
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => instance.methods.call('removeTodo', [todo.id]),
              ),
            )),
            
            if (filteredTodos.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('暂无任务'),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(VueComponentInstance instance, String label, String value, String currentFilter) {
    return FilterChip(
      label: Text(label),
      selected: currentFilter == value,
      onSelected: (_) => instance.methods.call('setFilter', [value]),
    );
  }
}

/// 响应式对象示例
class ReactiveObjectExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Vue.component(
      initialData: {
        'counter': ReactiveFactory.ref(0),
        'user': ReactiveFactory.reactiveMap({
          'name': '李四',
          'age': 30,
          'isOnline': true,
        }),
        'items': ReactiveFactory.reactiveList<String>(['苹果', '香蕉', '橙子']),
      },
      methods: {
        'incrementCounter': (MethodContext ctx) {
          final counter = ctx.getData<Reactive<int>>('counter');
          counter.value++;
        },
        
        'updateUserName': (MethodContext ctx, String newName) {
          final user = ctx.getData<Reactive<Map<String, dynamic>>>('user');
          user.setProperty('name', newName);
        },
        
        'toggleUserStatus': (MethodContext ctx) {
          final user = ctx.getData<Reactive<Map<String, dynamic>>>('user');
          final currentStatus = user.getProperty<bool>('isOnline') ?? false;
          user.setProperty('isOnline', !currentStatus);
        },
        
        'addItem': (MethodContext ctx, String item) {
          final items = ctx.getData<Reactive<List<String>>>('items');
          items.add(item);
        },
        
        'removeItem': (MethodContext ctx, String item) {
          final items = ctx.getData<Reactive<List<String>>>('items');
          items.remove(item);
        },
      },
      builder: (instance) {
        final counter = instance.data.get<Reactive<int>>('counter');
        final user = instance.data.get<Reactive<Map<String, dynamic>>>('user');
        final items = instance.data.get<Reactive<List<String>>>('items');
        
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('响应式对象示例', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 16),
                
                // 计数器
                Row(
                  children: [
                    Text('计数器: ${counter.value}'),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => instance.methods.call('incrementCounter'),
                      child: Text('+1'),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // 用户信息
                Text('用户: ${user.getProperty<String>('name')} (${user.getProperty<int>('age')}岁)'),
                Text('状态: ${user.getProperty<bool>('isOnline')! ? '在线' : '离线'}'),
                
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => instance.methods.call('updateUserName', ['王五']),
                      child: Text('改名为王五'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => instance.methods.call('toggleUserStatus'),
                      child: Text('切换状态'),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // 项目列表
                Text('水果列表:'),
                Wrap(
                  children: items.value.map((item) => Chip(
                    label: Text(item),
                    onDeleted: () => instance.methods.call('removeItem', [item]),
                  )).toList(),
                ),
                
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => instance.methods.call('addItem', ['葡萄']),
                      child: Text('添加葡萄'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

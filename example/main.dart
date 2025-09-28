import 'package:flutter/material.dart';

import '../lib/flutter_vue2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vue2 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Vue2 风格组件'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 使用继承VueComponent的方式
            CounterComponent(),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            // 使用Vue.component的方式
            UserProfileComponent(
              props: {
                'name': '张三',
                'age': 25,
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 示例1: 继承VueComponent的计数器组件
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
      'decrement': (MethodContext ctx) {
        final currentCount = ctx.getData<int>('count');
        if (currentCount > 0) {
          ctx.setData('count', currentCount - 1);
          ctx.setData('message', '当前计数: ${currentCount - 1}');
        }
      },
      'reset': (MethodContext ctx) {
        ctx.setData('count', 0);
        ctx.setData('message', '计数已重置');
      },
    };
  }
  
  @override
  Widget build(BuildContext context, VueComponentInstance instance) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '计数器组件 (继承方式)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Text(
              instance.data.get<String>('message'),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '${instance.data.get<int>('count')}',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => instance.methods.call('decrement'),
                  child: Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => instance.methods.call('reset'),
                  child: Text('重置'),
                ),
                ElevatedButton(
                  onPressed: () => instance.methods.call('increment'),
                  child: Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 示例2: 使用Vue.component创建的用户资料组件
class UserProfileComponent extends StatelessWidget {
  final Map<String, dynamic>? props;
  
  const UserProfileComponent({Key? key, this.props}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Vue.component(
      props: props,
      propsDefinition: {
        'name': PropDefinition(type: String, required: true),
        'age': PropDefinition(type: int, defaultValue: 0),
        'email': PropDefinition(type: String, defaultValue: '未设置'),
      },
      initialData: {
        'isEditing': false,
        'editedName': '',
      },
      methods: {
        'toggleEdit': (MethodContext ctx) {
          final isEditing = ctx.getData<bool>('isEditing');
          ctx.setData('isEditing', !isEditing);
          if (!isEditing) {
            // 开始编辑时，将当前name设置为编辑值
            ctx.setData('editedName', ctx.getData<String>('editedName'));
          }
        },
        'updateName': (MethodContext ctx, String newName) {
          ctx.setData('editedName', newName);
        },
        'saveName': (MethodContext ctx) {
          final editedName = ctx.getData<String>('editedName');
          if (editedName.isNotEmpty) {
            // 这里应该调用API保存数据
            print('保存新名称: $editedName');
            ctx.setData('isEditing', false);
          }
        },
      },
      builder: (instance) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户资料组件 (Vue.component方式)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 15),
                if (!instance.data.get<bool>('isEditing')) ...[
                  Text('姓名: ${instance.props.get<String>('name')}'),
                  Text('年龄: ${instance.props.get<int>('age')}'),
                  Text('邮箱: ${instance.props.get<String>('email')}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => instance.methods.call('toggleEdit'),
                    child: Text('编辑'),
                  ),
                ] else ...[
                  TextField(
                    decoration: InputDecoration(labelText: '姓名'),
                    onChanged: (value) => instance.methods.call('updateName', [value]),
                    controller: TextEditingController(
                      text: instance.data.get<String>('editedName').isEmpty 
                        ? instance.props.get<String>('name')
                        : instance.data.get<String>('editedName')
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => instance.methods.call('saveName'),
                        child: Text('保存'),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () => instance.methods.call('toggleEdit'),
                        child: Text('取消'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

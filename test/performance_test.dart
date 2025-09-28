import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vue2/flutter_vue2.dart';

void main() {
  group('Performance Tests', () {
    test('should handle large data sets efficiently', () {
      final vueData = VueData();
      final stopwatch = Stopwatch()..start();
      
      // 创建大量数据
      final largeData = <String, dynamic>{};
      for (int i = 0; i < 10000; i++) {
        largeData['item_$i'] = {
          'id': i,
          'name': 'Item $i',
          'value': i * 2,
          'active': i % 2 == 0,
        };
      }
      
      vueData.initData(largeData);
      stopwatch.stop();
      
      print('Large data initialization took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 应该在1秒内完成
      
      // 测试访问性能
      stopwatch.reset();
      stopwatch.start();
      
      for (int i = 0; i < 1000; i++) {
        final item = vueData.get<Map<String, dynamic>>('item_$i');
        expect(item['id'], i);
      }
      
      stopwatch.stop();
      print('1000 data accesses took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 应该在100ms内完成
      
      vueData.dispose();
    });
    
    test('should handle frequent updates efficiently', () {
      final vueData = VueData();
      vueData.initData({'counter': 0});
      
      var notificationCount = 0;
      vueData.addListener(() {
        notificationCount++;
      });
      
      final stopwatch = Stopwatch()..start();
      
      // 执行大量更新
      for (int i = 0; i < 1000; i++) {
        vueData.set('counter', i);
      }
      
      stopwatch.stop();
      
      print('1000 updates took: ${stopwatch.elapsedMilliseconds}ms');
      print('Received $notificationCount notifications');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 应该在100ms内完成
      expect(notificationCount, 999); // 从1开始更新，所以是999次通知（0->1, 1->2, ..., 998->999）
      expect(vueData.get<int>('counter'), 999);
      
      vueData.dispose();
    });
    
    test('should handle reactive objects efficiently', () {
      final reactiveList = ReactiveFactory.reactiveList<int>();
      
      var notificationCount = 0;
      reactiveList.addListener(() {
        notificationCount++;
      });
      
      final stopwatch = Stopwatch()..start();
      
      // 添加大量元素
      for (int i = 0; i < 1000; i++) {
        reactiveList.add(i);
      }
      
      stopwatch.stop();
      
      print('1000 reactive list additions took: ${stopwatch.elapsedMilliseconds}ms');
      print('Received $notificationCount notifications');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // 应该在200ms内完成
      expect(notificationCount, 1000); // 每次添加都应该触发通知
      expect(reactiveList.value.length, 1000);
      
      reactiveList.dispose();
    });
    
    test('should handle complex object updates efficiently', () {
      final vueData = VueData();
      
      // 创建复杂的嵌套对象
      final complexObject = {
        'users': <Map<String, dynamic>>[],
        'settings': {
          'theme': 'light',
          'language': 'en',
          'features': <String, bool>{},
        },
        'cache': <String, dynamic>{},
      };
      
      vueData.initData(complexObject);
      
      final stopwatch = Stopwatch()..start();
      
      // 执行复杂的更新操作
      for (int i = 0; i < 100; i++) {
        // 更新用户列表
        final users = vueData.get<List<Map<String, dynamic>>>('users');
        users.add({
          'id': i,
          'name': 'User $i',
          'email': 'user$i@example.com',
          'preferences': {
            'notifications': i % 2 == 0,
            'theme': i % 3 == 0 ? 'dark' : 'light',
          },
        });
        vueData.set('users', users);
        
        // 更新设置
        vueData.updateProperty<String>('settings', 'theme', i % 2 == 0 ? 'dark' : 'light');
        
        // 更新缓存
        final cache = vueData.get<Map<String, dynamic>>('cache');
        cache['key_$i'] = 'value_$i';
        vueData.set('cache', cache);
      }
      
      stopwatch.stop();
      
      print('100 complex updates took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // 应该在500ms内完成
      
      // 验证数据正确性
      final users = vueData.get<List<Map<String, dynamic>>>('users');
      expect(users.length, 100);
      expect(users.last['name'], 'User 99');
      
      final cache = vueData.get<Map<String, dynamic>>('cache');
      expect(cache.length, 100);
      expect(cache['key_99'], 'value_99');
      
      vueData.dispose();
    });
    
    test('should handle memory efficiently', () {
      final vueDataList = <VueData>[];
      
      // 创建多个VueData实例
      for (int i = 0; i < 100; i++) {
        final vueData = VueData();
        vueData.initData({
          'id': i,
          'data': List.generate(100, (index) => 'item_${i}_$index'),
        });
        vueDataList.add(vueData);
      }
      
      // 验证所有实例都正常工作
      for (int i = 0; i < 100; i++) {
        final vueData = vueDataList[i];
        expect(vueData.get<int>('id'), i);
        expect(vueData.get<List<String>>('data').length, 100);
      }
      
      // 清理资源
      for (final vueData in vueDataList) {
        vueData.dispose();
      }
      
      // 这个测试主要是确保没有内存泄漏，如果有问题会在dispose时抛出异常
      expect(vueDataList.length, 100);
    });
  });
}

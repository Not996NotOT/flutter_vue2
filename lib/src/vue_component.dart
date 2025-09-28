import 'package:flutter/material.dart';

import 'vue_data.dart';
import 'vue_methods.dart';
import 'vue_props.dart';

/// Vue2风格的Flutter组件基类
abstract class VueComponent extends StatefulWidget {
  final Map<String, dynamic>? props;
  
  const VueComponent({super.key, this.props});
  
  @override
  State<VueComponent> createState() => _VueComponentState();
  
  /// 定义初始data
  Map<String, dynamic> data() => {};
  
  /// 定义methods
  Map<String, Function> methods() => {};
  
  /// 定义props
  Map<String, PropDefinition> propsDefinition() => {};
  
  /// 构建组件UI
  Widget build(BuildContext context, VueComponentInstance instance);
}

class _VueComponentState extends State<VueComponent> {
  late VueComponentInstance instance;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化Vue组件实例
    instance = VueComponentInstance();
    
    // 设置props
    if (widget.propsDefinition().isNotEmpty) {
      instance.props.defineAll(widget.propsDefinition());
      if (widget.props != null) {
        instance.props.setProps(widget.props!);
      }
    }
    
    // 初始化data
    instance.data.initData(widget.data());
    
    // 注册methods
    instance.methods.registerAll(widget.methods());
    
    // 监听data变化
    instance.data.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  void didUpdateWidget(VueComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 更新props
    if (widget.props != null && widget.props != oldWidget.props) {
      instance.props.setProps(widget.props!);
    }
  }
  
  @override
  void dispose() {
    instance.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.build(context, instance);
  }
}

/// Vue组件实例，包含data、methods、props的访问器
class VueComponentInstance {
  late final VueData data;
  late final VueMethods methods;
  late final VueProps props;
  
  VueComponentInstance() {
    data = VueData();
    methods = VueMethods(data);
    props = VueProps();
  }
  
  void dispose() {
    data.dispose();
  }
}

/// 便捷的Vue组件创建函数
class Vue {
  /// 创建一个简单的Vue风格组件
  static Widget component({
    Map<String, dynamic>? initialData,
    Map<String, Function>? methods,
    Map<String, PropDefinition>? propsDefinition,
    Map<String, dynamic>? props,
    required Widget Function(VueComponentInstance instance) builder,
  }) {
    return _SimpleVueComponent(
      initialData: initialData ?? {},
      methodsMap: methods ?? {},
      propsDefinition: propsDefinition ?? {},
      props: props,
      builder: builder,
    );
  }
}

class _SimpleVueComponent extends VueComponent {
  final Map<String, dynamic> initialData;
  final Map<String, Function> methodsMap;
  final Map<String, PropDefinition> _propsDefinition;
  final Widget Function(VueComponentInstance instance) builder;
  
  const _SimpleVueComponent({
    required this.initialData,
    required this.methodsMap,
    required Map<String, PropDefinition> propsDefinition,
    required this.builder,
    super.props,
  }) : _propsDefinition = propsDefinition;
  
  @override
  Map<String, dynamic> data() => initialData;
  
  @override
  Map<String, Function> methods() => methodsMap;
  
  @override
  Map<String, PropDefinition> propsDefinition() => _propsDefinition;
  
  @override
  Widget build(BuildContext context, VueComponentInstance instance) {
    return builder(instance);
  }
}

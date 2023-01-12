import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bubble_demo/dynamic_page.dart';
import 'package:flutter_bubble_demo/global.dart';
import 'package:flutter_bubble_demo/new_feature_bubble.dart';
import 'package:flutter_bubble_demo/normal_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      /// 因为是利用页面路由变化来触发气泡的消失，所以需要加这个路由订阅处理
      navigatorObservers: [
        NewFeatureRouteObserver.instance,
      ],
      routes: {
        '/normal_page': (context) => const NormalPage(),
        '/dynamic_page': (context) => const DynamicPage(),
      },
      // 这是修复桌面版flutter应用不能用鼠标拖动屏幕的问题，不用管
      scrollBehavior: MyCustomScrollBehavior(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NormalPage(),
                ),
              ),
              child: const Text('Normal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DynamicPage(),
                ),
              ),
              child: const Text('Dynamic'),
            ),
            TextButton(
              onPressed: G.clear,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

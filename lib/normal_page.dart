import 'package:flutter/material.dart';
import 'package:flutter_bubble_demo/new_feature_bubble.dart';

class NormalPage extends StatelessWidget {
  const NormalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Normal Demo'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 100,
            top: 200,
            child: NewFeatureBubble(
              featureId: '1',
              featureDescription: '我在左上区\n我不受弹窗影响',
              hideWhenDialogShown: false,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Click me'),
              ),
            ),
          ),
          Positioned(
            right: 100,
            top: 200,
            child: NewFeatureBubble(
              featureId: '2',
              featureDescription: '我在右上区',
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Click me'),
              ),
            ),
          ),
          Positioned(
            left: 100,
            bottom: 200,
            child: NewFeatureBubble(
              featureId: '3',
              featureDescription: '我在左下区',
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const AlertDialog(
                      title: Text('测试弹窗'),
                    ),
                  );
                },
                child: const Text('测试弹窗'),
              ),
            ),
          ),
          Positioned(
            right: 240,
            bottom: 200,
            child: NewFeatureBubble(
              featureId: '4',
              featureDescription: '我在右下区\n但是就想让气泡在我下面',
              forceAlignment: PositionAlignment.topLeft,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Click me'),
              ),
            ),
          ),
          Builder(builder: (context) {
            var left = 500.0;
            var top = 500.0;
            return StatefulBuilder(builder: (context, setState) {
              return Positioned(
                left: left,
                top: top,
                child: Draggable(
                  onDragEnd: (details) {
                    setState(() {
                      left = details.offset.dx;
                      top = details.offset.dy;
                    });
                  },
                  feedback: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Click me'),
                  ),
                  child: NewFeatureBubble(
                    featureId: '5',
                    featureDescription: '这个按钮可以拖动哦',
                    dynamicFollow: true,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Click me'),
                    ),
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}

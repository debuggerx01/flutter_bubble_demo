import 'package:flutter/material.dart';
import 'package:flutter_bubble_demo/new_feature_bubble.dart';

class DynamicPage extends StatelessWidget {
  const DynamicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Demo'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1.5,
          child: ListView.builder(
            itemBuilder: (context, index) => SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('$index'),
                  index == 25
                      ? NewFeatureBubble(
                          featureId: '6',
                          featureDescription: '拖动屏幕\n我会一直在"25"的周围',
                          dynamicFollow: true,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('$index'),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/normal_page');
                          },
                          child: Text('$index'),
                        ),
                  Text('$index'),
                ],
              ),
            ),
            itemCount: 100,
          ),
        ),
      ),
    );
  }
}

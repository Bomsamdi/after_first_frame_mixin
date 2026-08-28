import 'dart:async';

import 'package:after_first_frame_mixin/after_first_frame_mixin.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

@immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'after_first_frame_mixin example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}

@immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AfterFirstFrameMixin<HomeScreen> {
  double _boxWidth = 120;
  Size? _measured;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('after_first_frame_mixin')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('hasRenderedFirstFrame: $hasRenderedFirstFrame'),
            const SizedBox(height: 24),

            // 2. The widget form, for subtrees that are not stateful.
            AfterFirstFrame(
              onFirstFrame: (BuildContext context) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AfterFirstFrame widget ran')),
                  ),
              child: const Text('AfterFirstFrame wraps this text'),
            ),
            const SizedBox(height: 24),

            // 3. afterNextFrame: measure a layout that setState just changed.
            SizedBox(
              key: _boxKey,
              width: _boxWidth,
              height: 48,
              child: const ColoredBox(color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              _measured == null
                  ? 'not measured yet'
                  : 'measured after next frame: '
                        '${_measured!.width.toStringAsFixed(0)} x '
                        '${_measured!.height.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _growAndMeasure,
              child: const Text('Grow, then measure after next frame'),
            ),
          ],
        ),
      ),
    );
  }

  final GlobalKey _boxKey = GlobalKey();

  void _growAndMeasure() {
    setState(() => _boxWidth += 40);
    // The new size only exists once the frame has been laid out.
    afterNextFrame((_) {
      final RenderBox? box =
          _boxKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) setState(() => _measured = box.size);
    });
  }

  void showHelloWorld() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Hello World'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('DISMISS'),
            ),
          ],
        );
      },
    );
  }

  // 1. The mixin: a context that is already laid out, so a dialog can be shown.
  @override
  FutureOr<void> afterFirstFrame(BuildContext context) {
    showHelloWorld();
  }
}

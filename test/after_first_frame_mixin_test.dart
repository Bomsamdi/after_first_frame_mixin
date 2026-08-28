import 'dart:async';

import 'package:after_first_frame_mixin/after_first_frame_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what happened, so tests can assert on order and count.
final List<String> log = <String>[];

class _Host extends StatefulWidget {
  const _Host({required this.onFirstFrame, this.onBuild});

  final AfterFrameCallback onFirstFrame;
  final void Function(_HostState state)? onBuild;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> with AfterFirstFrameMixin<_Host> {
  @override
  Widget build(BuildContext context) {
    widget.onBuild?.call(this);
    return const SizedBox(width: 100, height: 100);
  }

  @override
  FutureOr<void> afterFirstFrame(BuildContext context) =>
      widget.onFirstFrame(context);
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(log.clear);

  group('AfterFirstFrameMixin', () {
    testWidgets('runs after the first frame', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(_Host(onFirstFrame: (_) => log.add('after'))),
      );

      expect(log, <String>['after']);
    });

    testWidgets('runs after build, not during it', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          _Host(
            onBuild: (_) => log.add('build'),
            onFirstFrame: (_) => log.add('after'),
          ),
        ),
      );

      expect(log.first, 'build');
      expect(log.last, 'after');
    });

    testWidgets('runs exactly once across rebuilds', (
      WidgetTester tester,
    ) async {
      Widget host() => _app(_Host(onFirstFrame: (_) => log.add('after')));

      await tester.pumpWidget(host());
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(host());
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(log, <String>['after']);
    });

    testWidgets('gets a laid out context, so it can show a dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _Host(
            onFirstFrame: (BuildContext context) => showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(content: Text('Hello World')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('hasRenderedFirstFrame flips only after the frame', (
      WidgetTester tester,
    ) async {
      late _HostState state;
      await tester.pumpWidget(
        _app(
          _Host(
            onBuild: (_HostState s) {
              state = s;
              log.add('build:${s.hasRenderedFirstFrame}');
            },
            onFirstFrame: (_) => log.add('after'),
          ),
        ),
      );

      expect(log.first, 'build:false');
      expect(state.hasRenderedFirstFrame, isTrue);
    });
  });

  group('afterNextFrame', () {
    testWidgets('runs after a later frame', (WidgetTester tester) async {
      late _HostState state;
      await tester.pumpWidget(
        _app(
          _Host(
            onBuild: (_HostState s) => state = s,
            onFirstFrame: (_) => log.add('first'),
          ),
        ),
      );
      log.clear();

      state.afterNextFrame((_) => log.add('next'));
      expect(log, isEmpty, reason: 'must not run synchronously');

      await tester.pump();
      expect(log, <String>['next']);
    });

    testWidgets('does not run once the widget is gone', (
      WidgetTester tester,
    ) async {
      late _HostState state;
      await tester.pumpWidget(
        _app(_Host(onBuild: (_HostState s) => state = s, onFirstFrame: (_) {})),
      );

      state.afterNextFrame((_) => log.add('next'));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));

      expect(log, isEmpty);
    });

    testWidgets('can be scheduled more than once', (WidgetTester tester) async {
      late _HostState state;
      await tester.pumpWidget(
        _app(_Host(onBuild: (_HostState s) => state = s, onFirstFrame: (_) {})),
      );

      state
        ..afterNextFrame((_) => log.add('a'))
        ..afterNextFrame((_) => log.add('b'));
      await tester.pump();

      expect(log, <String>['a', 'b']);
    });
  });

  group('error reporting', () {
    testWidgets('a synchronous error is reported through FlutterError', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(_Host(onFirstFrame: (_) => throw StateError('sync boom'))),
      );

      expect(tester.takeException(), isStateError);
    });

    testWidgets('an asynchronous error is reported through FlutterError', (
      WidgetTester tester,
    ) async {
      // Regression: the returned Future was dropped, so its error escaped as
      // an unhandled asynchronous error instead of reaching FlutterError.
      await tester.pumpWidget(
        _app(_Host(onFirstFrame: (_) async => throw StateError('async boom'))),
      );
      await tester.pump();

      expect(tester.takeException(), isStateError);
    });
  });

  group('AfterFirstFrame widget', () {
    testWidgets('renders its child and runs the callback once', (
      WidgetTester tester,
    ) async {
      Widget host() => _app(
        AfterFirstFrame(
          onFirstFrame: (_) => log.add('after'),
          child: const Text('child'),
        ),
      );

      await tester.pumpWidget(host());
      expect(find.text('child'), findsOneWidget);
      expect(log, <String>['after']);

      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 20));
      expect(log, <String>['after']);
    });

    testWidgets('gets a context that can reach inherited widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          AfterFirstFrame(
            onFirstFrame: (BuildContext context) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Ready'))),
            child: const Text('child'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('reports callback errors through FlutterError', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          AfterFirstFrame(
            onFirstFrame: (_) async => throw StateError('widget boom'),
            child: const SizedBox(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isStateError);
    });
  });
}

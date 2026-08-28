import 'package:flutter/widgets.dart';

import 'after_frame.dart';
import 'after_first_frame_mixin.dart';

/// Runs [onFirstFrame] after the first frame of its subtree has been
/// displayed, without requiring the surrounding widget to be stateful.
///
/// This is the widget form of [AfterFirstFrameMixin], for cases where turning a
/// [StatelessWidget] into a [StatefulWidget] just to reach the first frame
/// would be the only reason to do so.
///
/// ### Example
///
/// ```dart
/// AfterFirstFrame(
///   onFirstFrame: (BuildContext context) => ScaffoldMessenger.of(context)
///       .showSnackBar(const SnackBar(content: Text('Ready'))),
///   child: const HomeBody(),
/// )
/// ```
class AfterFirstFrame extends StatefulWidget {
  const AfterFirstFrame({
    super.key,
    required this.onFirstFrame,
    required this.child,
  });

  /// Called once, after the first frame of [child] has been displayed.
  ///
  /// Errors are reported through [FlutterError.reportError].
  final AfterFrameCallback onFirstFrame;

  /// The subtree whose first frame is awaited.
  final Widget child;

  @override
  State<AfterFirstFrame> createState() => _AfterFirstFrameState();
}

class _AfterFirstFrameState extends State<AfterFirstFrame> {
  @override
  void initState() {
    super.initState();
    // Reads widget.onFirstFrame when the frame is done, so a rebuild before
    // the first frame still runs the callback the caller last provided.
    runAfterFrame(this, (BuildContext context) => widget.onFirstFrame(context));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

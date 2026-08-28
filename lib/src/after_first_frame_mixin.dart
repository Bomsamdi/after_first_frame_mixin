import 'dart:async';

import 'package:flutter/widgets.dart';

import 'after_frame.dart';

/// Runs code after the first layout of a widget has been performed, i.e. after
/// the first frame has been displayed.
///
/// Unlike `initState`, the callback receives a [BuildContext] that is already
/// laid out, so it can show dialogs and route transitions, read a
/// [MediaQuery] or measure a [RenderBox].
///
/// ### Example
///
/// ```dart
/// class HomeScreenState extends State<HomeScreen>
///     with AfterFirstFrameMixin<HomeScreen> {
///   @override
///   Widget build(BuildContext context) => const Center(child: Text('Example'));
///
///   @override
///   FutureOr<void> afterFirstFrame(BuildContext context) {
///     showDialog<void>(
///       context: context,
///       builder: (BuildContext context) =>
///           const AlertDialog(content: Text('Hello World')),
///     );
///   }
/// }
/// ```
mixin AfterFirstFrameMixin<T extends StatefulWidget> on State<T> {
  bool _hasRenderedFirstFrame = false;

  /// Whether the first frame of this widget has been displayed, i.e. whether
  /// [afterFirstFrame] has been reached.
  ///
  /// Useful for code that runs both before and after the first frame and has
  /// to tell the two apart.
  bool get hasRenderedFirstFrame => _hasRenderedFirstFrame;

  @override
  void initState() {
    super.initState();
    runAfterFrame(this, (BuildContext context) {
      _hasRenderedFirstFrame = true;
      return afterFirstFrame(context);
    });
  }

  /// Runs [callback] after the next frame has been displayed, if this [State]
  /// is still mounted by then.
  ///
  /// Can be called at any point in the widget's life, which makes it the
  /// counterpart of [afterFirstFrame] for later frames - for instance to
  /// measure a layout that a `setState` has just changed. A frame is scheduled
  /// if none is pending.
  ///
  /// Errors are reported through [FlutterError.reportError].
  void afterNextFrame(AfterFrameCallback callback) =>
      runAfterFrame(this, callback);

  /// Called once, after the first frame of this widget has been displayed.
  ///
  /// Returning a [Future] is supported; errors from it are reported through
  /// [FlutterError.reportError].
  FutureOr<void> afterFirstFrame(BuildContext context);
}

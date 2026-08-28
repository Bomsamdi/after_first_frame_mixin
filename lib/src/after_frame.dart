import 'dart:async';

import 'package:flutter/widgets.dart';

/// Signature of a callback run after a frame has been displayed.
typedef AfterFrameCallback = FutureOr<void> Function(BuildContext context);

/// Runs [callback] once the current or next frame has been displayed, provided
/// [state] is still mounted by then.
///
/// Errors thrown by [callback] - including those from an asynchronous
/// implementation - are reported through [FlutterError.reportError] rather than
/// escaping as unhandled asynchronous errors.
void runAfterFrame(State<StatefulWidget> state, AfterFrameCallback callback) {
  // endOfFrame schedules a frame if none is pending, so this also fires when
  // called between frames.
  WidgetsBinding.instance.endOfFrame.then((_) {
    if (!state.mounted) return;
    _guard(() => callback(state.context));
  });
}

void _guard(FutureOr<void> Function() body) {
  try {
    final FutureOr<void> result = body();
    if (result is Future<void>) {
      result.catchError(_report);
    }
  } catch (error, stack) {
    _report(error, stack);
  }
}

void _report(Object error, StackTrace stack) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'after_first_frame_mixin',
      context: ErrorDescription('while running an after-frame callback'),
    ),
  );
}

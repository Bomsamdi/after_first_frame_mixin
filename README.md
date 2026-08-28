# after_first_frame_mixin

[![Pub Version](https://img.shields.io/pub/v/after_first_frame_mixin)](https://pub.dev/packages/after_first_frame_mixin)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![pub points](https://img.shields.io/pub/points/after_first_frame_mixin)](https://pub.dev/packages/after_first_frame_mixin/score)

Run code after the first layout of a widget has been performed, i.e. after the
first frame has been displayed.

`initState` runs before layout, so the context it sees has no size, no route
transition in place and no `Scaffold` to show a snack bar in. This package gives
you a callback that runs once the frame is on screen, as a **mixin** or as a
**widget**.

## Installation

```yaml
dependencies:
  after_first_frame_mixin: ^1.0.0
```

Requires Dart 3.8 / Flutter 3.32 or newer.

## Usage

### As a mixin

```dart
class HomeScreenState extends State<HomeScreen>
    with AfterFirstFrameMixin<HomeScreen> {
  @override
  Widget build(BuildContext context) => const Center(child: Text('Example'));

  @override
  FutureOr<void> afterFirstFrame(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          const AlertDialog(content: Text('Hello World')),
    );
  }
}
```

### As a widget

For a subtree that would otherwise have no reason to be stateful:

```dart
AfterFirstFrame(
  onFirstFrame: (BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Ready'))),
  child: const HomeBody(),
)
```

### Later frames

`afterNextFrame` is the counterpart for everything after the first frame — for
instance to measure a layout that a `setState` has just changed. It can be
called at any point in the widget's life and schedules a frame if none is
pending.

```dart
void _grow() {
  setState(() => _width += 40);
  afterNextFrame((_) {
    final RenderBox box = _key.currentContext!.findRenderObject()! as RenderBox;
    setState(() => _measured = box.size);
  });
}
```

`hasRenderedFirstFrame` tells you which side of the first frame you are on:

```dart
if (hasRenderedFirstFrame) {
  // safe to touch layout-dependent things
}
```

## API

| Member | Description |
|---|---|
| `AfterFirstFrameMixin<T>` | Mixin on `State<T>`. Implement `afterFirstFrame`. |
| `afterFirstFrame(BuildContext)` | Called once, after the first frame. May return a `Future`. |
| `afterNextFrame(callback)` | Runs `callback` after the next frame. Callable at any time. |
| `hasRenderedFirstFrame` | Whether the first frame has been displayed. |
| `AfterFirstFrame` | Widget form: `onFirstFrame` + `child`. |
| `AfterFrameCallback` | `FutureOr<void> Function(BuildContext context)`. |

## Notes

- Callbacks never run after the `State` has been unmounted.
- Errors — including those thrown by an asynchronous callback — are reported
  through `FlutterError.reportError`, so they reach `FlutterError.onError` and
  `tester.takeException()` instead of escaping as unhandled async errors.
- Scheduling relies on `WidgetsBinding.instance.endOfFrame`. If the device
  screen is off, frames are not produced and the callback waits.

## Example

A runnable app demonstrating all three APIs is in the `/example` folder.

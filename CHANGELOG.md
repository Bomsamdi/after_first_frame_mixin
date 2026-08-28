## 1.0.0

### Added

* `AfterFirstFrame` widget - the widget form of the mixin, for subtrees that
  would otherwise have no reason to be stateful.
* `afterNextFrame(callback)` on the mixin - the counterpart of
  `afterFirstFrame` for later frames, callable at any point in the widget's
  life, e.g. to measure a layout a `setState` has just changed.
* `hasRenderedFirstFrame` - whether the first frame has been displayed.
* `AfterFrameCallback` typedef for the callback signature.

### Fixed

* Errors thrown by an asynchronous `afterFirstFrame` are reported through
  `FlutterError.reportError`. The returned `Future` used to be dropped, so its
  error escaped as an unhandled asynchronous error, without widget diagnostics
  and out of reach of `FlutterError.onError` and `tester.takeException()`.

### Other

* Requires Dart 3.8 / Flutter 3.32; `flutter_lints` 6.
* First test suite: 13 tests covering both APIs, the mounted guard and error
  reporting. The package previously shipped an empty test.
* IDE files (`.idea/`, `*.iml`) are no longer committed nor published.
* README rewritten: installation, both APIs, an API table and the scheduling
  caveats.

## 0.0.2

* Minor changes.

## 0.0.1

* Initial release.

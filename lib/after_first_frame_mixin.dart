library after_first_frame_mixin;

import 'dart:async';

import 'package:flutter/widgets.dart';

/// This demo showcases how this package resolves the shortcomings shown above:
/// ```dart
/// import 'dart:async';
///
/// import 'package:after_first_frame_mixin/after_first_frame_mixin.dart';
/// import 'package:flutter/material.dart';
///
/// void main() => runApp(const MyApp());
///
/// @immutable
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return const MaterialApp(
///       title: 'Example',
///       home: HomeScreen(),
///     );
///   }
/// }
///
/// @immutable
/// class HomeScreen extends StatefulWidget {
///   const HomeScreen({Key? key}) : super(key: key);
///
///   @override
///   HomeScreenState createState() => HomeScreenState();
/// }
///
/// class HomeScreenState extends State<HomeScreen>
///     with AfterFirstFrameMixin<HomeScreen> {
///   @override
///   Widget build(BuildContext context) {
///    return Scaffold(
///      body: Container(
///        child: const Center(
///          child: Text("Example"),
///        ),
///      ),
///    );
///   }
///
///   void showHelloWorld() {
///     showDialog(
///       context: context,
///       builder: (BuildContext context) {
///         return AlertDialog(
///           content: const Text('Hello World'),
///           actions: <Widget>[
///             TextButton(
///               onPressed: () => Navigator.of(context).pop(),
///               child: const Text('DISMISS'),
///             )
///           ],
///         );
///       },
///     );
///   }
///
///   @override
///   FutureOr<void> afterFirstFrame(BuildContext context) {
///     showHelloWorld();
///   }
/// }
/// ```
mixin AfterFirstFrameMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) afterFirstFrame(context);
      },
    );
  }

  FutureOr<void> afterFirstFrame(BuildContext context);
}

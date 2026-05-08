import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.safeArea = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = safeArea ? SafeArea(child: body) : body;

    return Scaffold(
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}

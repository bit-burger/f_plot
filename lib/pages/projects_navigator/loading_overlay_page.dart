import 'package:flutter/material.dart';

class LoadingOverlayPage extends Page {
  const LoadingOverlayPage({super.key, super.name});

  @override
  Route createRoute(BuildContext context) {
    return DialogRoute(
      context: context,
      settings: this,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );
  }
}

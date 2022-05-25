import 'package:flutter/material.dart';

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 512,
        child: LinearProgressIndicator(backgroundColor: Colors.transparent),
      ),
    );
  }
}

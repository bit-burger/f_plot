import 'package:flutter/material.dart';

class ProjectLoadingOverlay extends StatelessWidget {
  const ProjectLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withAlpha(100),
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

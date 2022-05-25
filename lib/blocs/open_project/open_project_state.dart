part of 'open_project_cubit.dart';

@immutable
class OpenProjectState {
  final bool isLoading;
  final Project? openProject;

  bool get projectIsOpen => openProject != null;

  const OpenProjectState({
    this.isLoading = false,
    this.openProject,
  });

  factory OpenProjectState.initial() {
    return const OpenProjectState();
  }

  OpenProjectState copyWith({
    bool? isLoading,
    Project? openProject,
  }) {
    return OpenProjectState(
      isLoading: isLoading ?? this.isLoading,
      openProject: openProject ?? this.openProject,
    );
  }

  @override
  String toString() {
    return 'OpenProjectState{isLoading: $isLoading, openProject: $openProject}';
  }
}

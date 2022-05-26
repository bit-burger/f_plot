part of 'open_project_cubit.dart';

enum ProjectStatus {
  /// project is being opened
  opening,

  /// project is opened and the current project in memory has already been saved
  saved,

  /// project is opened
  /// and the current project in memory is being saved right now
  saving,

  /// project is opened and the current project in memory is has not been saved
  unsaved,

  /// project currently is opened and is currently being deleted,
  /// after deletion is finished it will be closed
  deleting,
}

/// the state of [OpenProjectCubit], shows if a [Project] is opened by the user
/// and its current state, e.g. is it being opened or is it already opened,
/// is it saved or is it currently being saved, etc.
@immutable
class OpenProjectState {
  /// the status of a project that the user opens, see [ProjectStatus]
  ///
  /// if [status] is null, [openProject] should also be null,
  /// as then nothing is happening, if [openProject] is not null,
  /// [status] should also be not null,
  /// as the [openProject] should have a status
  final ProjectStatus? status;

  /// if null no project is currently open,
  /// if not null [openProject] is the state of the currently open project.
  ///
  /// depending on [status] it is either saved or not saved
  final Project? openProject;

  /// if a project is currently being opened
  /// or if the opened project is currently being deleted
  ///
  /// is useful for knowing if any kind of global loader should be shown,
  /// as the opening or deleting opens or closes a page
  bool get openingOrDeleting =>
      status == ProjectStatus.opening || status == ProjectStatus.deleting;

  /// if a [Project] is open, independent from a pending deletion of the project
  /// or the pending opening of another project
  bool get projectIsOpen => openProject != null;

  const OpenProjectState({
    this.status,
    this.openProject,
  });

  factory OpenProjectState.initial() {
    return const OpenProjectState();
  }

  OpenProjectState copyWith({
    ProjectStatus? status,
    Project? openProject,
  }) {
    return OpenProjectState(
      status: status ?? this.status,
      openProject: openProject ?? this.openProject,
    );
  }
}

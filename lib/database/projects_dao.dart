import "package:f_plot/domain/project.dart";
import "package:sqflite/sqflite.dart";

import '../domain/project_listing.dart';

class ProjectsDao {
  final String dbPath;
  late final Database db;

  ProjectsDao({required this.dbPath});

  Future<void> _initSchema(Database db) async {
    await db.execute("create table projects("
        "  id integer primary key autoincrement,"
        "  name varchar not null,"
        "  plot_file varchar not null default '',"
        "  created_at timestamp not null"
        "    default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))"
        ")");
    // TODO: create example project
  }

  Future<void> initDB() async {
    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => _initSchema(db),
    );
  }

  Future<List<ProjectListing>> getProjects() async {
    final result = await db.query(
      "projects",
      columns: ["id", "name", "created_at"],
      orderBy: "name",
    );
    return result
        .map((json) => ProjectListing.fromJson(json))
        .toList(growable: false);
  }

  Future<Project> getProject(int projectId) async {
    final result = await db.query(
      "projects",
      columns: ["id", "name", "created_at", "plot_file"],
      limit: 1,
    );
    return Project.fromJson(result[0]);
  }

  Future<ProjectListing> newProject(String name) async {
    final result = await db.rawQuery(
      "insert into projects(name) values (?) "
      "returning id, name, created_at",
      [name],
    );
    return ProjectListing.fromJson(result.first);
  }

  Future<void> editProjectName(int projectId, String name) async {
    await db.update(
      "projects",
      {"name": name},
      where: "id = ?",
      whereArgs: [projectId],
    );
  }

  Future<void> deleteProject(int projectId) async {
    await db.delete(
      "projects",
      where: "id = ?",
      whereArgs: [projectId],
    );
  }

  Future<void> editProjectPlotFile(
    int projectId,
    String plotFile,
  ) async {
    await db.update(
      "projects",
      {"plot_file": plotFile},
      where: "id = ?",
      whereArgs: [projectId],
    );
  }
}

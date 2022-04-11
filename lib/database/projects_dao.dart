import "package:f_plot/domain/project.dart";
import "package:sqflite/sqflite.dart";

class ProjectsDao {
  final String dbPath;
  late final Database db;

  ProjectsDao({required this.dbPath});

  Future<void> initSchema(Database db) async {
    await db.execute("create table projects("
        "  id integer primary key autoincrement,"
        "  name varchar not null,"
        "  math_functions varchar not null default '',"
        "  created_at timestamp not null"
        "    default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))"
        ")");
    // TODO: create example project
  }

  Future<void> initDB() async {
    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => initSchema(db),
    );
  }

  Future<List<Project>> getProjects() async {
    final result = await db.query(
      "projects",
      columns: ["id", "name", "created_at"],
      orderBy: "name",
    );
    return result.map((json) => Project.fromJson(json)).toList(growable: false);
  }

  Future<Project> newProject(String name) async {
    final result = await db.rawQuery(
      "insert into projects(name) values (?) "
      "returning id, name, created_at",
      [name],
    );
    return Project.fromJson(result.first);
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

  Future<String> getMathFunctionsFromProject(int projectId) async {
    final result = await db.query(
      "projects",
      columns: ["math_functions"],
      where: "id = ?",
      whereArgs: [projectId],
    );
    return result.first["math_functions"]! as String;
  }

  Future<void> saveMathFunctionsToProject(
    int projectId,
    String mathFunctions,
  ) async {
    await db.update(
      "projects",
      {"math_functions": mathFunctions},
      where: "id = ?",
      whereArgs: [projectId],
    );
  }
}

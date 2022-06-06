import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/f_plot.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart' as window;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  final dbDirPath = await getDatabasesPath();
  final dbPath = "$dbDirPath/db.sqlite3";
  final projectsDao = ProjectsDao(dbPath: dbPath);

  await projectsDao.initDB();

  runApp(
    FPlot(projectsDao: projectsDao),
  );

  window.doWhenWindowReady(() {
    window.appWindow.minSize = const Size(1500, 1000);
    window.appWindow.size = const Size(1500, 1000);
    window.appWindow.show();
    window.appWindow.title = "F Plot";
  });
}

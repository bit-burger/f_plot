import 'package:flutter_plotter/database/projects_dao.dart';
import 'package:flutter_plotter/f_plot.dart';
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
  window.appWindow.size = const Size(1200, 800);
  window.appWindow.minSize = const Size(900, 600);
  window.appWindow.show();
  window.appWindow.title = "flutter plotter";

  // window.doWhenWindowReady(() {
  //   window.appWindow.size = const Size(1200, 800);
  //   window.appWindow.show();
  //   window.appWindow.title = "F Plot";
  // });
}

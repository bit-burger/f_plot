import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/f_plot.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  WidgetsFlutterBinding.ensureInitialized();

  final dbDirPath = await getDatabasesPath();
  final dbPath = "$dbDirPath/db.sqlite3";
  final projectsDao = ProjectsDao(dbPath: dbPath);

  await projectsDao.initDB();

  runApp(
    FPlot(projectsDao: projectsDao),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_code_field/math_code_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _errors = [
    CodeError(begin: 3, message: "first"),
    CodeError(begin: 3, end: 5, message: "second"),
    CodeError(begin: 8, end: 20, message: "third"),
  ];
  var errorsOn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MathCodeField"),
      ),
      body: MathCodeField(
        monoTextTheme: GoogleFonts.jetBrainsMonoTextTheme(),
        codeErrors: errorsOn ? _errors : [],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.error_outline_sharp),
        onPressed: () {
          setState((){
            errorsOn = !errorsOn;
          });
        },
      ),
    );
  }
}

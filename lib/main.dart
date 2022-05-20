import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:function_tree/function_tree.dart' show StringMethods;
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_math_fork/flutter_math.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MathFieldEditingController controller = new MathFieldEditingController();

  @override
  Widget build(BuildContext context) {
    // final e = Parser().parse("0.");
    final e = Parser().parse("(4)*(1)");
    final evl = e.evaluate(EvaluationType.REAL,
        ContextModel()..bindVariable(Variable("y"), Number(2)));
    print("evl:" + evl.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("f_plot"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableMath.tex(r'\frac a b',
                textStyle: TextStyle(fontSize: 42)),
            MathField(
              keyboardType: MathKeyboardType.expression,
              variables: const ['x'],
              onChanged: (s) {
                try {
                  final Expression b = TeXParser(s).parse();
                  final context = ContextModel()
                    ..bindVariable(Variable('x'), Number(2));
                  print('eval;:,' +
                      b.evaluate(EvaluationType.REAL, context).toString());
                } catch (e) {
                  print("error: $e");
                }
                print(s);
              },
              autofocus: true,
              controller: controller,
            ),
            Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

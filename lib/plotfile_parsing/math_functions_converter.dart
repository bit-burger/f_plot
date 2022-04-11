import 'package:f_plot/domain/math_function.dart';

class MathFunctionsConverter {
  final List<MathFunction> functions;

  MathFunctionsConverter(this.functions);

  String convert() => functions
      .map(
        (function) => "${function.name}(${function.arguments.join(",")})"
            "=${function.body}",
      )
      .join("\n" * 2);
}

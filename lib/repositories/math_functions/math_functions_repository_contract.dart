import 'package:f_plot/domain/math_function.dart';

abstract class IMathFunctionsRepository {
  Future<List<MathFunction>> getFunction(int projectId);
  Future<void> saveFunctions(int projectId, List<MathFunction> functions);
}

import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/domain/math_function.dart';
import 'package:f_plot/plotfile_parsing/math_functions_converter.dart';
import 'package:f_plot/plotfile_parsing/plotfile_parser.dart';

import 'math_functions_repository_contract.dart';

class MathFunctionsRepository implements IMathFunctionsRepository {
  final ProjectsDao dao;

  MathFunctionsRepository(this.dao);

  @override
  Future<List<MathFunction>> getFunction(int projectId) async {
    final rawMathFunctions = await dao.getMathFunctionsFromProject(projectId);
    final parser = PlotfileParser(rawMathFunctions);
    return parser.parse();
  }

  @override
  Future<void> saveFunctions(
    int projectId,
    List<MathFunction> functions,
  ) async {
    final converter = MathFunctionsConverter(functions);
    final functionsAsString = converter.convert();
    await dao.saveMathFunctionsToProject(projectId, functionsAsString);
  }
}

import 'package:evaluator/evaluator.dart';
import 'package:expressions/expressions.dart';
import 'package:plot_file/src/raw_plot_file_parser/raw_plot_file_parser.dart';
import 'package:math_functions/math_functions.dart';

part 'parsing_context.dart';
part 'cached_declarations.dart';

// TODO: multiple errors possible
class CachedPlotFileParser {
  final Map<String, CachedFunctionDeclaration> functions;
  final Map<String, CachedVariableDeclaration> variables;
  final StringExpressionParser _stringExpressionParser;
  final bool _createEvaluatingFunctionsForSingleVariableFunction;
  List<StringExpressionParseError> errors;

  CachedPlotFileParser({
    StringExpressionParserOptions? expressionParserOptions,
    EvaluatorContext evaluatorContext = const EvaluatorContext(),
    bool createEvaluatingFunctionsForSingleVariableFunction = true,
  })  : _stringExpressionParser = StringExpressionParser(
          options: expressionParserOptions,
        ),
        _createEvaluatingFunctionsForSingleVariableFunction =
            createEvaluatingFunctionsForSingleVariableFunction,
        errors = [],
        functions = {},
        variables = {};

  void parseAndCache(String plotFile) {
    _setAllDeclarationsToNotFound();
    errors.clear();
    RawPlotFileParser multipleParserContext = RawPlotFileParser(
      stringExpressionParser: _stringExpressionParser,
    );
    multipleParserContext.parsePlotFile(plotFile);
    if (multipleParserContext.parseErrors.isNotEmpty) {
      errors = multipleParserContext.parseErrors;
      //return; // problem removing return:
      // MultipleParserContext already checks
      // for things that concern multiple declarations,
      // such as that every declaration is unique
    }
    var currentVariableOrder = 0;
    var currentFunctionOrder = 0;
    final parsingContext = _ParsingContext();
    for (final rawDeclaration in multipleParserContext.declarations) {
      try {
        final identifier = rawDeclaration.identifier;
        var cachedDeclaration = _getCachedDeclaration(identifier);
        var cachedDeclarationDeleted =
            false; // if the declaration is in the cache
        if (cachedDeclaration != null) {
          final isChanged = _rawDeclarationCheckCacheIsChanged(
            rawDeclaration,
            cachedDeclaration,
          );
          if (isChanged) {
            _deleteDeclaration(identifier);
            cachedDeclarationDeleted = true;
            cachedDeclaration =
                _newCachedDeclaration(plotFile, rawDeclaration, parsingContext);
          } else {
            cachedDeclaration.status = CachedDeclarationStatus.found;
          }
        } else {
          cachedDeclaration =
              _newCachedDeclaration(plotFile, rawDeclaration, parsingContext);
          cachedDeclarationDeleted = true;
        }
        // add the declaration to the cache (only if they are new/have changed),
        // add the declaration to the parsing context,
        // set the functions order and update it
        if (cachedDeclaration is CachedFunctionDeclaration) {
          cachedDeclaration.order = currentFunctionOrder++;
          parsingContext.addFunction(identifier, cachedDeclaration);
          if (cachedDeclarationDeleted) {
            functions[identifier] = cachedDeclaration;
          }
        } else if (cachedDeclaration is CachedVariableDeclaration) {
          cachedDeclaration.order = currentVariableOrder++;
          parsingContext.addVariable(identifier, cachedDeclaration);
          if (cachedDeclarationDeleted) {
            variables[identifier] = cachedDeclaration;
          }
        } else {
          throw StateError("declaration should only be of type "
              "CachedVariableDeclaration or CachedFunctionDeclaration");
        }
      } on StringExpressionParseError catch (e) {
        errors.add(e);
        // TODO: maybe return here?
      }
    }
    // remove all functions that have not been found in the plot file
    _removeNonFoundFunctions();
  }

  /// remove not found functions in the cache,
  /// if the [CachedDeclaration.status] is [CachedDeclarationStatus.notFound]
  void _removeNonFoundFunctions() {
    functions.removeWhere(
      (_, declaration) =>
          declaration.status == CachedDeclarationStatus.notFound,
    );
    variables.removeWhere(
      (_, declaration) =>
          declaration.status == CachedDeclarationStatus.notFound,
    );
  }

  /// set all functions as if they have not been found,
  /// is done before parsing, to check if has not been found
  /// (useful in [_removeNonFoundFunctions]
  void _setAllDeclarationsToNotFound() {
    functions.forEach((_, declaration) {
      declaration.status = CachedDeclarationStatus.notFound;
    });

    variables.forEach((_, declaration) {
      declaration.status = CachedDeclarationStatus.notFound;
    });
  }

  /// if a cached function has been
  /// changed/has not been found/is new/was removed in the current parsing
  bool _functionIsChanged(String functionName) {
    final status = functions[functionName]?.status;
    if (status == null || status != CachedDeclarationStatus.found) {
      return true;
    }
    return false;
  }

  /// if a cached variable has been changed/is new/was removed
  /// in the current parsing
  bool _variableIsChanged(String variableName) {
    final status = variables[variableName]?.status;
    if (status == null || status != CachedDeclarationStatus.found) {
      return true;
    }
    return false;
  }

  /// delete a function/variable from the cache
  void _deleteDeclaration(String declaration) {
    functions.removeWhere((name, _) => name == declaration);
    variables.removeWhere((name, _) => name == declaration);
  }

  /// if a declaration in the cache is referencing changed variables/functions.
  ///
  /// see [_variableIsChanged]
  bool _cachedDeclarationReferencingIdentifiersChanged(
      CachedDeclaration cachedDeclaration) {
    for (final variable in cachedDeclaration.variableReferences) {
      if (_variableIsChanged(variable)) {
        return true;
      }
    }
    for (final function in cachedDeclaration.functionReferences) {
      if (_functionIsChanged(function)) {
        return true;
      }
    }
    return false;
  }

  /// get the [CachedDeclaration] with the name [declaration],
  /// if it does not exist, return null
  CachedDeclaration? _getCachedDeclaration(String declaration) =>
      functions[declaration] ?? variables[declaration];

  /// compares a [RawDeclaration] with a [CachedDeclaration],
  /// returns true if it finds a [CachedDeclaration],
  /// with the same name and same parameters.
  ///
  /// returns false if the [RawDeclaration] :
  /// - has a changed declaration type (variable/function)
  /// - the [CachedDeclaration.rawBody] has changed
  /// - it is a [CachedFunctionDeclaration] and the parameters have changed
  /// - the referenced variables/functions have been changed
  bool _rawDeclarationCheckCacheIsChanged(
      RawDeclaration rawDeclaration, CachedDeclaration cachedDeclaration) {
    if (cachedDeclaration is CachedFunctionDeclaration) {
      if (rawDeclaration is RawVariableDeclaration) {
        return true;
      }
      final rawFunction = rawDeclaration as RawFunctionDeclaration;
      if (rawFunction.parameters.length != cachedDeclaration.parameterLength) {
        return true;
      }
      for (var i = 0; i < cachedDeclaration.parameterLength; i++) {
        if (rawFunction.parameters[i] != cachedDeclaration.parameters[i]) {
          return true;
        }
      }
      if (cachedDeclaration.rawBody != rawFunction.body) {
        return true;
      }
      if (_cachedDeclarationReferencingIdentifiersChanged(cachedDeclaration)) {
        return true;
      }
    } else if (cachedDeclaration is CachedVariableDeclaration) {
      if (rawDeclaration is RawFunctionDeclaration) return true;
      final rawVariable = rawDeclaration as RawVariableDeclaration;
      if (rawVariable.body != cachedDeclaration.rawBody) {
        return true;
      }
      if (_cachedDeclarationReferencingIdentifiersChanged(cachedDeclaration)) {
        return true;
      }
    } else {
      throw StateError("declaration should only be of type "
          "CachedVariableDeclaration or CachedFunctionDeclaration");
    }
    return false;
  }

  /// get back a new [CachedVariableDeclaration],
  /// with the [CachedDeclaration.status]
  /// set to [CachedDeclarationStatus.changed].
  ///
  /// uses the [ParsingContext] to parse the [String]
  /// to an callable function (for a function)
  ///
  /// throws [StringExpressionParseError], if a error in the parsing occurs
  CachedDeclaration _newCachedDeclaration(
    String plotFile,
    RawDeclaration rawDeclaration,
    _ParsingContext c,
  ) {
    final rawBody = rawDeclaration.body;
    if (rawDeclaration is RawFunctionDeclaration) {
      final body = _stringExpressionParser.operatorParse(
        plotFile,
        rawDeclaration.bodyStart,
        rawDeclaration.bodyEnd,
        c,
        rawDeclaration.parameters,
      );
      final resolvedBody = body.resolve(c, rawDeclaration.parameters);
      late final EvaluatorFunction? evaluatorFunction;
      if (_createEvaluatingFunctionsForSingleVariableFunction &&
          rawDeclaration.parameters.length == 1) {
        evaluatorFunction = expressionToEvaluatorFunction(resolvedBody, c);
      } else {
        evaluatorFunction = null;
      }
      return CachedFunctionDeclaration(
        parameters: rawDeclaration.parameters,
        body: resolvedBody,
        rawBody: rawBody,
        evaluatorFunction: evaluatorFunction,
        status: CachedDeclarationStatus.changed,
      );
    } else {
      final body = _stringExpressionParser.operatorParse(
        plotFile,
        rawDeclaration.bodyStart,
        rawDeclaration.bodyEnd,
        c,
        const [],
      );
      return CachedVariableDeclaration(
        value: body.resolveToNumber(c),
        rawBody: rawBody,
        status: CachedDeclarationStatus.changed,
      );
    }
  }
}

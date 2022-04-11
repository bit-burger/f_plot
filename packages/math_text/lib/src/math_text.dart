class MathBox {
  List<MathNode> nodes;
}

abstract class MathNode {}

enum OperatorType {
  add,
  subtract,
  multiply,
  divide,
}

class OnLineOperator extends MathNode {
  final OperatorType type;

  OnLineOperator(this.type);
}

class Separator extends MathNode {}


class Character {
  final String text;
}

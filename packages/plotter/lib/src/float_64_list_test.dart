import 'dart:typed_data';

main() {
  final l = Float64List(8);
  l[0] = double.infinity;
  print(l[0]);
}
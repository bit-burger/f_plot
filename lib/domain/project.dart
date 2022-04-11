import "package:json_annotation/json_annotation.dart";

part "project.g.dart";

@JsonSerializable()
class Project {
  final int id;
  final String name;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

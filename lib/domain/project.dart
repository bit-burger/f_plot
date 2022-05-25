import 'package:f_plot/domain/project_listing.dart';
import "package:json_annotation/json_annotation.dart";

part "project.g.dart";

@JsonSerializable(fieldRename: FieldRename.snake)
class Project extends ProjectListing {
  final String plotFile;

  Project({
    required super.id,
    required super.name,
    required super.createdAt,
    required this.plotFile,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

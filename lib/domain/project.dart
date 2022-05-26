import 'package:f_plot/domain/project_listing.dart';
import 'package:flutter/cupertino.dart';
import "package:json_annotation/json_annotation.dart";

part "project.g.dart";

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Project extends ProjectListing {
  final String plotFile;

  const Project({
    required super.id,
    required super.name,
    required super.createdAt,
    required this.plotFile,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

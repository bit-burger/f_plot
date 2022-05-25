import 'package:json_annotation/json_annotation.dart';
part 'project_listing.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectListing {
  final int id;
  final String name;
  final DateTime createdAt;

  const ProjectListing({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ProjectListing.fromJson(Map<String, dynamic> json) =>
      _$ProjectListingFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectListingToJson(this);
}

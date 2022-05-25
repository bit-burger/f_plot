// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectListing _$ProjectListingFromJson(Map<String, dynamic> json) =>
    ProjectListing(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProjectListingToJson(ProjectListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };

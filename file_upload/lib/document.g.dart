// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentImpl _$$DocumentImplFromJson(Map<String, dynamic> json) =>
    _$DocumentImpl(
      id: json['id'] as String?,
      compressedFileSize: json['compressedFileSize'] as int,
      content: json['content'] as String?,
      contentType: json['contentType'] as String,
      created: json['created'] as String,
      errorMessage: json['errorMessage'] as String,
      file: const Uint8ListJsonConverter().fromJson(json['file'] as List),
      name: json['name'] as String,
      originFileSize: json['originFileSize'] as int,
      status: json['status'] as String,
      updated: json['updated'] as String,
    );

Map<String, dynamic> _$$DocumentImplToJson(_$DocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'compressedFileSize': instance.compressedFileSize,
      'content': instance.content,
      'contentType': instance.contentType,
      'created': instance.created,
      'errorMessage': instance.errorMessage,
      'file': const Uint8ListJsonConverter().toJson(instance.file),
      'name': instance.name,
      'originFileSize': instance.originFileSize,
      'status': instance.status,
      'updated': instance.updated,
    };

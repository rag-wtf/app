import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stacked_package_template/src/services/date_time_json_converter.dart';

part 'model.freezed.dart';
part 'model.g.dart';

@Freezed(toJson: true)
sealed class Model with _$Model {
  const factory Model({
    required String name,
    String? id,
    @DateTimeJsonConverter() DateTime? created,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Model;

  //factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'].toString(),
      name: json['name'] as String,
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  //static String? _fromJsonId(dynamic id) => id.toString();
  static const tableName = 'models';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
''';
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Document _$DocumentFromJson(Map<String, dynamic> json) {
  return _Document.fromJson(json);
}

/// @nodoc
mixin _$Document {
  String? get id => throw _privateConstructorUsedError;
  int get compressedFileSize => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  String get created => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  @Uint8ListJsonConverter()
  Uint8List get file => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get originFileSize => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get updated => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationError>? get errors => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentCopyWith<Document> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCopyWith<$Res> {
  factory $DocumentCopyWith(Document value, $Res Function(Document) then) =
      _$DocumentCopyWithImpl<$Res, Document>;
  @useResult
  $Res call(
      {String? id,
      int compressedFileSize,
      String? content,
      String contentType,
      String created,
      String errorMessage,
      @Uint8ListJsonConverter() Uint8List file,
      String name,
      int originFileSize,
      String status,
      String updated,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<ValidationError>? errors});
}

/// @nodoc
class _$DocumentCopyWithImpl<$Res, $Val extends Document>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? compressedFileSize = null,
    Object? content = freezed,
    Object? contentType = null,
    Object? created = null,
    Object? errorMessage = null,
    Object? file = null,
    Object? name = null,
    Object? originFileSize = null,
    Object? status = null,
    Object? updated = null,
    Object? errors = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      compressedFileSize: null == compressedFileSize
          ? _value.compressedFileSize
          : compressedFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      file: null == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      originFileSize: null == originFileSize
          ? _value.originFileSize
          : originFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as String,
      errors: freezed == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentImplCopyWith<$Res>
    implements $DocumentCopyWith<$Res> {
  factory _$$DocumentImplCopyWith(
          _$DocumentImpl value, $Res Function(_$DocumentImpl) then) =
      __$$DocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      int compressedFileSize,
      String? content,
      String contentType,
      String created,
      String errorMessage,
      @Uint8ListJsonConverter() Uint8List file,
      String name,
      int originFileSize,
      String status,
      String updated,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<ValidationError>? errors});
}

/// @nodoc
class __$$DocumentImplCopyWithImpl<$Res>
    extends _$DocumentCopyWithImpl<$Res, _$DocumentImpl>
    implements _$$DocumentImplCopyWith<$Res> {
  __$$DocumentImplCopyWithImpl(
      _$DocumentImpl _value, $Res Function(_$DocumentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? compressedFileSize = null,
    Object? content = freezed,
    Object? contentType = null,
    Object? created = null,
    Object? errorMessage = null,
    Object? file = null,
    Object? name = null,
    Object? originFileSize = null,
    Object? status = null,
    Object? updated = null,
    Object? errors = freezed,
  }) {
    return _then(_$DocumentImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      compressedFileSize: null == compressedFileSize
          ? _value.compressedFileSize
          : compressedFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      file: null == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      originFileSize: null == originFileSize
          ? _value.originFileSize
          : originFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as String,
      errors: freezed == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentImpl extends _Document {
  const _$DocumentImpl(
      {this.id,
      required this.compressedFileSize,
      this.content,
      required this.contentType,
      required this.created,
      required this.errorMessage,
      @Uint8ListJsonConverter() required this.file,
      required this.name,
      required this.originFileSize,
      required this.status,
      required this.updated,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final List<ValidationError>? errors})
      : _errors = errors,
        super._();

  factory _$DocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentImplFromJson(json);

  @override
  final String? id;
  @override
  final int compressedFileSize;
  @override
  final String? content;
  @override
  final String contentType;
  @override
  final String created;
  @override
  final String errorMessage;
  @override
  @Uint8ListJsonConverter()
  final Uint8List file;
  @override
  final String name;
  @override
  final int originFileSize;
  @override
  final String status;
  @override
  final String updated;
  final List<ValidationError>? _errors;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationError>? get errors {
    final value = _errors;
    if (value == null) return null;
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Document(id: $id, compressedFileSize: $compressedFileSize, content: $content, contentType: $contentType, created: $created, errorMessage: $errorMessage, file: $file, name: $name, originFileSize: $originFileSize, status: $status, updated: $updated, errors: $errors)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.compressedFileSize, compressedFileSize) ||
                other.compressedFileSize == compressedFileSize) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other.file, file) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.originFileSize, originFileSize) ||
                other.originFileSize == originFileSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.updated, updated) || other.updated == updated) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      compressedFileSize,
      content,
      contentType,
      created,
      errorMessage,
      const DeepCollectionEquality().hash(file),
      name,
      originFileSize,
      status,
      updated,
      const DeepCollectionEquality().hash(_errors));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      __$$DocumentImplCopyWithImpl<_$DocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentImplToJson(
      this,
    );
  }
}

abstract class _Document extends Document {
  const factory _Document(
      {final String? id,
      required final int compressedFileSize,
      final String? content,
      required final String contentType,
      required final String created,
      required final String errorMessage,
      @Uint8ListJsonConverter() required final Uint8List file,
      required final String name,
      required final int originFileSize,
      required final String status,
      required final String updated,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final List<ValidationError>? errors}) = _$DocumentImpl;
  const _Document._() : super._();

  factory _Document.fromJson(Map<String, dynamic> json) =
      _$DocumentImpl.fromJson;

  @override
  String? get id;
  @override
  int get compressedFileSize;
  @override
  String? get content;
  @override
  String get contentType;
  @override
  String get created;
  @override
  String get errorMessage;
  @override
  @Uint8ListJsonConverter()
  Uint8List get file;
  @override
  String get name;
  @override
  int get originFileSize;
  @override
  String get status;
  @override
  String get updated;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationError>? get errors;
  @override
  @JsonKey(ignore: true)
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_config.freezed.dart';
part 'split_config.g.dart';

@freezed
sealed class SplitConfig with _$SplitConfig {
  const factory SplitConfig({
    @JsonKey(name: 'delete_temp_file') required bool deleteTempFile,
    @JsonKey(name: 'nltk_data') required String nltkData,
    @JsonKey(name: 'max_file_size_in_mb') required double maxFileSizeInMb,
    @JsonKey(name: 'supported_file_types')
    required List<String> supportedFileTypes,
    @JsonKey(name: 'chunk_size') required int chunkSize,
    @JsonKey(name: 'chunk_overlap') required int chunkOverlap,
  }) = _SplitConfig;

  factory SplitConfig.fromJson(Map<String, dynamic> json) =>
      _$SplitConfigFromJson(json);
}

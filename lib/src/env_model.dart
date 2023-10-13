// Env Reader Auto-Generated Model File
// Created at 2023-10-12 16:58:32.395887
// 🍔 [Buy me a coffee](https://www.buymeacoffee.com/nialixus) 🚀
import 'package:env_reader/env_reader.dart';

/// Auto-generated environment model class.
///
/// This class represents environment variables parsed from the .env file.
/// Each static variable corresponds to an environment variable,
/// with default values provided for safety
/// `false` for [bool], `0` for [int], `0.0` for [double] and `VARIABLE_NAME` for [String].
class EnvModel {
  /// Value of `CONFIG` in environment variable. This is equal to
  /// ```dart
  /// Env.read<String>('CONFIG') ?? 'CONFIG';
  /// ```
  static String config = Env.read<String>('CONFIG') ?? 'CONFIG';

  /// Value of `DATA_INGESTION_API_URL` in environment variable. This is equal to
  /// ```dart
  /// Env.read<String>('DATA_INGESTION_API_URL') ?? 'DATA_INGESTION_API_URL';
  /// ```
  static String dataIngestionApiUrl = Env.read<String>('DATA_INGESTION_API_URL') ?? 'DATA_INGESTION_API_URL';

  /// Value of `EMBEDDINGS_API_BASE` in environment variable. This is equal to
  /// ```dart
  /// Env.read<String>('EMBEDDINGS_API_BASE') ?? 'EMBEDDINGS_API_BASE';
  /// ```
  static String embeddingsApiBase = Env.read<String>('EMBEDDINGS_API_BASE') ?? 'EMBEDDINGS_API_BASE';

  /// Value of `EMBEDDINGS_API_KEY` in environment variable. This is equal to
  /// ```dart
  /// Env.read<String>('EMBEDDINGS_API_KEY') ?? 'EMBEDDINGS_API_KEY';
  /// ```
  static String embeddingsApiKey = Env.read<String>('EMBEDDINGS_API_KEY') ?? 'EMBEDDINGS_API_KEY';

}

import 'package:fzregex/utils/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:settings/src/constants.dart';

class SettingsValidators {
  static const Pattern _decimalNumber = r'^-?\d+(\.\d+)?$';
  static const Pattern _csvUpTo4 = r'^([^,\s]+)(,[^,\s]+){0,3}$';

  static String? validateUrl(String? value) {
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri == null) {
        return 'Please enter a valid URL';
      } else {
        final uriString = uri.toString().toLowerCase();
        if (!(uriString.startsWith('http') || uriString.startsWith('https'))) {
          return 'Please enter API URL that start with http or https.';
        }
      }
    }

    return null;
  }

  static String? _validateApiUriPath(String uriPath, String? value) {
    if (value != null && value.isNotEmpty) {
      final message = validateUrl(value);
      if (message != null) {
        return message;
      } else {
        final uri = Uri.tryParse(value);
        if (!uri!.path.endsWith(uriPath)) {
          return 'Please enter API URL that end with $uriPath.';
        }
        return null;
      }
    }
    return null;
  }

  static String? validateSplitApiUrl(String? value) {
    return _validateApiUriPath(splitApiUriPath, value);
  }

  static String? validateEmbeddingsApiUrl(String? value) {
    return _validateApiUriPath(embeddingsApiUriPath, value);
  }

  static String? validateGenerationApiUrl(String? value) {
    return _validateApiUriPath(generationApiUriPath, value);
  }

  static bool isPositiveInteger(String s) {
    return RegExp(r'^[0-9]+$').hasMatch(s);
  }

  static String? _validateIntegerRange(
    String? value,
    int start,
    int end,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (isPositiveInteger(value)) {
      final integer = int.parse(value);
      if (integer < start || integer > end) {
        return 'Please enter a number between $start and $end.';
      }
    } else {
      return 'Please enter a valid number';
    }

    return null;
  }

  static String? validateEmbeddingsBatchSize(String? value) {
    return _validateIntegerRange(value, 10, 500);
  }

  static String? _validateMinimumValue(String? value, int minValue) {
    if (value != null && value.isNotEmpty) {
      if (isPositiveInteger(value)) {
        final integer = int.parse(value);
        if (integer < minValue) {
          return 'Please enter a minimum value of $minValue.';
        }
      } else {
        return 'Please enter a valid number';
      }
    }

    return null;
  }

  static String? validateEmbeddingsDimensions(String? value) {
    return _validateMinimumValue(value, 256);
  }

  static String? validateChunkSize(String? value) {
    return _validateIntegerRange(value, 100, 2000);
  }

  static String? validateChunkOverlap(String? value) {
    return _validateIntegerRange(value, 10, 400);
  }

  static String? validateSearchType(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, FzPattern.name)) {
        return 'Please enter a valid search type.';
      }
    }
    return null;
  }

  static String? validateSearchIndex(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, FzPattern.name)) {
        return 'Please enter a valid search index.';
      }
    }
    return null;
  }

  static String? _validateDoubleRange(
    String? value,
    double start,
    double end,
  ) {
    if (value != null && value.isNotEmpty) {
      if (Fzregex.hasMatch(value, _decimalNumber)) {
        final doubleValue = double.parse(value);
        if (doubleValue < start || doubleValue > end) {
          return 'Please enter a number between $start and $end.';
        }
      } else {
        return 'Please enter a valid decimal number';
      }
    }

    return null;
  }

  static String? validateSearchThreshold(String? value) {
    return _validateDoubleRange(value, 0.5, 0.9);
  }

  static String? validateRetrieveTopNResults(String? value) {
    return _validateIntegerRange(value, 1, 30);
  }

  static String? validateTemperature(String? value) {
    return _validateDoubleRange(value, 0, 1);
  }

  static String? validateTopP(String? value) {
    return _validateDoubleRange(value, 0, 1);
  }

  static String? validateFrequencyPenalty(String? value) {
    return _validateDoubleRange(value, -2, 2);
  }

  static String? validateMaxTokens(String? value) {
    return _validateMinimumValue(value, 64);
  }

  static String? validateStop(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, _csvUpTo4)) {
        return 'Please enter up to 4 comma-separated values without space.';
      }
    }

    return null;
  }

  static String? validatePromptTemplate(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!value.contains(contextPlaceholder) ||
          !value.contains(instructionPlaceholder)) {
        return '''
Please enter prompt template with $contextPlaceholder and $instructionPlaceholder.''';
      }
    }

    return null;
  }
}

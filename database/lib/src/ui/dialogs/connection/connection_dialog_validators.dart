import 'package:fzregex/utils/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';

class ConnectionDialogValidators {
  static const Pattern alphanumericUnderscore = r'^[a-zA-Z0-9_]+$';

  static String? _validateUrl(String? value) {
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri == null) {
        return 'Please enter a valid URL';
      } else {
        final uriString = uri.toString().toLowerCase();
        if (!(uriString.startsWith('http') ||
            uriString.startsWith('https') ||
            uriString.startsWith('ws') ||
            uriString.startsWith('wss'))) {
          return 'Please enter URL that start with https, http, wss or ws.';
        }
      }
    }

    return null;
  }

  static String? validateAddressPort(String protocol, String? addressPort) {
    if (addressPort != null && addressPort.isNotEmpty) {
      return _validateUrl('$protocol//$addressPort');
    } else {
      return 'Please enter address:port.';
    }
  }

  static String? validateConnectionName(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, FzPattern.name)) {
        return 'Please enter valid name.';
      }
    } else {
      return 'Please enter name.';
    }
    return null;
  }

  static String? _validateName(
    String? value,
    String fieldName, {
    bool required = true,
  }) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, alphanumericUnderscore)) {
        return 'Please enter valid $fieldName.';
      }
    } else if (required) {
      return 'Please enter $fieldName.';
    }
    return null;
  }

  static String? validateDatabaseName(String? value) {
    return _validateName(value, 'database_name');
  }

  static String? validateDatabase(String? value) {
    return _validateName(value, 'Database', required: false);
  }

  static String? validateNamespace(String? value) {
    return _validateName(value, 'Namespace', required: false);
  }

  static String? validateNamespaceOrDatabaseValue(
    String? namespace,
    String? database,
  ) {
    if ((namespace == null || namespace.isEmpty) &&
        (database == null || database.isEmpty)) {
      return 'Please enter Namespace or Database.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Fzregex.hasMatch(value, FzPattern.username)) {
        return 'Please enter valid Username.';
      }
    } else {
      return 'Please enter Username.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Password.';
    }
    return null;
  }
}

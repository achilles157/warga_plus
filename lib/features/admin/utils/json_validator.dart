class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final dynamic data;
  final String? summary;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.data,
    this.summary,
  });

  factory ValidationResult.success(dynamic data, String summary) =>
      ValidationResult(isValid: true, data: data, summary: summary);

  factory ValidationResult.failure(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}

class JsonValidator {
  static ValidationResult validateFullRelease(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return ValidationResult.failure(
          "JSON must be an Object {} for Full Release.");
    }

    // Check mandatory fields
    final requiredFields = [
      'release_id',
      'title',
      'cover_image',
      'sub_modules'
    ];
    for (var field in requiredFields) {
      if (!decoded.containsKey(field)) {
        return ValidationResult.failure("Missing required field: '$field'.");
      }
    }

    // Check sub_modules
    final subModules = decoded['sub_modules'] as List?;

    // Count Bubbles Recursively
    int totalBubbles = 0;
    List<String> details = [];

    if (subModules != null) {
      for (var item in subModules) {
        if (item is Map<String, dynamic>) {
          if (item['type'] == 'chat_stream' && item['chat_script'] is List) {
            final count = (item['chat_script'] as List).length;
            totalBubbles += count;
            details.add("${item['id']}: $count bubbles");
          }
        }
      }
    }

    return ValidationResult.success(
        decoded,
        "Title: ${decoded['title']}\n"
        "ID: ${decoded['release_id']}\n"
        "SubModules: ${subModules?.length ?? 0}\n"
        "Total Chat Bubbles: $totalBubbles\n"
        "Details: ${details.take(3).join(', ')}${details.length > 3 ? '...' : ''}");
  }

  static ValidationResult validateSubModule(
      dynamic decoded, String targetReleaseId) {
    // Can be List or Map
    List items = [];
    if (decoded is Map<String, dynamic>) {
      items = [decoded];
    } else if (decoded is List) {
      items = decoded;
    } else {
      return ValidationResult.failure(
          "JSON must be an Object {} or Array [] for SubModules.");
    }

    if (targetReleaseId.isEmpty) {
      return ValidationResult.failure(
          "Target Release ID is required for SubModule import.");
    }

    int totalBubbles = 0;
    List<String> details = [];

    // Check items
    for (var item in items) {
      if (item is! Map<String, dynamic>) {
        return ValidationResult.failure("Items must be Objects.");
      }
      if (!item.containsKey('id')) {
        return ValidationResult.failure("Item missing 'id'.");
      }
      if (!item.containsKey('title')) {
        return ValidationResult.failure(
            "Item '${item['id']}' missing 'title'.");
      }

      // Count Bubbles
      if (item['type'] == 'chat_stream' && item['chat_script'] is List) {
        final count = (item['chat_script'] as List).length;
        totalBubbles += count;
        details.add("${item['id']}: $count bubbles");
      }
    }

    return ValidationResult.success(
        decoded is List ? decoded : [decoded],
        "Action: Add/Update SubModules\n"
        "Target Release: $targetReleaseId\n"
        "Item Count: ${items.length}\n"
        "Total Chat Bubbles: $totalBubbles\n"
        "Details: ${details.take(3).join(', ')}${details.length > 3 ? '...' : ''}\n"
        "IDs: ${items.map((e) => e['id']).take(3).join(', ')}${items.length > 3 ? '...' : ''}");
  }

  static ValidationResult validateContext(
      String content, String targetReleaseId, String targetSubModuleId) {
    if (targetReleaseId.isEmpty || targetSubModuleId.isEmpty) {
      return ValidationResult.failure(
          "Target Release ID and SubModule ID are required.");
    }

    // Payload construction for Service
    final payload = {
      'release_id': targetReleaseId.trim(),
      'sub_module_id': targetSubModuleId.trim(),
      'ai_context': content
    };

    return ValidationResult.success(
        payload,
        "Action: Update AI Context (RAG)\n"
        "Target Release: $targetReleaseId\n"
        "Target SubModule: $targetSubModuleId\n"
        "Context Length: ${content.length} characters");
  }
}

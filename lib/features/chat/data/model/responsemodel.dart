class CardResponseModel {
  final String objectId;
  final String type;

  CardResponseModel({
    required this.objectId,
    required this.type,
  });
}

class ChatResponseModel {
  final String displayText;
  final Map<String, dynamic> extractedFields;
  final List<String> rawBracketedContent;
  final String originalText;

  // Specific extracted fields - only objectId and type
  final String? objectId;
  final String? type;
  final Map<String, String>? metadata;

  ChatResponseModel({
    required this.displayText,
    required this.extractedFields,
    required this.rawBracketedContent,
    required this.originalText,
    this.objectId,
    this.type,
    this.metadata,
  });

  factory ChatResponseModel.fromRawResponse(String rawResponse) {
    final parser = BracketedContentParser();
    return parser.parseResponse(rawResponse);
  }

  Map<String, dynamic> toJson() => {
        'displayText': displayText,
        'extractedFields': extractedFields,
        'rawBracketedContent': rawBracketedContent,
        'originalText': originalText,
        'objectId': objectId,
        'type': type,
        'metadata': metadata,
      };

  bool get hasExtractedFields => extractedFields.isNotEmpty;
  bool get hasObjectId => objectId != null && objectId!.isNotEmpty;
  bool get hasType => type != null && type!.isNotEmpty;
}

class BracketedContentParser {
  // Define the specific fields we want to extract and store
  static const Set<String> _allowedFields = {
    'objectid',
    'object_id',
    'type',
  };

  ChatResponseModel parseResponse(String rawResponse) {
    final RegExp bracketRegex = RegExp(r'\[([^\]]*)\]');
    final List<String> rawBracketedContent = [];
    final Map<String, dynamic> extractedFields = {};
    final Map<String, String> metadata = {};

    // Extract all bracketed content
    final Iterable<RegExpMatch> matches = bracketRegex.allMatches(rawResponse);

    for (final match in matches) {
      final String bracketContent = match.group(1) ?? '';
      if (bracketContent.trim().isNotEmpty) {
        rawBracketedContent.add(bracketContent);

        // Parse field:value pairs within brackets
        _parseFieldValuePairs(bracketContent, extractedFields, metadata);
      }
    }

    // Remove all bracketed content from display text
    final String displayText = rawResponse
        .replaceAll(bracketRegex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();

    return ChatResponseModel(
      displayText: displayText,
      extractedFields: extractedFields,
      rawBracketedContent: rawBracketedContent,
      originalText: rawResponse,
      objectId: extractedFields['objectid']?.toString() ??
          extractedFields['object_id']?.toString(),
      type: extractedFields['type']?.toString(),
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  void _parseFieldValuePairs(String bracketContent,
      Map<String, dynamic> extractedFields, Map<String, String> metadata) {
    // Handle different bracket content formats:
    // Format 1: "field: value"
    // Format 2: "field=value"
    // Format 3: "field1: value1, field2: value2"
    // Format 4: "field1=value1&field2=value2"
    // Format 5: JSON-like: {"objectid": "dM0VtFLN5i", "type": "HABIT"}

    // Try to parse as JSON first
    try {
      // Remove any extra quotes and clean the content
      String cleanContent = bracketContent.trim();
      if (cleanContent.startsWith('{') && cleanContent.endsWith('}')) {
        // This looks like JSON, try to parse it
        final RegExp jsonPairRegex = RegExp(r'"([^"]+)"\s*[=:]\s*"([^"]+)"');
        final matches = jsonPairRegex.allMatches(cleanContent);

        for (final match in matches) {
          final key = match.group(1)?.toLowerCase();
          final value = match.group(2);

          if (key != null && value != null && value.isNotEmpty) {
            if (_allowedFields.contains(key)) {
              extractedFields[key] = value;
              print('✅ Extracted field: $key = $value');
            } else {
              metadata[key] = value;
              print('ℹ️ Unrecognized field stored in metadata: $key = $value');
            }
          }
        }
        return; // Successfully parsed as JSON-like format
      }
    } catch (e) {
      // Not JSON format, continue with other parsing methods
    }

    List<String> pairs = [];

    // Try comma-separated first
    if (bracketContent.contains(',')) {
      pairs = bracketContent.split(',');
    }
    // Try ampersand-separated
    else if (bracketContent.contains('&')) {
      pairs = bracketContent.split('&');
    }
    // Single pair
    else {
      pairs = [bracketContent];
    }

    for (String pair in pairs) {
      pair = pair.trim();

      String? key;
      String? value;

      // Try colon separator
      if (pair.contains(':')) {
        final parts = pair.split(':');
        if (parts.length >= 2) {
          key = parts[0].trim().toLowerCase();
          value = parts.sublist(1).join(':').trim();
          // Remove quotes if present
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
        }
      }
      // Try equals separator
      else if (pair.contains('=')) {
        final parts = pair.split('=');
        if (parts.length >= 2) {
          key = parts[0].trim().toLowerCase();
          value = parts.sublist(1).join('=').trim();
          // Remove quotes if present
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
        }
      }
      // Single value without separator (treat as type)
      else if (pair.isNotEmpty) {
        key = 'type';
        value = pair.trim();
      }

      if (key != null && value != null && value.isNotEmpty) {
        // Only store allowed fields
        if (_allowedFields.contains(key)) {
          extractedFields[key] = value;
          print('✅ Extracted field: $key = $value');
        } else {
          // Store unrecognized fields in metadata but don't use them
          metadata[key] = value;
          print('ℹ️ Unrecognized field stored in metadata: $key = $value');
        }
      }
    }
  }
}

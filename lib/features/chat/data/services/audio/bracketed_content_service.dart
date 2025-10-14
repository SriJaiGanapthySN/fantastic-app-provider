import '../../model/responsemodel.dart';

class BracketedContentService {
  static final Map<String, ChatResponseModel> _storedResponseModels = {};

  /// Store response model for a message ID
  static void storeResponseModel(
      String messageId, ChatResponseModel responseModel) {
    if (responseModel.hasExtractedFields) {
      _storedResponseModels[messageId] = responseModel;
      print('🔒 Stored response model for message $messageId');
      print('   Fields: ${responseModel.extractedFields}');
      if (responseModel.objectId != null) {
        print('   Object ID: ${responseModel.objectId}');
      }
      if (responseModel.type != null) {
        print('   Type: ${responseModel.type}');
      }
    }
  }

  /// Store content using the legacy method (for backward compatibility)
  static void storeContent(
      String messageId, List<String> content, String originalMessage) {
    if (content.isNotEmpty) {
      final responseModel = ChatResponseModel.fromRawResponse(originalMessage);
      storeResponseModel(messageId, responseModel);
    }
  }

  /// Get stored response model for a message ID
  static ChatResponseModel? getResponseModel(String messageId) {
    return _storedResponseModels[messageId];
  }

  /// Get stored bracketed content for a message ID (legacy support)
  static List<String>? getStoredContent(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.rawBracketedContent;
  }

  /// Get original message with brackets for a message ID
  static String? getOriginalMessage(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.originalText;
  }

  /// Get extracted fields for a message ID
  static Map<String, dynamic>? getExtractedFields(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.extractedFields;
  }

  /// Get specific field value for a message ID
  static String? getFieldValue(String messageId, String fieldName) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.extractedFields[fieldName]?.toString();
  }

  /// Get object ID for a message ID
  static String? getObjectId(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.objectId;
  }

  /// Get type for a message ID
  static String? getType(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    return responseModel?.type;
  }

  /// Check if a message has stored response model
  static bool hasStoredContent(String messageId) {
    return _storedResponseModels.containsKey(messageId) &&
        _storedResponseModels[messageId]!.hasExtractedFields;
  }

  /// Get all stored response models as a map
  static Map<String, ChatResponseModel> getAllResponseModels() {
    return Map.from(_storedResponseModels);
  }

  /// Get all stored content as a map (legacy support)
  static Map<String, List<String>> getAllStoredContent() {
    final Map<String, List<String>> legacyMap = {};
    _storedResponseModels.forEach((messageId, responseModel) {
      legacyMap[messageId] = responseModel.rawBracketedContent;
    });
    return legacyMap;
  }

  /// Clear stored content for a specific message
  static void clearContent(String messageId) {
    _storedResponseModels.remove(messageId);
  }

  /// Clear all stored content
  static void clearAllContent() {
    _storedResponseModels.clear();
    print('🧹 Cleared all response models and bracketed content');
  }

  /// Get the count of messages with stored content
  static int getStoredContentCount() {
    return _storedResponseModels.length;
  }

  /// Get stored content as formatted string for a message (legacy support)
  static String getStoredContentAsString(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    if (responseModel == null || responseModel.rawBracketedContent.isEmpty) {
      return '';
    }
    return responseModel.rawBracketedContent.join(', ');
  }

  /// Get extracted fields as formatted string for a message
  static String getExtractedFieldsAsString(String messageId) {
    final responseModel = _storedResponseModels[messageId];
    if (responseModel == null || responseModel.extractedFields.isEmpty) {
      return '';
    }

    final List<String> fieldStrings = [];
    responseModel.extractedFields.forEach((key, value) {
      fieldStrings.add('$key: $value');
    });
    return fieldStrings.join(', ');
  }

  /// Find messages by field value
  static List<String> findMessagesByField(String fieldName, String fieldValue) {
    final List<String> matchingMessageIds = [];

    _storedResponseModels.forEach((messageId, responseModel) {
      if (responseModel.extractedFields[fieldName] == fieldValue) {
        matchingMessageIds.add(messageId);
      }
    });

    return matchingMessageIds;
  }

  /// Find messages by action
  static List<String> findMessagesByAction(String action) {
    return findMessagesByField('action', action);
  }

  /// Find messages by category
  static List<String> findMessagesByCategory(String category) {
    return findMessagesByField('category', category);
  }
}

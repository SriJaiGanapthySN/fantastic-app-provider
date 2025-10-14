import '../../features/chat/data/model/responsemodel.dart';

class ResponseParser {
  /// Parses response text to extract content within square brackets
  /// Returns a map with 'displayText' (text without brackets) and 'responseModel' (structured data)
  static Map<String, dynamic> parseResponseWithBrackets(String originalText) {
    final ChatResponseModel responseModel =
        ChatResponseModel.fromRawResponse(originalText);

    return {
      'displayText': responseModel.displayText,
      'responseModel': responseModel,
      'extractedFields': responseModel.extractedFields,
      'originalText': originalText,
      'hasBracketedContent': responseModel.hasExtractedFields,
      // Legacy support for existing code
      'storedContent': responseModel.rawBracketedContent,
    };
  }

  /// Extracts just the stored content from square brackets (legacy method)
  static List<String> extractBracketedContent(String text) {
    final responseModel = ChatResponseModel.fromRawResponse(text);
    return responseModel.rawBracketedContent;
  }

  /// Removes all square brackets and their content from text
  static String removeAllBrackets(String text) {
    final responseModel = ChatResponseModel.fromRawResponse(text);
    return responseModel.displayText;
  }

  /// Checks if text contains square brackets
  static bool hasBrackets(String text) {
    return RegExp(r'\[([^\]]*)\]').hasMatch(text);
  }

  /// Gets a structured response model from raw text
  static ChatResponseModel getResponseModel(String text) {
    return ChatResponseModel.fromRawResponse(text);
  }

  /// Extracts specific fields from bracketed content
  static Map<String, dynamic> extractFields(String text) {
    final responseModel = ChatResponseModel.fromRawResponse(text);
    return responseModel.extractedFields;
  }
}

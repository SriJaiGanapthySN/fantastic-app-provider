import '../utils/response_parser.dart';
import '../services/bracketed_content_service.dart';

void testJsonBracketParsing() {
  print('🧪 Testing JSON-like bracket parsing...\n');

  // Test case based on your log output
  final testResponse =
      'Here is your response [{"objectid" = "dM0VtFLN5i", "type" = "HABIT"}] with some additional text.';
  final messageId = 'test_message_001';

  print('📝 Input response: $testResponse');
  print('🆔 Message ID: $messageId\n');

  // Parse the response
  final result = ResponseParser.parseResponseWithBrackets(testResponse);

  print('✅ Parsing Results:');
  print('   Clean text: "${result['displayText']}"');
  print('   Has bracketed content: ${result['hasBracketedContent']}');

  if (result['responseModel'] != null) {
    final responseModel = result['responseModel'];
    print('\n📦 Response Model Details:');
    print('   Object ID: ${responseModel.objectId}');
    print('   Type: ${responseModel.type}');
    print('   Extracted fields: ${responseModel.extractedFields}');

    // Store the response model
    BracketedContentService.storeResponseModel(messageId, responseModel);

    print('\n🔍 Service Retrieval Test:');
    final retrievedObjectId = BracketedContentService.getObjectId(messageId);
    final retrievedType = BracketedContentService.getType(messageId);

    print('   Retrieved Object ID: $retrievedObjectId');
    print('   Retrieved Type: $retrievedType');

    // Verify the results
    final objectIdMatch = retrievedObjectId == 'dM0VtFLN5i';
    final typeMatch = retrievedType == 'HABIT';

    print('\n✅ Verification:');
    print('   Object ID matches: $objectIdMatch');
    print('   Type matches: $typeMatch');
    print('   Overall success: ${objectIdMatch && typeMatch}');
  } else {
    print('❌ No response model created - parsing failed');
  }

  print('\n' + '=' * 50);
}

void main() {
  testJsonBracketParsing();
}

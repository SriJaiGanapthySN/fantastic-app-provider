// Example usage and test for square bracket response parsing

import '../utils/response_parser.dart';

void main() {
  // Test examples
  testResponseParser();
}

void testResponseParser() {
  print('=== Response Parser Test ===');

  // Test 1: JSON-like format (as seen in your logs)
  final test1 =
      'Hello there! [{"objectid": "dM0VtFLN5i", "type": "HABIT"}] How can I help you today?';
  final result1 = ResponseParser.parseResponseWithBrackets(test1);
  print('\nTest 1 (JSON-like format):');
  print('Original: $test1');
  print('Display: ${result1['displayText']}');
  print('Response Model: ${result1['responseModel']}');
  print('Object ID: ${result1['responseModel'].objectId}');
  print('Type: ${result1['responseModel'].type}');

  // Test 2: Simple colon format
  final test2 =
      "I understand [objectid: dM0VtFLN5i, type: HABIT] that you want to build habits.";
  final result2 = ResponseParser.parseResponseWithBrackets(test2);
  print('\nTest 2 (colon format):');
  print('Original: $test2');
  print('Display: ${result2['displayText']}');
  print('Object ID: ${result2['responseModel'].objectId}');
  print('Type: ${result2['responseModel'].type}');

  // Test 3: No brackets
  final test3 = "This is a normal response without any special content.";
  final result3 = ResponseParser.parseResponseWithBrackets(test3);
  print('\nTest 3 (no brackets):');
  print('Original: $test3');
  print('Display: ${result3['displayText']}');
  print('Has Bracketed Content: ${result3['hasBracketedContent']}');

  // Test 4: Only objectid
  final test4 = "Check this out [objectid: ABC123] for more details.";
  final result4 = ResponseParser.parseResponseWithBrackets(test4);
  print('\nTest 4 (only objectid):');
  print('Original: $test4');
  print('Display: ${result4['displayText']}');
  print('Object ID: ${result4['responseModel'].objectId}');
  print('Type: ${result4['responseModel'].type}');

  // Test 5: Only type
  final test5 = "This is about [type: JOURNEY] experiences.";
  final result5 = ResponseParser.parseResponseWithBrackets(test5);
  print('\nTest 5 (only type):');
  print('Original: $test5');
  print('Display: ${result5['displayText']}');
  print('Object ID: ${result5['responseModel'].objectId}');
  print('Type: ${result5['responseModel'].type}');

  print('\n=== Test Complete ===');
}

/*
Expected Output:

=== Response Parser Test ===

Test 1 (JSON-like format):
Original: Hello there! [{"objectid": "dM0VtFLN5i", "type": "HABIT"}] How can I help you today?
Display: Hello there! How can I help you today?
✅ Extracted field: objectid = dM0VtFLN5i
✅ Extracted field: type = HABIT
Object ID: dM0VtFLN5i
Type: HABIT

Test 2 (colon format):
Original: I understand [objectid: dM0VtFLN5i, type: HABIT] that you want to build habits.
Display: I understand that you want to build habits.
✅ Extracted field: objectid = dM0VtFLN5i
✅ Extracted field: type = HABIT
Object ID: dM0VtFLN5i
Type: HABIT

Test 3 (no brackets):
Original: This is a normal response without any special content.
Display: This is a normal response without any special content.
Has Bracketed Content: false

Test 4 (only objectid):
Original: Check this out [objectid: ABC123] for more details.
Display: Check this out for more details.
✅ Extracted field: objectid = ABC123
Object ID: ABC123
Type: null

Test 5 (only type):
Original: This is about [type: JOURNEY] experiences.
Display: This is about experiences.
✅ Extracted field: type = JOURNEY
Object ID: null
Type: JOURNEY

=== Test Complete ===
*/

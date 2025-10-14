import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../model/chat_message.dart';
import '../token/token_service.dart';

class ChatApiService {
  // Register a new user by sending all text fields to /register
  Future<Map<String, dynamic>?> register(
    Map<String, String> registrationData,
  ) async {
    try {
      print('Registering user with data: $registrationData');
      final url = '$baseUrl/auth/register';
      final payload = jsonEncode(registrationData);
      print('POST $url');
      print('Payload: $payload');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': registrationData['name'],
            'email': registrationData['email'],
            'password': registrationData['password'],
            'age': registrationData['age'],
            'gender_identity': registrationData['gender'],
            'location': registrationData['location'],
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Registration successful!');
        return data;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  static const String baseUrl = 'https://mental-health.rohanrichard.com';
  static const String audioUrl = 'https://mental-health.rohanrichard.com/audio';

  // Alternative endpoints to try if main one fails
  static const List<String> fallbackUrls = [
    'https://mental-health.rohanrichard.com',
    'http://mental-health.rohanrichard.com', // Try HTTP if HTTPS fails
    // Add more fallback URLs if you have them
  ];

  // Timeout duration for API calls
  static const Duration apiTimeout = Duration(seconds: 30);

  // Check network connectivity by testing DNS resolution
  Future<bool> checkNetworkConnectivity() async {
    try {
      print('Checking network connectivity...');
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(Duration(seconds: 10));

      print('Network connectivity check passed');
      return response.statusCode == 200;
    } catch (e) {
      print('Network connectivity check failed: $e');
      return false;
    }
  }

  // Check if the API server is reachable
  Future<bool> checkApiServerHealth() async {
    try {
      print('Checking API server health...');
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(Duration(seconds: 15));

      print('API server health check passed');
      return response.statusCode == 200;
    } catch (e) {
      print('API server health check failed: $e');
      return false;
    }
  }

  // Authenticate and get access token
  Future<String?> authenticate(String email, String password) async {
    try {
      print('Authenticating user: $email');

      // First check network connectivity
      final hasNetwork = await checkNetworkConnectivity();
      if (!hasNetwork) {
        print(
            'No network connectivity. Please check your internet connection.');
        return null;
      }

      print('Attempting to connect to: $baseUrl/auth/token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/token'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(apiTimeout);

      print('Authentication response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        print('Authentication successful!');

        // Store token using TokenService
        await TokenService.storeToken(token);

        // Also store user email
        await TokenService.storeUserDetails(email: email);

        return token;
      } else {
        print('Authentication failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } on http.ClientException catch (e) {
      print('Network error during authentication: $e');
      print('This might indicate:');
      print('   - DNS resolution failure for $baseUrl');
      print('   - No internet connection');
      print('   - Server is down');
      print('   - Firewall blocking the request');

      // Try to check if it's a general network issue
      final hasNetwork = await checkNetworkConnectivity();
      if (!hasNetwork) {
        print('Confirmed: No internet connection');
      } else {
        print('Internet works, but API server seems unreachable');
      }

      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  } // Fetch existing messages

  Future<List<ChatMessage>> fetchMessages() async {
    try {
      // Use backend token for API authentication instead of Firebase token
      final token = await TokenService.getBackendToken();
      if (token == null) {
        print(
            'No backend token available for fetching messages - attempting to generate...');
        final newToken = await TokenService.generateAndStoreBackendToken();
        if (newToken == null) {
          print('Failed to generate backend token');
          return [];
        }
      }

      final finalToken = await TokenService.getBackendToken();
      if (finalToken == null) {
        print('No token available for fetching messages');
        return [];
      }

      print('Fetching messages from server...');

      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $finalToken',
        },
      ).timeout(apiTimeout);

      print('Fetch messages response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesJson = data['messages'] as List<dynamic>;
        print('Successfully fetched ${messagesJson.length} messages');
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
        return [];
      }
    } on http.ClientException catch (e) {
      print('Network error fetching messages: $e');
      return [];
    } on TimeoutException catch (e) {
      print('Timeout error fetching messages: $e');
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // Send message to API and return parsed streaming response
  Future<Map<String, dynamic>?> sendMessage(String message,
      {String inputType = 'text'}) async {
    try {
      // Use backend token for API authentication instead of Firebase token
      final token = await TokenService.getBackendToken();
      if (token == null) {
        print('No backend token available - attempting to generate...');
        final newToken = await TokenService.generateAndStoreBackendToken();
        if (newToken == null) {
          print('Failed to generate backend token');
          return null;
        }
      }

      final finalToken = await TokenService.getBackendToken();
      if (finalToken == null) return null;

      print('Sending message: $message (input type: $inputType)');

      final requestHeaders = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $finalToken',
        'User-Agent': 'Flutter-App/1.0',
      };

      final requestBody = {
        'message': message,
        'message_type': inputType == 'voice' ? 'voice' : 'text',
      };

      print('🚀 Request headers: $requestHeaders');
      print('🚀 Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/'),
            headers: requestHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 60)); // Increase timeout for API calls

      print('Send message response status: ${response.statusCode}');
      print(
          '📋 Raw API Response Body (first 500 chars): "${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}"');
      print('📋 FULL API Response Body: "${response.body}"');
      print('📋 Response body length: ${response.body.length}');
      print('📋 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final parsed = _parseStreamingResponse(response.body, inputType);
        print('🔍 Parsed response result: $parsed');
        return parsed;
      }

      print('Send message failed with status: ${response.statusCode}');
      return null;
    } on http.ClientException catch (e) {
      print('Network error during message sending: $e');
      return null;
    } on TimeoutException catch (e) {
      print('Timeout error during message sending: $e');
      return null;
    } catch (e) {
      print('Send message error: $e');
      return null;
    }
  }

  // Send message with streaming callback for real-time updates
  Future<Map<String, dynamic>?> sendMessageWithStreaming(
    String message,
    Function(String chunk) onChunk,
    Function() onComplete, {
    String inputType = 'text',
  }) async {
    try {
      // Use backend token for API authentication instead of Firebase token
      final token = await TokenService.getBackendToken();
      if (token == null) {
        print('No backend token available - attempting to generate...');
        final newToken = await TokenService.generateAndStoreBackendToken();
        if (newToken == null) {
          print('Failed to generate backend token');
          return null;
        }
      }

      final finalToken = await TokenService.getBackendToken();
      if (finalToken == null) return null;

      print(
          'Sending message with streaming: $message (input type: $inputType)');

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $finalToken',
            },
            body: jsonEncode({
              'message': message,
              'message_type': inputType == 'voice' ? 'voice' : 'text',
            }),
          )
          .timeout(Duration(seconds: 60)); // Increase timeout for streaming

      print('Send message response status: ${response.statusCode}');
      print(
          '🔄 Streaming API Response Body (first 500 chars): "${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}"');

      if (response.statusCode == 200) {
        final parsed = _parseStreamingResponseWithCallback(
            response.body, onChunk, onComplete, inputType);
        print('🔍 Streaming parsed response result: $parsed');
        return parsed;
      }

      print('Send message failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Send message error: $e');
      return null;
    }
  }

  // Parse streaming SSE response
  Map<String, dynamic>? _parseStreamingResponse(
      String responseBody, String inputType) {
    try {
      print('🔍 Parsing streaming response - Input type: $inputType');
      print(
          '🔍 Response body preview: "${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}..."');

      // First, try to parse as regular JSON response
      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse is Map<String, dynamic>) {
          print('✅ Found direct JSON response!');
          final aiContent = jsonResponse['ai_message_content'] as String?;
          if (aiContent != null && aiContent.isNotEmpty) {
            print(
                '✅ Direct JSON has ai_message_content: "${aiContent.substring(0, aiContent.length > 100 ? 100 : aiContent.length)}..."');
            jsonResponse['input_type'] = inputType;
            return jsonResponse;
          }
        }
      } catch (e) {
        print('🔍 Not direct JSON, trying SSE format...');
      }

      final lines = responseBody.trim().split('\n');
      Map<String, dynamic>? metadata;
      final messageChunks = <String>[];

      print('🔍 Processing ${lines.length} lines for SSE format');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        print('🔍 Line $i: "$line"');

        if (line.startsWith('data: ')) {
          final content = line.substring(6); // Remove "data: " prefix
          print('🔍 SSE content: "$content"');

          if (content.trim().isEmpty) {
            continue; // Skip empty lines
          }

          // Try to parse as JSON (first line contains metadata)
          if (metadata == null) {
            try {
              metadata = jsonDecode(content);
              print('📋 Parsed metadata: $metadata');
              continue;
            } catch (e) {
              print('🔍 Content is not JSON metadata, treating as text chunk');
            }
          }

          // Collect text chunks for the AI message
          messageChunks.add(content);
          print(
              '🔍 Added chunk to messageChunks. Total chunks: ${messageChunks.length}');
        } else if (line.trim().isNotEmpty) {
          // Handle non-SSE lines that might contain content
          print('🔍 Non-SSE line with content: "$line"');
          messageChunks.add(line);
        }
      }

      // Combine all message chunks and clean them
      final rawAiMessage = messageChunks.join(' ').trim();
      print(
          '🔍 Raw AI message before cleaning: "$rawAiMessage" (length: ${rawAiMessage.length})');

      final fullAiMessage = _removeSquareBrackets(rawAiMessage);
      print(
          '🤖 Complete AI message (cleaned): "$fullAiMessage" (length: ${fullAiMessage.length})');

      // Return metadata with the complete AI message and audio URL based on input type
      if (metadata != null) {
        metadata['ai_message_content'] = fullAiMessage;
        metadata['input_type'] = inputType;

        // Only generate audio URL for voice input
        if (inputType == 'voice') {
          metadata['audio_url'] = getAudioUrl(fullAiMessage);
          print(
              'Successfully parsed streaming response with audio URL for voice input');
        } else {
          print(
              'Successfully parsed streaming response for text input (no audio)');
        }

        print('🎯 Final metadata: $metadata');
        return metadata;
      } else {
        // If no metadata found, create a basic response
        print('⚠️ No metadata found, creating basic response structure');
        final basicResponse = {
          'ai_message_content': fullAiMessage,
          'input_type': inputType,
          'user_message_id':
              'fallback_${DateTime.now().millisecondsSinceEpoch}',
          'ai_message_id':
              'fallback_ai_${DateTime.now().millisecondsSinceEpoch}',
          'created_at': DateTime.now().toIso8601String(),
          'message_type': 'text',
        };
        print('🎯 Basic fallback response: $basicResponse');
        return basicResponse;
      }
    } catch (e) {
      print('❌ Error parsing streaming response: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Parse streaming response with real-time callbacks
  Map<String, dynamic>? _parseStreamingResponseWithCallback(
    String responseBody,
    Function(String chunk) onChunk,
    Function() onComplete,
    String inputType,
  ) {
    try {
      // First, try to parse as regular JSON response
      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse is Map<String, dynamic>) {
          final aiMessageContent =
              jsonResponse['ai_message_content'] as String?;

          if (aiMessageContent != null && aiMessageContent.isNotEmpty) {
            print(
                '📋 Parsing regular JSON response, content length: ${aiMessageContent.length}');

            // Remove square brackets from the content before streaming
            final cleanedContent = _removeSquareBrackets(aiMessageContent);

            // Simulate streaming by breaking text into chunks
            final words = cleanedContent.split(' ');
            for (int i = 0; i < words.length; i++) {
              final chunk = i == 0 ? words[i] : ' ${words[i]}';
              Future.delayed(Duration(milliseconds: i * 100), () {
                onChunk(chunk);
              });
            }

            // Call completion after all chunks
            final totalDelay = words.length * 100 + 200;
            Future.delayed(Duration(milliseconds: totalDelay), () {
              onComplete();
            });

            return jsonResponse;
          }
        }
      } catch (e) {
        // Not JSON format, try SSE format below
        print('Not a JSON response, trying SSE format...');
      }

      // If not JSON, try SSE streaming format
      final lines = responseBody.trim().split('\n');
      Map<String, dynamic>? metadata;
      bool hasContent = false;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        if (line.startsWith('data: ')) {
          final content = line.substring(6); // Remove "data: " prefix

          if (content.trim().isEmpty) {
            continue; // Skip empty lines
          }

          // Try to parse as JSON (first line contains metadata)
          if (metadata == null) {
            try {
              metadata = jsonDecode(content);
              metadata!['input_type'] = inputType;
              print('📋 Parsed SSE metadata: $metadata');
              continue;
            } catch (e) {
              // Not JSON, treat as text chunk
            }
          }

          // Clean the chunk by removing square brackets before sending
          final cleanedContent = _removeSquareBrackets(content);
          hasContent = true;

          // Send each cleaned text chunk with a delay to simulate real-time streaming
          Future.delayed(Duration(milliseconds: i * 50), () {
            onChunk(cleanedContent);
          });
        }
      }

      if (hasContent) {
        // Call completion callback after all chunks are processed
        final totalDelay = lines.length * 50 + 100;
        Future.delayed(Duration(milliseconds: totalDelay), () {
          onComplete();
        });

        return metadata;
      }

      return null;
    } catch (e) {
      print('Error parsing streaming response: $e');
      return null;
    }
  }

  // Clear stored token (delegate to TokenService)
  Future<void> clearToken() async {
    await TokenService.clearAllData();
  }

  // Check if user is authenticated (delegate to TokenService)
  Future<bool> isAuthenticated() async {
    return await TokenService.isAuthenticated();
  }

  // Helper method to remove text within square brackets
  String _removeSquareBrackets(String text) {
    if (text.isEmpty) {
      print('⚠️ WARNING: _removeSquareBrackets received empty text');
      return text;
    }

    // Print the original response with square brackets to terminal
    print('🟦 ORIGINAL RESPONSE WITH SQUARE BRACKETS:');
    print('📝 "$text"');
    print('🔢 Original length: ${text.length}');

    // Check if text is just metadata or has actual content
    final hasNonBracketContent =
        text.replaceAll(RegExp(r'\[.*?\]'), '').trim().isNotEmpty;

    if (!hasNonBracketContent) {
      print('⚠️ WARNING: Text appears to be only metadata/structured data');
      print('🔄 Returning original text to preserve content');
      return text; // Return original if it's all structured data
    }

    // Remove all content within square brackets including the brackets themselves
    final cleanedText = text.replaceAll(RegExp(r'\[.*?\]'), '').trim();

    print('🟩 CLEANED RESPONSE (brackets removed):');
    print('📝 "$cleanedText"');
    print('🔢 Cleaned length: ${cleanedText.length}');

    // Check if all content was within brackets
    if (cleanedText.isEmpty && text.isNotEmpty) {
      print(
          '⚠️ WARNING: All content was within square brackets! Original: "$text"');
      print('🔄 Returning original text as fallback to prevent empty response');
      return text; // Return original text as fallback
    }

    print(''); // Empty line for better readability

    return cleanedText;
  }

  // Get audio URL for a specific message or general audio
  String getAudioUrl([String? messageText]) {
    if (messageText != null && messageText.isNotEmpty) {
      // Clean the message text first by removing square brackets
      final cleanedText = _removeSquareBrackets(messageText);

      // URL encode the cleaned message text to handle special characters
      final encodedText = Uri.encodeComponent(cleanedText);
      final fullUrl = '$audioUrl?text=$encodedText';
      print('Generated audio URL: $fullUrl');
      return fullUrl;
    }
    print('Using default audio URL: $audioUrl');
    return audioUrl;
  }

  // Test method to debug API responses
  Future<void> testApiResponse(String testMessage) async {
    print('🧪 Testing API response with message: "$testMessage"');

    try {
      final token = await TokenService.getBackendToken();
      if (token == null) {
        print('❌ No token available for testing');
        return;
      }

      print('🧪 Making test request to: $baseUrl/chat/');

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'Flutter-Test-App/1.0',
            },
            body: jsonEncode({
              'message': testMessage,
              'message_type': 'text',
            }),
          )
          .timeout(Duration(seconds: 30));

      print('🧪 Test Response Status: ${response.statusCode}');
      print('🧪 Test Response Headers: ${response.headers}');
      print('🧪 Test Response Body Length: ${response.body.length}');
      print('🧪 Test Response Body: "${response.body}"');

      if (response.statusCode == 200) {
        final parsed = _parseStreamingResponse(response.body, 'text');
        print('🧪 Test Parsed Result: $parsed');
      }
    } catch (e) {
      print('❌ Test API call failed: $e');
    }
  }
}

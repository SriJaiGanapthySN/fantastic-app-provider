import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'token_service.dart';

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
      final token = await TokenService.getToken();
      if (token == null) {
        print('No token available for fetching messages');
        return [];
      }

      print('Fetching messages from server...');

      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
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
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // Send message to API and return parsed streaming response
  Future<Map<String, dynamic>?> sendMessage(String message,
      {String inputType = 'text'}) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return null;

      print('Sending message: $message (input type: $inputType)');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'message_type': inputType == 'voice' ? 'voice' : 'text',
        }),
      );

      print('Send message response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseStreamingResponse(response.body, inputType);
      }

      print('Send message failed with status: ${response.statusCode}');
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
      final token = await TokenService.getToken();
      if (token == null) return null;

      print(
          'Sending message with streaming: $message (input type: $inputType)');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'message_type': inputType == 'voice' ? 'voice' : 'text',
        }),
      );

      print('Send message response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseStreamingResponseWithCallback(
            response.body, onChunk, onComplete, inputType);
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
      final lines = responseBody.trim().split('\n');
      Map<String, dynamic>? metadata;
      final messageChunks = <String>[];

      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final content = line.substring(6); // Remove "data: " prefix

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
              // Not JSON, treat as text chunk
            }
          }

          // Collect text chunks for the AI message
          messageChunks.add(content);
        }
      }

      // Combine all message chunks
      final fullAiMessage = messageChunks.join('');
      print('🤖 Complete AI message: $fullAiMessage');

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

        return metadata;
      }

      return null;
    } catch (e) {
      print('Error parsing streaming response: $e');
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
      final lines = responseBody.trim().split('\n');
      Map<String, dynamic>? metadata;

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
              print('📋 Parsed metadata: $metadata');
              continue;
            } catch (e) {
              // Not JSON, treat as text chunk
            }
          }

          // Send each text chunk with a delay to simulate real-time streaming
          Future.delayed(Duration(milliseconds: i * 50), () {
            onChunk(content);
          });
        }
      }

      // Call completion callback after all chunks are processed
      final totalDelay = lines.length * 50 + 100;
      Future.delayed(Duration(milliseconds: totalDelay), () {
        onComplete();
      });

      return metadata;
    } catch (e) {
      print('Error parsing streaming response with callback: $e');
      onComplete();
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

  // Get audio URL for a specific message or general audio
  String getAudioUrl([String? messageText]) {
    if (messageText != null && messageText.isNotEmpty) {
      // URL encode the message text to handle special characters
      final encodedText = Uri.encodeComponent(messageText);
      final fullUrl = '$audioUrl?text=$encodedText';
      print('Generated audio URL: $fullUrl');
      return fullUrl;
    }
    print('Using default audio URL: $audioUrl');
    return audioUrl;
  }
}

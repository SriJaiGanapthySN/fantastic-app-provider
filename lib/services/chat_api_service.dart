import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatApiService {
  static const String baseUrl = 'https://mental-health.rohanrichard.com';
  static const String audioUrl = 'https://mental-health.rohanrichard.com/audio';
  static const String tokenKey = 'access_token';

  // Store access token
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Get stored access token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Authenticate and get access token
  Future<String?> authenticate(String email, String password) async {
    try {
      print('🔐 Authenticating user: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/token'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        print('✅ Authentication successful!');
        await _storeToken(token);
        return token;
      } else {
        print('❌ Authentication failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Authentication error: $e');
      return null;
    }
  }

  // Fetch existing messages
  Future<List<ChatMessage>> fetchMessages() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesJson = data['messages'] as List<dynamic>;
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch messages error: $e');
      return [];
    }
  }

  // Send message to API and return parsed streaming response
  Future<Map<String, dynamic>?> sendMessage(String message,
      {String inputType = 'text'}) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      print('📤 Sending message: $message (input type: $inputType)');

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

      print('📥 Send message response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseStreamingResponse(response.body, inputType);
      }

      print('❌ Send message failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('💥 Send message error: $e');
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
      final token = await _getToken();
      if (token == null) return null;

      print(
          '📤 Sending message with streaming: $message (input type: $inputType)');

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

      print('📥 Send message response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseStreamingResponseWithCallback(
            response.body, onChunk, onComplete, inputType);
      }

      print('❌ Send message failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('💥 Send message error: $e');
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
              '✅ Successfully parsed streaming response with audio URL for voice input');
        } else {
          print(
              '✅ Successfully parsed streaming response for text input (no audio)');
        }

        return metadata;
      }

      return null;
    } catch (e) {
      print('💥 Error parsing streaming response: $e');
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
      print('💥 Error parsing streaming response with callback: $e');
      onComplete();
      return null;
    }
  }

  // Clear stored token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  // Get audio URL for a specific message or general audio
  String getAudioUrl([String? messageText]) {
    if (messageText != null && messageText.isNotEmpty) {
      // URL encode the message text to handle special characters
      final encodedText = Uri.encodeComponent(messageText);
      final fullUrl = '$audioUrl?text=$encodedText';
      print('🎵 Generated audio URL: $fullUrl');
      return fullUrl;
    }
    print('🎵 Using default audio URL: $audioUrl');
    return audioUrl;
  }
}

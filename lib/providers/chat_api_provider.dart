import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_api_service.dart';
import '../models/chat_message.dart';

final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  return ChatApiService();
});

// Provider to track authentication status
final authStatusProvider = StateProvider<bool>((ref) => false);

// Provider for loading states
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for API messages
final apiMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

// Provider for authentication errors
final authErrorProvider = StateProvider<String?>((ref) => null);

// Provider for current user password (you might want to handle this differently)
final userPasswordProvider = StateProvider<String?>((ref) => null);
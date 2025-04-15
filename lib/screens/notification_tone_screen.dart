import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/notification_tone_provider.dart';
import '../models/notification_tone.dart';

class NotificationToneScreen extends ConsumerStatefulWidget {
  const NotificationToneScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationToneScreen> createState() => _NotificationToneScreenState();
}

class _NotificationToneScreenState extends ConsumerState<NotificationToneScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTone(NotificationTone tone) async {
    if (_currentlyPlayingId == tone.id) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
    } else {
      try {
        await _audioPlayer.stop(); // Stop any currently playing audio
        await _audioPlayer.play(AssetSource(tone.audioPath));
        setState(() => _currentlyPlayingId = tone.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing tone: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _stopPlaying() async {
    if (_currentlyPlayingId != null) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationTonesState = ref.watch(notificationTonesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () {
            _stopPlaying();
            Navigator.pop(context);
          },
        ),
        title: const Text('Notification Tone'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Toggle button for sample data
          Consumer(
            builder: (context, ref, child) {
              final useSampleData = ref.watch(useSampleDataProvider);
              return Switch(
                value: useSampleData,
                onChanged: (value) {
                  ref.read(useSampleDataProvider.notifier).state = value;
                  ref.read(notificationTonesProvider.notifier).loadNotificationTones();
                },
                activeColor: Colors.pink,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: notificationTonesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
        data: (tones) {
          final categories = ref.read(notificationTonesProvider.notifier).getCategories();
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryTones = ref.read(notificationTonesProvider.notifier)
                  .getTonesByCategory(category);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ...categoryTones.map((tone) => GestureDetector(
                    onTap: () async {
                      // Stop any playing tone first
                      await _stopPlaying();
                      // Update selection
                      await ref.read(notificationTonesProvider.notifier)
                          .updateSelectedTone(tone.id);
                    },
                    onLongPress: () => _playTone(tone),
                    onLongPressEnd: (details) => _stopPlaying(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          tone.name,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: tone.isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        trailing: tone.isSelected
                          ? const Icon(Icons.check, color: Colors.pink)
                          : null,
                      ),
                    ),
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 
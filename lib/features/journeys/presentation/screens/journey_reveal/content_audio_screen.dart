import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../data/services/journey_service.dart';

class ContentAudioScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> audioData;
  const ContentAudioScreen({Key? key, required this.audioData})
      : super(key: key);

  @override
  ConsumerState<ContentAudioScreen> createState() => _ContentAudioScreenState();
}

class _ContentAudioScreenState extends ConsumerState<ContentAudioScreen> {
  late final AudioPlayer _audioPlayer;
  bool _isAudioLoading = false;
  bool _isAudioError = false;
  String? _fetchedHtml;
  bool _isLoadingHtml = false;
  String? _htmlError;
  bool _isCompletedToday = false;
  bool _isSaving = false;
  final JourneyService _journeyService = JourneyService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    final String? audioUrl = widget.audioData['audioUrl'] as String?;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      _loadAudio(audioUrl);
    }
    final String? contentUrl = widget.audioData['contentUrl'] as String?;
    if (contentUrl != null && contentUrl.isNotEmpty) {
      _fetchAndParseHtml(contentUrl);
    }
    _checkIfCompletedToday();
  }

  Future<void> _loadAudio(String url) async {
    setState(() {
      _isAudioLoading = true;
      _isAudioError = false;
    });
    try {
      await _audioPlayer.setUrl(url);
      setState(() {
        _isAudioLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAudioLoading = false;
        _isAudioError = true;
      });
    }
  }

  Future<void> _fetchAndParseHtml(String url) async {
    setState(() {
      _isLoadingHtml = true;
      _htmlError = null;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String html = response.body;
        // Get user email from provider
        final email = ref.read(currentEmailProvider);
        String userName = 'User';
        if (email.isNotEmpty && email.contains('@')) {
          userName = email.split('@')[0];
        }
        html = html.replaceAll('{{NAME}}', userName);
        setState(() {
          _fetchedHtml = html;
          _isLoadingHtml = false;
        });
      } else {
        setState(() {
          _htmlError = 'Failed to load content (Status ${response.statusCode})';
          _isLoadingHtml = false;
        });
      }
    } catch (e) {
      setState(() {
        _htmlError = 'Failed to load content: $e';
        _isLoadingHtml = false;
      });
    }
  }

  Future<void> _checkIfCompletedToday() async {
    final email = ref.read(currentEmailProvider);
    final skillLevelId =
        widget.audioData['objectId'] ?? widget.audioData['skillLevelId'];
    if (email.isEmpty || skillLevelId == null) return;
    final completed =
        await _journeyService.isSkillLevelCompleted(email, skillLevelId);
    if (completed) {
      setState(() {
        _isCompletedToday = true;
      });
    }
  }

  Future<void> _handleDonePressed() async {
    setState(() {
      _isSaving = true;
    });
    final email = ref.read(currentEmailProvider);
    final goalId = widget.audioData['goalId'] ?? '';
    final skillLevelId = widget.audioData['objectId'] ?? '';
    final skillId = widget.audioData['skillId'] ?? '';
    final skillTrackId = widget.audioData['skillTrackId'] ?? '';
    final success = await _journeyService.updateGoalCompletion(
      email,
      goalId,
      skillLevelId,
      skillId,
      skillTrackId,
    );
    setState(() {
      _isSaving = false;
      if (success) _isCompletedToday = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Marked as completed!'
              : 'Failed to mark as completed.')),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String contentTitle = widget.audioData['contentTitle'] ?? 'No Title';
    final String readingTime = widget.audioData['contentReadingTime'] ?? '';
    final String? rawHeadline = widget.audioData['headline'] as String?;
    // Get user email from provider
    final email = ref.read(currentEmailProvider);
    String userName = 'User';
    if (email.isNotEmpty && email.contains('@')) {
      userName = email.split('@')[0];
    }
    final String? headline = rawHeadline?.replaceAll('{{NAME}}', userName);
    final String? headlineImageUrl =
        widget.audioData['headlineImageUrl'] as String?;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFe0eafc),
                  Color(0xFFcfdef3),
                  Color(0xFFf9fafc),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 64), // Padding for back arrow
                      // Title centered
                      Text(
                        contentTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.1,
                        ),
                      ),
                      // Time right-aligned below title
                      if (readingTime.isNotEmpty)
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 18, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Text(
                                  readingTime,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Headline image
                      if (headlineImageUrl != null &&
                          headlineImageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              headlineImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey.shade400, size: 50),
                              ),
                            ),
                          ),
                        ),
                      // Headline text
                      if (headline != null && headline.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            headline,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      // Audio player
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: _isAudioLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _isAudioError
                                  ? const Text('Failed to load audio',
                                      style: TextStyle(color: Colors.red))
                                  : _buildAudioPlayer(),
                        ),
                      ),
                      // Parsed HTML content
                      if (_isLoadingHtml)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_htmlError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_htmlError!,
                              style: TextStyle(color: Colors.red)),
                        ),
                      if (_fetchedHtml != null && _htmlError == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Html(
                            data: _fetchedHtml!,
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                color: Colors.black87,
                                lineHeight: const LineHeight(1.5),
                              ),
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: ElevatedButton(
                          onPressed: _isCompletedToday || _isSaving
                              ? null
                              : _handleDonePressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: _isCompletedToday
                              ? const Text('Completed')
                              : _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text("Done, what's next?"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final playing = playerState?.playing ?? false;
            final processingState = playerState?.processingState;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              );
            } else if (playing) {
              return IconButton(
                icon: const Icon(Icons.pause_circle_filled,
                    size: 48, color: Colors.blueAccent),
                onPressed: _audioPlayer.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.play_circle_fill,
                    size: 48, color: Colors.blueAccent),
                onPressed: _audioPlayer.play,
              );
            }
          },
        ),
        const SizedBox(width: 16),
        StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = _audioPlayer.duration ?? Duration.zero;
            return Text(
              '${_formatDuration(position)} / ${_formatDuration(duration)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

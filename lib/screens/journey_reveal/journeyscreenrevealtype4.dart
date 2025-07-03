import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/journey_service.dart';

class PagedContentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> goalData;

  const PagedContentScreen({
    super.key,
    required this.goalData,
  });

  @override
  ConsumerState<PagedContentScreen> createState() => _PagedContentScreenState();
}

class _PagedContentScreenState extends ConsumerState<PagedContentScreen> {
  late final PageController _pageController;
  late final List<dynamic> _pages;
  int _currentPageIndex = 0;
  bool _isCompleted = false;
  bool _isSaving = false;
  final JourneyService _journeyService = JourneyService();

  final String _userName = "Alex";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final pagedContent = widget.goalData['pagedContent'];
    dynamic pages;
    if (pagedContent is String) {
      try {
        final decoded = jsonDecode(pagedContent);
        pages = decoded['pages'];
      } catch (e) {
        pages = [];
      }
    } else if (pagedContent is Map && pagedContent['pages'] is List) {
      pages = pagedContent['pages'];
    } else {
      pages = [];
    }
    _pages = pages ?? [];
    _checkIfCompleted();
  }

  Future<void> _checkIfCompleted() async {
    final email = ref.read(currentEmailProvider);
    final skillLevelId = widget.goalData['objectId'] ?? widget.goalData['skillLevelId'];
    if (email.isEmpty || skillLevelId == null) return;
    final completed = await _journeyService.isSkillLevelCompleted(email, skillLevelId);
    if (completed) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  Future<void> _handleDonePressed() async {
    setState(() { _isSaving = true; });
    final email = ref.read(currentEmailProvider);
    final goalId = widget.goalData['goalId'] ?? '';
    final skillLevelId = widget.goalData['objectId'] ?? '';
    final skillId = widget.goalData['skillId'] ?? '';
    final skillTrackId = widget.goalData['skillTrackId'] ?? '';
    final success = await _journeyService.updateGoalCompletion(
      email, goalId, skillLevelId, skillId, skillTrackId,
    );
    setState(() {
      _isSaving = false;
      if (success) _isCompleted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Marked as completed!' : 'Failed to mark as completed.')),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String contentTitle = widget.goalData['contentTitle'] ?? 'No Title';
    final String readingTime = widget.goalData['contentReadingTime'] ?? '';
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 18, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    readingTime,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.blueGrey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 500,
                            ),
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              color: Colors.white.withOpacity(0.95),
                              shadowColor: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _pages.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final pageData = _pages[index];
                                    return _buildPageContent(pageData);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_pages.length > 1) _buildPageIndicator(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: ElevatedButton(
                          onPressed: _isCompleted || _isSaving ? null : _handleDonePressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: _isCompleted
                              ? const Text('Completed')
                              : _isSaving
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

  Widget _buildPageContent(Map<String, dynamic> pageData) {
    final String htmlText = (pageData['text'] as String? ?? '').replaceAll('{{NAME}}', _userName);
    final String mediaType = pageData['mediaType'] ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (mediaType == 'IMAGE') ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              'https://picsum.photos/seed/${pageData['id']}/800/400',
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator())
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 50),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        Html(
          data: htmlText,
          style: {
            "body": Style(
              fontSize: FontSize(18.0),
              lineHeight: const LineHeight(1.7),
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            "em": Style(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
          },
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        bool isActive = _currentPageIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          width: isActive ? 32.0 : 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
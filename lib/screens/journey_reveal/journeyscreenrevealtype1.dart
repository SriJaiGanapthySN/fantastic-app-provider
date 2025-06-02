import 'package:flutter/material.dart';
import 'package:fantastic_app_riverpod/models/skill.dart'; // Your Skill model
import 'package:fantastic_app_riverpod/models/skillTrack.dart'; // Your skillTrack model
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart'; // For rendering HTML
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http; // For fetching HTML content
import 'dart:convert'; // For jsonDecode if pagedContent is used as fallback

// AppColors class to hold color constants
class AppColors {
  static const Color primaryColor = Color(0xFF00C89C); // Teal button color
  static const Color textColor = Color(0xFF333333); // Dark grey for main text
  static const Color lightTextColor = Color(0xFF8A8A8A); // Lighter grey for date/time
  static const Color cardBackground = Colors.white;
  static const Color pageBackground = Color(0xFFF5F5F5); // Or a darker color if image is primary bg
  static const Color flourishColor = Color(0xFF275D7A); // Dark blue flourish color
  static const Color imageOverlayText = Colors.white;
}

class JourneyRevealType1 extends StatefulWidget {
  final Map<String, dynamic> letterData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const JourneyRevealType1({
    Key? key,
    required this.letterData,
    required this.skill,
    required this.email,
    required this.skilltrack,
  }) : super(key: key);

  @override
  State<JourneyRevealType1> createState() => _JourneyRevealType1State();
}

class _JourneyRevealType1State extends State<JourneyRevealType1> {
  String? _htmlContent;
  bool _isLoading = true;
  String _userName = "User"; // Default username

  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;

  static const String _flourishAssetPath = 'assets/images/decorative_flourish.png'; // Ensure this asset exists

  @override
  void initState() {
    super.initState();
    if (widget.email.isNotEmpty) {
      if (widget.email.contains('@')) {
        _userName = widget.email.split('@').first;
      } else {
        _userName = widget.email;
      }
      if (_userName.isNotEmpty) {
        _userName = _userName[0].toUpperCase() + _userName.substring(1);
      } else {
        _userName = "User";
      }
    } else {
      _userName = "User";
    }

    _loadContent();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_showButton && _scrollController.offset > 50.0) {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    }
    // Optional: hide button if scrolled back to top
    // else if (_showButton && _scrollController.offset <= 0.0) { // Changed to 0 or small threshold
    //   if (mounted) {
    //     setState(() {
    //       _showButton = false;
    //     });
    //   }
    // }
  }

  Future<void> _loadContent() async {
    final String? contentUrl = widget.letterData['contentUrl'] as String?;
    final String? pagedContentJson = widget.letterData['pagedContent'] as String?;

    if (contentUrl != null && contentUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(contentUrl));
        if (response.statusCode == 200) {
          String fetchedHtml = response.body;
          fetchedHtml = fetchedHtml.replaceAll('{{NAME}}', _userName);
          fetchedHtml = fetchedHtml.replaceAll('{{name}}', _userName.toLowerCase());
          if (mounted) {
            setState(() {
              _htmlContent = fetchedHtml;
              _isLoading = false;
            });
          }
        } else {
          _tryPagedContentFallback(pagedContentJson);
        }
      } catch (e) {
        print("Error fetching HTML content: $e");
        _tryPagedContentFallback(pagedContentJson);
      }
    } else {
      _tryPagedContentFallback(pagedContentJson);
    }
  }

  void _tryPagedContentFallback(String? pagedContentJson) {
    StringBuffer sb = StringBuffer();
    if (pagedContentJson != null && pagedContentJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(pagedContentJson);
        if (decoded is Map && decoded.containsKey('pages') && decoded['pages'] is List) {
          for (var page in decoded['pages']) {
            if (page is Map && page.containsKey('text')) {
              sb.writeln("<p>${page['text']}</p>");
            }
          }
        }
      } catch (e) {
        print("Error parsing pagedContent: $e");
      }
    }

    if (sb.isNotEmpty) {
      String content = sb.toString();
      content = content.replaceAll('{{NAME}}', _userName);
      content = content.replaceAll('{{name}}', _userName.toLowerCase());
      if (mounted) {
        setState(() {
          _htmlContent = content;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _htmlContent = "<p>Dear $_userName,</p><p>Content could not be loaded. Please try again later.</p>";
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    try {
      final int ms;
      if (timestamp is String) {
        ms = int.tryParse(timestamp) ?? DateTime.now().millisecondsSinceEpoch;
      } else if (timestamp is num) {
        ms = timestamp.toInt();
      } else {
        return "N/A";
      }
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateFormat('d MMMM yyyy').format(dateTime);
    } catch (e) {
      print("Error formatting date: $e, timestamp: $timestamp");
      return "N/A";
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String headlineImageUrl = widget.letterData['headlineImageUrl'] as String? ?? '';
    final String letterNumberText = "Letter no. ${widget.letterData['position'] ?? 'N/A'}";
    final String displayContentTitle = widget.letterData['contentTitle'] as String? ?? widget.skill.title;
    final String dateText = _formatDate(widget.letterData['createdAt']);
    final String readingTime = "${widget.letterData['contentReadingTime'] ?? 'N/A'}";

    String finalHtmlContent = _htmlContent ?? "";
    if (_isLoading) {
      finalHtmlContent = "";
    }

    return Scaffold(
      // Using a darker page background can make the white text container pop more.
      // Or keep it AppColors.pageBackground if the image is the main visual.
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : AppColors.pageBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image Area ---
                SizedBox( // Define a height for the image area
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (headlineImageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: headlineImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.blueGrey[700],
                            child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
                          ),
                        )
                      else
                        Container(color: Colors.blueGrey[800]),

                      Container( // Gradient overlay
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned( // Back Button
                        top: MediaQuery.of(context).padding.top + 4,
                        left: 4,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.imageOverlayText, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Positioned( // Titles
                        bottom: 20,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              letterNumberText,
                              style: TextStyle(
                                color: AppColors.imageOverlayText.withOpacity(0.85),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayContentTitle,
                              style: const TextStyle(
                                  color: AppColors.imageOverlayText,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(1,1))
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned( // Top Right Icons
                        top: MediaQuery.of(context).padding.top + 4,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined, color: AppColors.imageOverlayText, size: 24),
                              onPressed: () { /* Implement share */ },
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: AppColors.imageOverlayText, size: 28),
                              onPressed: () { /* Implement checkmark action */ },
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: AppColors.imageOverlayText, size: 26),
                              onPressed: () { /* Implement more options */ },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Text Container (Sharp Edges, Shadow) ---
                Container(
                  width: double.infinity, // Take full width
                  // No margin needed if it directly follows the image container
                  // margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Optional margin
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    // No borderRadius for sharp edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Softer shadow
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0), // Reduced bottom for SizedBox
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            _flourishAssetPath,
                            height: 22,
                            color: AppColors.flourishColor,
                            errorBuilder: (context, error, stackTrace) {
                              return Text('❦', style: TextStyle(color: AppColors.flourishColor, fontSize: 28));
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateText,
                              style: const TextStyle(color: AppColors.lightTextColor, fontSize: 13),
                            ),
                            Text(
                              (readingTime == "N/A" || readingTime.trim().isEmpty) ? "" : "$readingTime read",
                              style: const TextStyle(color: AppColors.lightTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(),
                        ))
                            : Html(
                          data: finalHtmlContent,
                          style: {
                            "body": Style(
                                fontSize: FontSize(15.5),
                                color: AppColors.textColor,
                                lineHeight: LineHeight.em(1.6),
                                margin: Margins.zero),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox to ensure content below text can scroll past the fixed button
                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),

          // --- Fixed Bottom Button ---
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: _showButton ? Offset.zero : const Offset(0, 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.98), // Solid or slightly transparent
                    // Optional: Top border or shadow to distinguish from content if needed
                    // border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5))
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Done! What's next?", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


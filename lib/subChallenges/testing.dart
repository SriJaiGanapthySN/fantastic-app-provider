import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For jsonDecode if needed

import '../providers/challengeProvider.dart';

class SkillLevelDetailScreen extends StatefulWidget {
  final String skillTrackId;
  const SkillLevelDetailScreen({Key? key, required this.skillTrackId}) : super(key: key);
  @override
  _SkillLevelDetailScreenState createState() => _SkillLevelDetailScreenState();
}

class _SkillLevelDetailScreenState extends State<SkillLevelDetailScreen> {
  late Future<SkillLevel?> _skillLevelFuture;
  late final WebViewController _webViewController;
  bool _isWebViewLoading = false;
  bool _contentLoadAttempted = false; // Renamed for clarity
  String? _htmlContentError; // To store potential fetching errors

  @override
  void initState() {
    super.initState();
    print('initState: Setting up SkillLevelDetailScreen for ${widget.skillTrackId}');

    // --- Initialize WebViewController (BEFORE fetching) ---
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {/* ... */},
          onPageStarted: (String url) {
            print('WebView started loading (likely base URL for loadHtmlString)');
            // For loadHtmlString, onPageStarted/Finished might be less relevant
            // unless the HTML itself navigates. Manage loading state manually.
          },
          onPageFinished: (String url) {
            print('WebView finished loading (likely base URL for loadHtmlString)');
            if (mounted) {
              setState(() { _isWebViewLoading = false; });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Resource Error: ${error.description}');
            if (mounted) {
              setState(() { _isWebViewLoading = false; });
            }
          },
          // No need for onNavigationRequest unless HTML content has links
        ),
      );

    // Fetch skill level data first
    _skillLevelFuture = getSkillLevelByTrackId(widget.skillTrackId);

    // After skill data is fetched, THEN fetch and load HTML content
    _skillLevelFuture.then((skillLevel) {
      if (mounted && skillLevel?.contentUrl != null) {
        print('SkillLevel data fetched, now fetching HTML from ${skillLevel!.contentUrl}');
        _fetchAndLoadHtml(skillLevel.contentUrl!);
      } else if (mounted) {
        print('SkillLevel fetch complete, but no contentUrl or widget unmounted.');
        setState(() { _isWebViewLoading = false; }); // Ensure loading stops
      }
    }).catchError((error) {
      print('Error fetching skill level data: $error');
      if (mounted) {
        setState(() {
          _isWebViewLoading = false;
          _htmlContentError = "Error fetching skill data.";
        });
      }
    });
  }

  // --- New Method to Fetch HTML and Load ---
  Future<void> _fetchAndLoadHtml(String url) async {
    if (_contentLoadAttempted) return;
    _contentLoadAttempted = true;

    if (mounted) {
      setState(() {
        _isWebViewLoading = true; // Start loading indicator
        _htmlContentError = null;   // Clear previous errors
      });
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return; // Check again after await

      if (response.statusCode == 200) {
        // --- SUCCESS ---
        String htmlString = response.body;

        // **Optional Check**: If you suspect the response is JSON containing HTML
        // String contentType = response.headers['content-type'] ?? '';
        // if (contentType.contains('application/json')) {
        //   try {
        //     var decodedJson = jsonDecode(response.body);
        //     // Assuming the HTML is in a field named 'htmlContent'
        //     htmlString = decodedJson['htmlContent'] as String? ?? 'Error: HTML field not found in JSON';
        //   } catch (e) {
        //      htmlString = 'Error parsing JSON response: $e';
        //   }
        // }

        print('HTML content fetched successfully, loading into WebView.');
        // Use loadHtmlString
        await _webViewController.loadHtmlString(htmlString);
        // Note: onPageFinished might fire shortly after this for the base load.
        // Setting _isWebViewLoading = false here might be too soon if the HTML
        // itself loads resources. Relying on onPageFinished is safer.
        // Let NavigationDelegate handle setting _isWebViewLoading to false on finish

      } else {
        // --- HTTP Error ---
        print('Failed to load HTML content. Status code: ${response.statusCode}');
        setState(() {
          _htmlContentError = 'Failed to load content (Code: ${response.statusCode})';
          _isWebViewLoading = false;
        });
      }
    } catch (e) {
      // --- Network or other error ---
      print('Error fetching HTML content: $e');
      if (mounted) {
        setState(() {
          _htmlContentError = 'Error fetching content: $e';
          _isWebViewLoading = false;
        });
      }
    }
    // Do NOT set _isWebViewLoading = false here necessarily, let onPageFinished handle it
    // unless there was an immediate error before even calling loadHtmlString.
  }


  @override
  Widget build(BuildContext context) {
    print('Building SkillLevelDetailScreen widget...');
    return Scaffold(
      appBar: AppBar(title: Text('Skill Level Details')),
      body: FutureBuilder<SkillLevel?>(
        future: _skillLevelFuture,
        builder: (context, snapshot) {
          // ... (Handle Future loading/error/no data for SKILL LEVEL data itself) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading skill base data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Skill Level with ID ${widget.skillTrackId} not found.'));
          }

          final skillLevel = snapshot.data!;

          // --- UI Structure ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Image, Headline, Type, Position) ...

                Divider(height: 24),

                // --- WebView Section ---
                Text('Content:', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),

                // Display error OR loading indicator OR WebView
                if (_htmlContentError != null) // Show error if fetching failed
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('Error: $_htmlContentError', style: TextStyle(color: Colors.red))),
                  )
                else if (skillLevel.contentUrl != null && skillLevel.contentUrl!.isNotEmpty) // Only show WebView area if URL exists
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Stack(
                      children: [
                        // Key is important if the underlying data changes dramatically
                        WebViewWidget(key: ValueKey(skillLevel.contentUrl), controller: _webViewController),
                        if (_isWebViewLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  )
                else // Message if no URL provided
                  Text('No content URL provided.', style: TextStyle(fontStyle: FontStyle.italic)),


                Divider(height: 24),

                // --- Other Details ---
                // ... (Track ID, Skill ID, etc.) ...

              ],
            ),
          );
        },
      ),
    );
  }
}
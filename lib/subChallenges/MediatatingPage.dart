import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For potential future asset loading (though not used in remove-only)
import 'package:webview_flutter/webview_flutter.dart'; // Import WebView
import 'package:http/http.dart' as http;             // Import HTTP client
import 'dart:async';                                // For TimeoutException
import 'package:html/parser.dart' as html_parser;      // For parsing HTML

// TODO: Ensure these are correctly defined and imported
import '../providers/challengeProvider.dart'; // Needed for getSkillLevelByTrackId and SkillLevel model
import 'MeditateTask.dart'; // Assuming GoalScreen is here

class MeditationActionScreen extends StatefulWidget {
  final String imageUrl; // Background image URL (Remains separate)
  final String objectId; // ID to fetch SkillLevel details

  const MeditationActionScreen({
    super.key,
    required this.imageUrl, // Keep background image direct
    required this.objectId, // Use objectId to fetch content details
  });

  @override
  State<MeditationActionScreen> createState() => _MeditationActionScreenState();
}

class _MeditationActionScreenState extends State<MeditationActionScreen> {
  bool _isPlaying = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final double _minSheetSize = 0.13;
  final double _initialSheetSize = 0.13;
  final double _maxSheetSize = 0.85;

  // --- State for Fetched Data & WebView ---
  late Future<SkillLevel?> _skillLevelFuture;
  late final WebViewController _webViewController;
  bool _isWebViewLoading = false; // Tracks HTML loading state specifically
  bool _contentLoadAttempted = false;
  String? _htmlContentError; // Stores error related to initial fetch or HTML processing/loading

  // --- Static UI Text (Keep if needed) ---
  final String title = "Your First Action";
  final String subtitle = "Create a Meditation Habit";
  final String durationText = "(2 minutes)";
  final String letterDate = "December 25, 2024";
  final String letterReadTime = "3 min";
  final String letterSalutation = "Dear Reader,";

  @override
  void initState() {
    super.initState();
    print('MeditationActionScreen initState for objectId: ${widget.objectId}');

    // --- Initialize WebViewController ---
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Transparent background
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {/* Optional: Update progress indicator */},
          onPageStarted: (String url) {
            // May fire for the base URL of loadHtmlString
          },
          onPageFinished: (String url) {
            print("WebView finished loading base content.");
            // This confirms the cleaned HTML is loaded, now set loading to false
            if (mounted) {
              setState(() { _isWebViewLoading = false; });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // This might catch errors for resources *within* the HTML (images, etc.)
            // But the problematic file:/// links should have been removed.
            print('WebView Resource Error (post-cleaning): ${error.description} URL: ${error.url}');
            if (mounted) {
              // Only set error if critical or no other error exists yet
              if (_htmlContentError == null) {
                setState(() {
                  _htmlContentError = "Error loading content elements";
                  _isWebViewLoading = false; // Stop loading on resource error too
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate; // Allow loading other resources
          },
        ),
      );

    // Fetch initial skill level data using the objectId
    _skillLevelFuture = getSkillLevelByTrackId(widget.objectId);

    // After skill data is fetched, attempt to fetch and process HTML content
    _skillLevelFuture.then((skillLevel) {
      if (!mounted) return; // Widget disposed?

      if (skillLevel?.contentUrl != null) {
        final contentUrl = skillLevel!.contentUrl!;
        Uri? parsedUri = Uri.tryParse(contentUrl);
        // Validate the URL before proceeding
        if (contentUrl.isNotEmpty && parsedUri != null && (parsedUri.isScheme("http") || parsedUri.isScheme("https"))) {
          print('SkillLevel data fetched, now fetching HTML from $contentUrl');
          _fetchAndLoadHtml(contentUrl); // Start the HTML fetch & process
        } else {
          print('SkillLevel data fetched, but invalid contentUrl: $contentUrl');
          setState(() { _htmlContentError = "Invalid content URL found."; _isWebViewLoading = false; });
        }
      } else {
        print('SkillLevel fetch complete, but no contentUrl found or skillLevel is null.');
        setState(() { _htmlContentError = "Content details not available."; _isWebViewLoading = false; });
      }
    }).catchError((error) {
      // Handle errors during the initial SkillLevel fetch
      print('Error fetching initial skill level data: $error');
      if (mounted) {
        setState(() { _htmlContentError = "Failed to load details."; _isWebViewLoading = false; });
      }
    });
  }

  // --- Fetches HTML, removes problematic links, and loads it ---
  Future<void> _fetchAndLoadHtml(String url) async {
    if (_contentLoadAttempted || !mounted) return;
    _contentLoadAttempted = true;

    // Set loading state, clear previous HTML-specific errors
    setState(() {
      _isWebViewLoading = true;
      if (_htmlContentError != "Failed to load details." && _htmlContentError != "Content details not available." && _htmlContentError != "Invalid content URL found.") {
        _htmlContentError = null;
      }
    });

    try {
      // 1. Fetch HTML
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (!mounted) return;

      if (response.statusCode == 200) {
        String originalHtml = response.body;
        print('HTML content fetched successfully, removing local asset links...');

        // 2. Remove problematic file:/// links
        String cleanedHtml = _removeLocalAssetLinks(originalHtml);

        print('HTML link removal complete, loading cleaned content into WebView.');

        // 3. Load the CLEANED HTML string
        await _webViewController.loadHtmlString(cleanedHtml, baseUrl: url);
        // Let NavigationDelegate's onPageFinished handle setting _isWebViewLoading = false

      } else {
        // Handle HTTP error during fetch
        setState(() { _htmlContentError = 'Failed to load content (Code: ${response.statusCode})'; _isWebViewLoading = false; });
      }
    } catch (e) { // Catch errors during fetch OR processing (_removeLocalAssetLinks)
      if (!mounted) return;
      print("Error during fetch or processing: $e");
      setState(() {
        if (e is TimeoutException) { _htmlContentError = 'Content server timed out.'; }
        else if (e is http.ClientException) { _htmlContentError = 'Network error fetching content.';}
        // Check for error from HTML processing helper
        else if (e is Exception && e.toString().contains("Failed to process HTML")) { _htmlContentError = 'Could not prepare content.';}
        else { _htmlContentError = 'Could not process content.'; } // Generic
        _isWebViewLoading = false;
      });
    }
  }

  // --- Helper Function to REMOVE Local Asset Links ---
  String _removeLocalAssetLinks(String htmlContent) {
    try {
      var document = html_parser.parse(htmlContent);

      // Select link tags whose href starts with file:///android_asset/
      var linksToRemove = document.querySelectorAll('link[href^="file:///android_asset/"]');

      if (linksToRemove.isNotEmpty) {
        print("Found ${linksToRemove.length} local asset link(s) to remove.");
        for (var link in linksToRemove) {
          print("Removing link: ${link.outerHtml}");
          link.remove(); // Remove the tag from the document
        }
      } else {
        print("No local asset links found to remove.");
      }

      // Return the modified HTML
      return document.outerHtml;

    } catch (e) {
      print("Error parsing/modifying HTML to remove links: $e");
      // Return original HTML as a fallback if parsing fails? Or throw?
      // Throwing is better to indicate failure clearly.
      throw Exception("Failed to process HTML for link removal: $e");
    }
  }


  @override
  void dispose() {
    _sheetController.dispose();
    // It's generally good practice to clean up controllers, though WebViewController might handle itself
    // Consider adding: _webViewController = null; or similar if needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body content behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton( icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop(), ),
        actions: [
          IconButton( icon: const Icon(Icons.equalizer_rounded, color: Colors.white), onPressed: () { /* Action */ },),
          IconButton( icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () { /* Action */ },),
          IconButton( icon: const Icon(Icons.check, color: Colors.white), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> GoalScreen(skillTrackId: widget.objectId,))); }, ),
          IconButton( icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () { /* Action */ },),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Image (Uses direct imageUrl)
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey[800], child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 60))),
            ),
          ),

          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent, Colors.black.withOpacity(0.35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Overlay Text Content (Static)
          Positioned(
            top: topPadding + kToolbarHeight + (screenHeight * 0.03),
            left: 20,
            right: 20,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text( title, textAlign: TextAlign.center, style: TextStyle( color: Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.w500, shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],),),
                  const SizedBox(height: 10),
                  Text( subtitle, textAlign: TextAlign.center, style: TextStyle( color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, height: 1.2, shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 7)],),),
                  const SizedBox(height: 6),
                  Text( durationText, textAlign: TextAlign.center, style: TextStyle( color: Colors.white.withOpacity(0.9), fontSize: 19, fontWeight: FontWeight.w500, shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],),),
                ]
            ),
          ),

          // 4. Central Play/Pause Button
          Positioned(
            top: screenHeight * 0.5 - 45,
            left: screenWidth * 0.5 - 45,
            child: GestureDetector(
                onTap: () { setState(() { _isPlaying = !_isPlaying; }); },
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE91E63), shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.15), width: 3.0),
                      boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.45), blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 5) ) ]
                  ),
                  child: Center( child: Icon(_isPlaying ? Icons.pause_rounded : Icons.equalizer_rounded, color: Colors.white, size: 55,)),
                )
            ),
          ),

          // 5. Draggable Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _initialSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only( topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0),),
                  boxShadow: [ BoxShadow( color: Colors.black38, blurRadius: 18.0, spreadRadius: 0.0, offset: Offset(0, -6), ), ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only( topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0),),
                  child: ListView( // Using ListView for content scrolling
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 15.0),
                    children: [
                      // --- Handle/Hint ---
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_drop_up, color: Color(0xFFE91E63), size: 28,),
                            Text("READ THIS LETTER", style: TextStyle( color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.6, ),),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Expanded Content ---
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(letterDate, style: TextStyle( color: Colors.grey[500], fontSize: 13.5, ),),
                          Text(letterReadTime, style: TextStyle( color: Colors.grey[500], fontSize: 13.5, ),)
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        letterSalutation,
                        style: TextStyle( color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w500, ),
                      ),
                      const SizedBox(height: 16),

                      // --- WebView Section Replaces Title/Body ---
                      _buildWebViewContent(), // Add the helper widget here

                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for WebView/Loading/Error State ---
  Widget _buildWebViewContent() {
    // This helper function remains the same as the previous correct version
    return Container(
      constraints: const BoxConstraints(minHeight: 250), // Minimum height
      child: Builder(
          builder: (context) {
            // Check for any error first
            if (_htmlContentError != null) {
              return Center( child: Padding( padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0), child: Text( "Error: $_htmlContentError", textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 16), ),),);
            }
            // Check if HTML is loading
            else if (_isWebViewLoading) {
              return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: CircularProgressIndicator(color: Color(0xFFE91E63))));
            }
            // Check if we haven't even started loading HTML yet (waiting for initial fetch)
            else if (!_contentLoadAttempted && _htmlContentError == null) {
              return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text("Loading content...", style: TextStyle(color: Colors.grey))));
            }
            // If content attempted, no error, not loading -> Show WebView
            else if (_contentLoadAttempted && _htmlContentError == null && !_isWebViewLoading) {
              return SizedBox( // Give explicit height to WebView inside ListView
                height: MediaQuery.of(context).size.height * 0.6, // Example: 60% screen height. Adjust as needed.
                child: WebViewWidget(
                  key: ValueKey(widget.objectId + "_webview"), // Unique key
                  controller: _webViewController,
                ),
              );
            }
            // Fallback state
            else {
              return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text("Content not available.", style: TextStyle(color: Colors.grey))));
            }
          }
      ),
    );
  }
}
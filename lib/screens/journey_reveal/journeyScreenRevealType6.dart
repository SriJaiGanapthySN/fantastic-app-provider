import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';

// --- Model Classes ---
PagedContent pagedContentFromJson(String str) => PagedContent.fromJson(json.decode(str));
String pagedContentToJson(PagedContent data) => json.encode(data.toJson());

class PagedContent {
  List<PageItem> pages;

  PagedContent({
    required this.pages,
  });

  factory PagedContent.fromJson(Map<String, dynamic> json) => PagedContent(
    pages: List<PageItem>.from(json["pages"].map((x) => PageItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pages": List<dynamic>.from(pages.map((x) => x.toJson())),
  };
}

class PageItem {
  String id;
  String type;        // e.g., "textAndMedia", "questionChoice"
  String? text;       // HTML content for the page item, nullable
  String? mediaUrl;   // URL for media (image), nullable
  String? title;      // Title, especially for "questionChoice", nullable
  String? questionId; // questionId for "questionChoice", nullable

  PageItem({
    required this.id,
    required this.type,
    this.text,
    this.mediaUrl,
    this.title,
    this.questionId,
  });

  factory PageItem.fromJson(Map<String, dynamic> json) => PageItem(
    id: json["id"] as String,
    type: json["type"] as String,
    text: json["text"] as String?,
    mediaUrl: json["media"] as String?,
    title: json["title"] as String?,
    questionId: json["questionId"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "text": text,
    "media": mediaUrl,
    "title": title,
    "questionId": questionId,
  };
}

// --- MotivatorScreen Widget ---
class MotivatorScreen extends StatefulWidget {
  final Map<String, String> data;

  const MotivatorScreen({Key? key, required this.data}) : super(key: key);

  @override
  _MotivatorScreenState createState() => _MotivatorScreenState();
}

class _MotivatorScreenState extends State<MotivatorScreen> {
  late Future<String> _htmlContentFuture;
  PagedContent _pagedContent = PagedContent(pages: []); // Initialize with empty pages
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final String? contentUrl = widget.data['contentUrl'];
    if (contentUrl != null && contentUrl.isNotEmpty && Uri.tryParse(contentUrl)?.isAbsolute == true) {
      _htmlContentFuture = _fetchHtmlContent(contentUrl);
    } else {
      _htmlContentFuture = Future.value(""); // Treat as empty HTML to fall back to paged content
      print("No valid contentUrl provided or URL is invalid, will attempt to show paged content.");
    }

    try {
      final pagedContentString = widget.data['pagedContent'];
      if (pagedContentString != null && pagedContentString.isNotEmpty) {
        // This is where the JSON string is parsed
        _pagedContent = pagedContentFromJson(pagedContentString);
      } else {
        print("Paged content string is null or empty.");
        _pagedContent = PagedContent(pages: []);
      }
    } catch (e) {
      print("Error parsing pagedContent JSON string: $e");
      _pagedContent = PagedContent(pages: []); // Fallback to empty pages on error
    }
  }

  Future<String> _fetchHtmlContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load HTML content (status code: ${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching HTML: $e");
      throw Exception('Failed to load HTML content: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper to build content for each page item based on its type
  Widget _buildPageItemContent(BuildContext context, PageItem item) {
    List<Widget> children = [];

    // 1. Add Media (if available)
    if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              item.mediaUrl!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: 150, // Adjust as needed
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                );
              },
            ),
          ),
        ),
      );
    }

    // 2. Add Title (if available, especially for questionChoice)
    if (item.title != null && item.title!.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            item.title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: item.type == "questionChoice" ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    // 3. Add Text/HTML content (if available)
    if (item.text != null && item.text!.isNotEmpty) {
      children.add(
        Html(
          data: item.text!,
          style: {
            "body": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero, // Padding is handled by the Card
              fontSize: FontSize(15.0),
              lineHeight: LineHeight.em(1.4),
            ),
            "p": Style(margin: Margins.only(bottom: 8.0)),
            "em": Style(fontStyle: FontStyle.italic),
            // Add more styles as needed
          },
        ),
      );
    }

    // 4. Specific additions for 'questionChoice' type
    if (item.type == "questionChoice") {
      if (item.questionId != null) {
        children.add(const SizedBox(height: 10));
        children.add(Text("Ref ID: ${item.questionId}", style: TextStyle(fontSize: 12, color: Colors.grey[600])));
      }
      // Placeholder for actual interactive question elements
      children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "(Interactive question components would be rendered here based on question type/options)",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey.shade300, fontSize: 13),
            ),
          )
      );
    }

    if (children.isEmpty) {
      return const Center(child: Text("No displayable content for this item."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important for SingleChildScrollView
      children: children,
    );
  }


  @override
  Widget build(BuildContext context) {
    final headline = widget.data['headline'] ?? 'No Headline';
    final headlineImageUrl = widget.data['headlineImageUrl'];
    final contentTitle = widget.data['contentTitle'] ?? 'Content';

    return Scaffold(
      appBar: AppBar(
        title: Text(contentTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              headline,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (headlineImageUrl != null && headlineImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  headlineImageUrl,
                  fit: BoxFit.cover, width: double.infinity, height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(height: 200, width: double.infinity, color: Colors.grey[300], child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(height: 200, width: double.infinity, color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50))),
                ),
              ),
            if (headlineImageUrl != null && headlineImageUrl.isNotEmpty) const SizedBox(height: 20),

            FutureBuilder<String>(
              future: _htmlContentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final String? htmlData = snapshot.data;
                // Show HTML if data exists, is not null, and is not an empty/whitespace string
                final bool showHtml = snapshot.hasData && htmlData != null && htmlData.trim().isNotEmpty;

                if (showHtml) {
                  // --- Display HTML Content ---
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Main Content:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Html(
                          data: htmlData!,
                          style: {
                            "body": Style(margin: Margins.zero, padding: HtmlPaddings.all(16.0), fontSize: FontSize(16.0), lineHeight: LineHeight.em(1.5)),
                            "p": Style(margin: Margins.only(bottom: 10.0)),
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  // --- HTML content is not shown (error, null, or empty). Attempt to display Paged Content ---
                  if (snapshot.hasError) {
                    print("Error fetching HTML content: ${snapshot.error}. Will show paged content if available.");
                  } else if (snapshot.hasData && (htmlData == null || htmlData.trim().isEmpty)) {
                    print("HTML content is null or empty. Will show paged content if available.");
                  }

                  if (_pagedContent.pages.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (snapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text("Could not load main content. Displaying reflections:", style: TextStyle(color: Colors.orange.shade700, fontStyle: FontStyle.italic)),
                          ),
                        Text("Daily Reflections:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 380, // Adjusted height, may need further tuning
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pagedContent.pages.length,
                            itemBuilder: (context, index) {
                              final pageItem = _pagedContent.pages[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0), // Padding for card content
                                  child: SingleChildScrollView( // Ensure content is scrollable
                                    child: _buildPageItemContent(context, pageItem), // Use helper
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_pagedContent.pages.length > 1)
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController, count: _pagedContent.pages.length,
                              effect: WormEffect(dotHeight: 10, dotWidth: 10, activeDotColor: Theme.of(context).primaryColor, dotColor: Colors.grey.shade300),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    );
                  } else {
                    // --- Neither HTML nor Paged content is available ---
                    String message = 'No content available.';
                    if (snapshot.hasError) {
                      message = 'Error loading content: ${snapshot.error}.\nNo alternative content found.';
                    } else if (widget.data['contentUrl'] == null || widget.data['contentUrl']!.isEmpty) {
                      message = 'No main content URL provided and no paged content found.';
                    }
                    return Card(
                      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(message, style: TextStyle(color: snapshot.hasError ? Colors.red[700] : null)),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
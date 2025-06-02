import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http; // Import the http package

class Journeyscreentype3 extends StatefulWidget {
  final Map<String, dynamic> motivatorData;

  const Journeyscreentype3({
    Key? key,
    required this.motivatorData,
  }) : super(key: key);

  @override
  State<Journeyscreentype3> createState() => _Journeyscreentype3State();
}

class _Journeyscreentype3State extends State<Journeyscreentype3> {
  String? _resolvedHtmlContent;
  bool _isLoadingContent = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Ensure motivatorData and contentUrl are not null
    if (widget.motivatorData == null) {
      if (mounted) {
        setState(() {
          _resolvedHtmlContent = '<p>Error: Motivator data is null.</p>';
          _isLoadingContent = false;
        });
      }
      return;
    }

    final dynamic contentSource = widget.motivatorData['contentUrl'];

    if (contentSource == null || contentSource is! String || contentSource.isEmpty) {
      if (mounted) {
        setState(() {
          _resolvedHtmlContent = '<p>No content available.</p>';
          _isLoadingContent = false;
        });
      }
      return;
    }

    String contentUrlString = contentSource as String;

    // Check if it's a URL that needs fetching
    if (contentUrlString.trim().toLowerCase().startsWith('http://') ||
        contentUrlString.trim().toLowerCase().startsWith('https://')) {
      try {
        final response = await http.get(Uri.parse(contentUrlString));
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _resolvedHtmlContent = response.body;
              _isLoadingContent = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to load content (Status: ${response.statusCode})';
              _resolvedHtmlContent = '<p>Error: $_errorMessage</p>';
              _isLoadingContent = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error fetching content: $e';
            _resolvedHtmlContent = '<p>Error: $_errorMessage</p>';
            _isLoadingContent = false;
          });
        }
      }
    } else {
      // Assume it's direct HTML content
      if (mounted) {
        setState(() {
          _resolvedHtmlContent = contentUrlString;
          _isLoadingContent = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extracting data with fallbacks - ensure motivatorData is not null first
    final String headlineImageUrl = widget.motivatorData['headlineImageUrl'] ?? '';
    final String headline = widget.motivatorData['headline'] ?? 'No Headline';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black54),
            onPressed: () {
              print("Share button pressed for ${widget.motivatorData['objectId']}");
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (headlineImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: headlineImageUrl,
                fit: BoxFit.cover,
                height: 250,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600])),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
              child: Text(
                headline,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _isLoadingContent
                  ? Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ))
                  : Html(
                data: _resolvedHtmlContent ?? '<p>Content not available.</p>', // Fallback for safety
                style: {
                  "p": Style(
                    fontSize: FontSize(16.0),
                    lineHeight: LineHeight.em(1.5),
                    color: Colors.black.withOpacity(0.75),
                  ),
                  // You can add more styles for other HTML tags if needed
                  "a": Style(
                    color: Theme.of(context).colorScheme.secondary, // Example: make links use accent color
                    textDecoration: TextDecoration.underline,
                  ),
                  "h1": Style(fontSize: FontSize(22.0), fontWeight: FontWeight.bold),
                  "h2": Style(fontSize: FontSize(20.0), fontWeight: FontWeight.w600),
                  // Add other tags as needed
                },
              ),
            ),
            SizedBox(height: 80), // Space for the button at the bottom
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        color: Theme.of(context).scaffoldBackgroundColor, // Or Colors.white
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1DE9B6), // Teal color
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Done! What\'s next? ', style: TextStyle(color: Colors.white)),
              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
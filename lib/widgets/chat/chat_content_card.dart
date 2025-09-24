import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/content_card_service.dart';
import '../../utils/blur_container.dart';

class ChatContentCard extends StatelessWidget {
  final ContentCardData contentData;
  final String? userEmail;
  final VoidCallback? onTap;

  const ChatContentCard({
    Key? key,
    required this.contentData,
    this.userEmail,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = contentData.colorScheme;
    final primaryColor = Color(int.parse(colorScheme['primary']));
    final backgroundColor = Color(int.parse(colorScheme['background']));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: BlurContainer(
        blur: 35.87,
        borderRadius: 16.0,
        color: backgroundColor.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap ?? () => _handleNavigation(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        contentData.type.toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _getTypeIcon(),
                      color: primaryColor.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Content section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    _buildImage(),
                    const SizedBox(width: 16),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contentData.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contentData.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              contentData.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap ?? () => _handleNavigation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          contentData.actionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    const double imageSize = 80;

    if (contentData.imageUrl.isEmpty) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getTypeIcon(),
          color: Colors.white.withOpacity(0.6),
          size: 40,
        ),
      );
    }

    // Check if it's an SVG
    if (contentData.imageUrl.toLowerCase().endsWith('.svg')) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SvgPicture.network(
            contentData.imageUrl,
            width: imageSize - 32,
            height: imageSize - 32,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (context) => Icon(
              _getTypeIcon(),
              color: Colors.white.withOpacity(0.6),
              size: 32,
            ),
          ),
        ),
      );
    }

    // Regular image
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: contentData.imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(),
            color: Colors.white.withOpacity(0.6),
            size: 40,
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (contentData.type.toUpperCase()) {
      case 'HABIT':
        return Icons.psychology_rounded;
      case 'JOURNEY':
        return Icons.explore_rounded;
      case 'COACHING':
        return Icons.school_rounded;
      case 'CHALLENGE':
        return Icons.flag_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  void _handleNavigation(BuildContext context) {
    // TODO: Implement navigation based on content type
    print(
        '🎯 Navigating to ${contentData.type} with ID: ${contentData.objectId}');

    // Show a snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${contentData.type}: ${contentData.title}'),
        backgroundColor: Color(int.parse(contentData.colorScheme['primary'])),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget that automatically fetches and displays content based on objectId and type
class ChatContentCardLoader extends StatefulWidget {
  final String objectId;
  final String type;
  final String? userEmail;
  final VoidCallback? onTap;

  const ChatContentCardLoader({
    Key? key,
    required this.objectId,
    required this.type,
    this.userEmail,
    this.onTap,
  }) : super(key: key);

  @override
  State<ChatContentCardLoader> createState() => _ChatContentCardLoaderState();
}

class _ChatContentCardLoaderState extends State<ChatContentCardLoader> {
  ContentCardData? contentData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final data = await ContentCardService.getContentById(
        widget.objectId,
        widget.type,
      );

      if (mounted) {
        setState(() {
          contentData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: BlurContainer(
          blur: 35.87,
          borderRadius: 16.0,
          color: Colors.black.withOpacity(0.15),
          child: const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
          ),
        ),
      );
    }

    if (error != null || contentData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: BlurContainer(
          blur: 35.87,
          borderRadius: 16.0,
          color: Colors.red.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content not found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.type} with ID: ${widget.objectId}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChatContentCard(
      contentData: contentData!,
      userEmail: widget.userEmail,
      onTap: widget.onTap,
    );
  }
}

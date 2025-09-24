import 'package:flutter/material.dart';
import '../../services/bracketed_content_service.dart';

class BracketedContentDebugWidget extends StatefulWidget {
  const BracketedContentDebugWidget({Key? key}) : super(key: key);

  @override
  _BracketedContentDebugWidgetState createState() =>
      _BracketedContentDebugWidgetState();
}

class _BracketedContentDebugWidgetState
    extends State<BracketedContentDebugWidget> {
  @override
  Widget build(BuildContext context) {
    final responseModels = BracketedContentService.getAllResponseModels();
    final count = BracketedContentService.getStoredContentCount();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Bracketed Content Debug',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count stored',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (responseModels.isEmpty)
              Text(
                'No bracketed content stored yet',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...responseModels.entries.map((entry) {
                final messageId = entry.key;
                final responseModel = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message ID
                      Text(
                        'Message ID: $messageId',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Extracted Fields
                      if (responseModel.extractedFields.isNotEmpty) ...[
                        Text(
                          'Extracted Fields:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...responseModel.extractedFields.entries.map(
                          (fieldEntry) => Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 2),
                            child: Row(
                              children: [
                                Text(
                                  '${fieldEntry.key}:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fieldEntry.value.toString(),
                                    style: TextStyle(color: Colors.green[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Display Text
                      Text(
                        'Display Text:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          responseModel.displayText,
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),

                      // Actions
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _clearMessage(messageId),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearMessage(String messageId) {
    BracketedContentService.clearContent(messageId);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cleared content for message $messageId')),
    );
  }

  void _clearAll() {
    BracketedContentService.clearAllContent();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleared all bracketed content')),
    );
  }
}

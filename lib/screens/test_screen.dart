import 'package:flutter/material.dart';
import '../services/journey_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final JourneyService _journeyService = JourneyService();
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _testResults = null;
    });

    try {
      // Using the test user and skill track ID from your examples
      final results = await _journeyService.testCompletionFlow(
        'test03@gmail.com',
        '4tzpq7JxbS', // The skill track ID from your example
      );

      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error running test: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completion Flow Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runTest,
              child: Text(_isLoading ? 'Running Test...' : 'Run Test'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (_testResults != null) ...[
              const SizedBox(height: 16),
              Text('Test Results:'),
              const SizedBox(height: 8),
              Text('Success: ${_testResults!['success']}'),
              Text('Message: ${_testResults!['message']}'),
              const SizedBox(height: 16),
              Text('Initial Stats:'),
              Text('Levels Completed: ${_testResults!['initialStats']['levelsCompleted']}'),
              Text('Total Levels: ${_testResults!['initialStats']['skillLevelCount']}'),
              Text('Total Skills: ${_testResults!['initialStats']['skillCount']}'),
              const SizedBox(height: 16),
              Text('Final Stats:'),
              Text('Levels Completed: ${_testResults!['finalStats']['levelsCompleted']}'),
              Text('Total Levels: ${_testResults!['finalStats']['skillLevelCount']}'),
              Text('Total Skills: ${_testResults!['finalStats']['skillCount']}'),
              const SizedBox(height: 16),
              Text('Skill Level Details:'),
              Text('Completed: ${_testResults!['skillLevelCompleted']}'),
              Text('Skill Level ID: ${_testResults!['skillLevelId']}'),
              Text('Skill ID: ${_testResults!['skillId']}'),
            ],
          ],
        ),
      ),
    );
  }
} 
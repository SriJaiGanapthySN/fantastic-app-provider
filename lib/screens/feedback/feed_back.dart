import 'package:flutter/material.dart';
import '../../models/feedback.dart';

class FeedbackScreen extends StatefulWidget {
  final List<FeedbackQuestion> allQuestions;
  final int currentQuestionIndex;
  final Map<String, String> responses;

  const FeedbackScreen({
    Key? key,
    required this.allQuestions,
    this.currentQuestionIndex = 0,
    this.responses = const {},
  }) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? selectedLabel;
  late List<FeedbackQuestion> questions;
  late int currentIndex;
  late Map<String, String> userResponses;

  @override
  void initState() {
    super.initState();
    questions = widget.allQuestions;
    currentIndex = widget.currentQuestionIndex;
    userResponses = Map<String, String>.from(widget.responses);
  }

  void _selectOption(String label) {
    setState(() {
      selectedLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentIndex];
    final questionOptions =
        currentQuestion.options.map((option) => option.toMap()).toList();
    final isLastQuestion = currentIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currentIndex + 1}➜ ${currentQuestion.question}*',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 30),
              ...questionOptions.map((option) {
                final isSelected = selectedLabel == option['label'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: OutlinedButton(
                    onPressed: () => _selectOption(option['label']!),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      backgroundColor:
                          isSelected ? Colors.pink.shade50 : Colors.transparent,
                      side: BorderSide(color: Colors.pink.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            option['label']!,
                            style: TextStyle(color: Colors.pink),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          option['text']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLabel == null
                      ? null
                      : () {
                          // Save the current response
                          userResponses[currentQuestion.id] = selectedLabel!;

                          if (isLastQuestion) {
                            // All questions answered, return to main screen
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          } else {
                            // Navigate to the next question
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackScreen(
                                  allQuestions: questions,
                                  currentQuestionIndex: currentIndex + 1,
                                  responses: userResponses,
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'FINISH' : 'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

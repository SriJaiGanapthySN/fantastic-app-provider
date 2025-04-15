class FeedbackQuestion {
  final String id;
  final String question;
  final List<FeedbackOption> options;

  FeedbackQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class FeedbackOption {
  final String label;
  final String text;

  FeedbackOption({
    required this.label,
    required this.text,
  });

  Map<String, String> toMap() {
    return {
      'label': label,
      'text': text,
    };
  }
}

class FeedbackManager {
  static List<FeedbackQuestion> getAppFeedbackQuestions() {
    return [
      FeedbackQuestion(
        id: '1',
        question: 'How would you rate your overall experience with our app?',
        options: [
          FeedbackOption(label: 'A', text: 'Excellent'),
          FeedbackOption(label: 'B', text: 'Good'),
          FeedbackOption(label: 'C', text: 'Average'),
          FeedbackOption(label: 'D', text: 'Poor'),
          FeedbackOption(label: 'E', text: 'Very Poor'),
        ],
      ),
      FeedbackQuestion(
        id: '2',
        question: 'How easy is it to navigate through the app?',
        options: [
          FeedbackOption(label: 'A', text: 'Very Easy'),
          FeedbackOption(label: 'B', text: 'Easy'),
          FeedbackOption(label: 'C', text: 'Neutral'),
          FeedbackOption(label: 'D', text: 'Difficult'),
          FeedbackOption(label: 'E', text: 'Very Difficult'),
        ],
      ),
      FeedbackQuestion(
        id: '3',
        question: 'How helpful are the rituals and journeys in the app?',
        options: [
          FeedbackOption(label: 'A', text: 'Very Helpful'),
          FeedbackOption(label: 'B', text: 'Helpful'),
          FeedbackOption(label: 'C', text: 'Somewhat Helpful'),
          FeedbackOption(label: 'D', text: 'Not Very Helpful'),
          FeedbackOption(label: 'E', text: 'Not Helpful At All'),
        ],
      ),
      FeedbackQuestion(
        id: '4',
        question: 'Would you recommend this app to friends?',
        options: [
          FeedbackOption(label: 'A', text: 'Definitely'),
          FeedbackOption(label: 'B', text: 'Probably'),
          FeedbackOption(label: 'C', text: 'Maybe'),
          FeedbackOption(label: 'D', text: 'Probably Not'),
          FeedbackOption(label: 'E', text: 'Definitely Not'),
        ],
      ),
      FeedbackQuestion(
        id: '5',
        question: 'What feature would you like to see improved?',
        options: [
          FeedbackOption(label: 'A', text: 'Chat Feature'),
          FeedbackOption(label: 'B', text: 'Rituals'),
          FeedbackOption(label: 'C', text: 'Journey Path'),
          FeedbackOption(label: 'D', text: 'Discover Section'),
          FeedbackOption(label: 'E', text: 'User Interface'),
        ],
      ),
    ];
  }
}

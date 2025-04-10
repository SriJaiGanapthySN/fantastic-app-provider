class QuestionDetector {
  static const List<String> _questionWords = [
    "what",
    "where",
    "why",
    "how",
    "explain",
    "some tips",
    "give",
    "any",
    "advise me",
    "brief me",
    "share",
    "list",
    "can you",
    "can we",
    "could you",
    "could we",
    "do you",
    "i need",
    "suggest",
    "is it",
    "are we",
    "are you",
    "do you",
    "does anyone",
    "should i",
    "should we",
    "gonna",
    "wanna",
    "shall we",
    "shouldn't we",
    "wouldn't it",
    "haven't you",
    "hasn't she",
    "hasn't he",
    "hasn't it",
    "didn't she",
    "didn't he",
    "aren't",
    "would you",
    "will that work"
  ];

  /// Detect if the text is likely a question
  static bool isQuestion(String text) {
    text = text.trim().toLowerCase();

    // Check if text ends with question mark
    if (text.endsWith("?")) {
      return true;
    }

    // Check if the first word is a question word
    List<String> words = text.split(RegExp(r'\s+'));
    if (words.isNotEmpty && _questionWords.contains(words.first)) {
      return true;
    }

    return false;
  }
}

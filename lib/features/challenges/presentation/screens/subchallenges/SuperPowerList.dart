// In your SuperPowerList.dart file

class Superpowerlist {
  // --- Fields for the first popup ---
  final String imageAdd;
  final String text;
  final String Content;
  final String colorHex;

  // --- NEW: Fields for the second "how-to" popup ---
  final String popup2_title;
  final String popup2_content;
  final String popup2_imageAdd;
  final String popup2_primaryActionText;
  final String popup2_secondaryActionText;

  Superpowerlist({
    // Required fields for first popup
    required this.imageAdd,
    required this.text,
    required this.Content,
    required this.colorHex,
    // NEW: Required fields for second popup
    required this.popup2_title,
    required this.popup2_content,
    required this.popup2_imageAdd,
    required this.popup2_primaryActionText,
    required this.popup2_secondaryActionText,
  });
}

// The complete list with all the new content for the second popups
List<Superpowerlist> habitList = [
  // 1. Gratitude
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img.png',
    text: "Gratitude",
    Content: "Have you ever stopped to think how others have helped us? Not only does showing gratitude build relationships, it helps you achieve your goals.",
    colorHex: "#9B59B6",
    popup2_title: "How to express gratitude",
    popup2_content: "Think of someone who has been nice to you, even in the smallest way, and let them know. A simple text, call, or note is all it takes to make their day and reinforce your own positive mindset. This will help you achieve your goal.",
    popup2_imageAdd: 'assets/images/family.png',
    popup2_primaryActionText: "I WANT TO THANK SOMEONE!",
    popup2_secondaryActionText: "I DON'T WANT TO SHOW GRATITUDE",
  ),
  // 2. Mindful Ritual
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_1.png',
    text: "Mindful Ritual",
    Content: "Start your day with intention, not distraction. A mindful ritual grounds you and sets a calm, focused tone for the rest of your day.",
    colorHex: "#3498DB",
    popup2_title: "How to create a Ritual",
    popup2_content: "Start small. Choose a simple 1-minute activity, like deep breathing or savoring coffee. Link it to an existing habit (e.g., 'after I brush my teeth'). The key is to be fully present, without your phone or other distractions.",
    popup2_imageAdd: 'assets/images/mindful_ritual_detail.png',
    popup2_primaryActionText: "I'LL START MY RITUAL!",
    popup2_secondaryActionText: "I'LL SKIP THIS FOR NOW",
  ),
  // 3. Pay Challenge
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_2.png',
    text: "Pay Challenge",
    Content: "Raise the stakes to guarantee your success by making the cost of inaction greater than the effort of action.",
    colorHex: "#E74C3C",
    popup2_title: "How to set up a Challenge",
    popup2_content: "Find a trusted friend to act as your referee. Define one simple, daily rule (e.g., 'no junk food'). Set a penalty you genuinely want to avoid, like \$5. If you break the rule, you must pay them immediately. No excuses!",
    popup2_imageAdd: 'assets/images/pay_challenge_detail.png',
    popup2_primaryActionText: "I'M READY TO COMMIT!",
    popup2_secondaryActionText: "THIS IS TOO INTENSE",
  ),
  // 4. Ulysses Contract
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_3.png',
    text: "Ulysses Contract",
    Content: "Make your future self's success inevitable by making the right choice the only choice available.",
    colorHex: "#2C3E50",
    popup2_title: "How to make a Contract",
    popup2_content: "Identify a temptation that derails you. Now, create a rule that makes it impossible to give in. For example, to avoid social media, use an app blocker and set a password you don't know (give it to a friend).",
    popup2_imageAdd: 'assets/images/ulysses_detail.png',
    popup2_primaryActionText: "I'LL LOCK IN MY GOAL!",
    popup2_secondaryActionText: "I PREFER MORE FLEXIBILITY",
  ),
  // 5. Mirror Mirror
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_4.png',
    text: "Mirror Mirror",
    Content: "Your biggest cheerleader is staring right back at you. Vocalizing your ambitions reinforces them in your mind and builds confidence.",
    colorHex: "#F1C40F",
    popup2_title: "How to use the Mirror",
    popup2_content: "Every morning, look yourself in the eyes. Say one positive affirmation or state your main goal for the day out loud. For example: 'I will complete my workout today.' It feels silly at first, but it rewires your brain for success.",
    popup2_imageAdd: 'assets/images/mirror_detail.png',
    popup2_primaryActionText: "I'LL START AFFIRMING!",
    popup2_secondaryActionText: "I'M TOO SHY FOR THIS",
  ),
  // 6. Power Partner
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_5.png',
    text: "Power Partner",
    Content: "You don't have to build good habits alone. Knowing someone else is counting on you is a powerful motivator.",
    colorHex: "#2ECC71",
    popup2_title: "How to find a Partner",
    popup2_content: "Think of a friend who also wants to improve. Ask them to be your accountability partner. Schedule a 5-minute check-in call or text at the same time every day to report if you did your habit. Celebrate each other's wins!",
    popup2_imageAdd: 'assets/images/partner_detail.png',
    popup2_primaryActionText: "I'LL FIND A PARTNER!",
    popup2_secondaryActionText: "I'D RATHER GO SOLO",
  ),
  // ... and so on for the rest of the list
  // Note: I will create placeholder content for the remaining items.
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_6.png',
    text: "Letter to myself",
    Content: "Connect with your most important stakeholder: your future self. It's a powerful reminder of your 'why'.",
    colorHex: "#8E44AD",
    popup2_title: "How to write the Letter",
    popup2_content: "Write a letter to the person you want to be in 6 months. Describe your goals and why they matter. Seal it and use your phone's calendar to set a reminder to open it. It will be a powerful gift to your future self.",
    popup2_imageAdd: 'assets/images/letter_detail.png',
    popup2_primaryActionText: "I'LL WRITE MY LETTER!",
    popup2_secondaryActionText: "I'LL THINK ABOUT IT",
  ),
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_7.png',
    text: "Take Note!",
    Content: "A thought that isn't written down is easily lost. The simple act of journaling makes your goals tangible.",
    colorHex: "#16A085",
    popup2_title: "How to Take Notes",
    popup2_content: "Get a simple notebook. Each day, write down one sentence about your progress. What went well? What was hard? This 'one-line journal' provides incredible insight over time with minimal effort.",
    popup2_imageAdd: 'assets/images/note_detail.png',
    popup2_primaryActionText: "I'LL START JOURNALING!",
    popup2_secondaryActionText: "I DON'T LIKE WRITING",
  ),
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_7.png',
    text: "Instagram",
    Content: "Turn a potential distraction into a tool for inspiration and commitment. Make your screen time work for you.",
    colorHex: "#D35400",
    popup2_title: "How to use Instagram",
    popup2_content: "Unfollow all accounts that don't inspire you. Follow 5 accounts related to your goal. For extra power, post a story declaring your commitment. Public accountability is a huge motivator!",
    popup2_imageAdd: 'assets/images/instagram_detail.png',
    popup2_primaryActionText: "I'LL CURATE MY FEED!",
    popup2_secondaryActionText: "I NEED A DIGITAL DETOX",
  ),
  Superpowerlist(
    imageAdd: 'assets/images/Habit/img_7.png',
    text: "Double Power",
    Content: "Attach a new habit to one you already do automatically. This is one of the most effective ways to build a new routine.",
    colorHex: "#34495E",
    popup2_title: "How to Double Power",
    popup2_content: "Use the formula: 'After my [CURRENT HABIT], I will do my [NEW HABIT].' For example: 'After I put my work bag by the door, I will put my gym clothes on top of it.' Make it obvious and easy!",
    popup2_imageAdd: 'assets/images/double_detail.png',
    popup2_primaryActionText: "I'LL STACK MY HABITS!",
    popup2_secondaryActionText: "I'LL DO THEM SEPARATELY",
  ),
];
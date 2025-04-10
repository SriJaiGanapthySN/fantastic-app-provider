// class Task {
//   final String name;
//   final String description;
//   final String objectID;
//   final bool iscompleted;

//   Task({
//     required this.name,
//     required this.description,
//     required this.objectID,
//     this.iscompleted = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'description': description,
//       'objectID': objectID,
//       'iscompleted': iscompleted,
//     };
//   }
// }

class Task {
  final String name;
  final String descriptionHtml;
  final String objectID;
  final String animationLink;
  final String audioLink;
  final String backgroundLink;
  final String iconLink;
  final bool isdailyroutine;
  final bool iscompleted;
  final String category;

  Task({
    required this.name,
    required this.descriptionHtml,
    required this.objectID,
    required this.animationLink,
    required this.audioLink,
    required this.backgroundLink,
    required this.iconLink,
    this.isdailyroutine = false,
    this.iscompleted = false,
    required this.category
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'descriptionHtml': descriptionHtml,
      'objectID': objectID,
      'animationLink': animationLink,
      'audioLink': audioLink,
      'backgroundLink': backgroundLink,
      'iconLink': iconLink,
      'isdailyroutine': isdailyroutine,
      'iscompleted': iscompleted,
      'category':category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'] ?? '',
      descriptionHtml: map['descriptionHtml'] ?? '',
      objectID: map['objectID'] ?? '',
      animationLink: map['animationLink'] ?? '',
      audioLink: map['audioLink'] ?? '',
      backgroundLink: map['backgroundLink'] ?? '',
      iconLink: map['iconLink'] ?? '',
      isdailyroutine: map['isdailyroutine'] ?? false,
      iscompleted: map['iscompleted'] ?? false,
      category: map['category']?? '',
    );
  }
}
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? age;
  final String? gender;
  final String? location;
  final String? stressLevel;
  final bool profileComplete;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.location,
    this.stressLevel,
    this.profileComplete = false,
  });

  // Copy with method for easy updates
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? age,
    String? gender,
    String? location,
    String? stressLevel,
    bool? profileComplete,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      stressLevel: stressLevel ?? this.stressLevel,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  //convert AppUser to json
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'location': location,
      'stressLevel': stressLevel,
      'profileComplete': profileComplete,
    };
  }

  //convert json to AppUser
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      age: json['age'],
      gender: json['gender'],
      location: json['location'],
      stressLevel: json['stressLevel'],
      profileComplete: json['profileComplete'] ?? false,
    );
  }
}

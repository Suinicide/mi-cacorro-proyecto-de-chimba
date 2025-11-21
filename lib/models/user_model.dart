class UserModel {
  final String id;
  final String fullName;
  final String email;
  final int dailyGoal; // Meta de agua diaria

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.dailyGoal = 2000, // Default 2000ml
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'dailyGoal': dailyGoal,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      dailyGoal: json['dailyGoal'] ?? 2000,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    int? dailyGoal,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}
class UserProfile {
  final String id;
  final String? fullName;
  final String? email;

  UserProfile({required this.id, this.fullName, this.email});

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
    );
  }
}

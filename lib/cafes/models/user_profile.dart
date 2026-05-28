class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.tagline,
    required this.level,
    required this.points,
    required this.email,
    required this.phone,
    required this.avatarKey,
  });

  final String userId;
  final String displayName;
  final String tagline;
  final int level;
  final int points;
  final String email;
  final String phone;
  final String avatarKey;

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? tagline,
    int? level,
    int? points,
    String? email,
    String? phone,
    String? avatarKey,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      tagline: tagline ?? this.tagline,
      level: level ?? this.level,
      points: points ?? this.points,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarKey: avatarKey ?? this.avatarKey,
    );
  }
}

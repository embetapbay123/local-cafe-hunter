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
}

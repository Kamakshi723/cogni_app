class UserModel {
  final String uid;
  final String name;
  final String email;
  final int level;
  final bool isGuest;
  final bool consentAccepted;
  final DateTime? consentAcceptedAt;
  final String consentVersion;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool colorBlindMode;
  final DateTime createdAt;
  final DateTime? lastSessionAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.level = 1, // Start with Level 1
    this.isGuest = false,
    this.consentAccepted = false,
    this.consentAcceptedAt,
    this.consentVersion = '1.0',
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.colorBlindMode = false,
    required this.createdAt,
    this.lastSessionAt,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? level,
    bool? isGuest,
    bool? consentAccepted,
    DateTime? consentAcceptedAt,
    String? consentVersion,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? colorBlindMode,
    DateTime? createdAt,
    DateTime? lastSessionAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      isGuest: isGuest ?? this.isGuest,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
      consentVersion: consentVersion ?? this.consentVersion,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      createdAt: createdAt ?? this.createdAt,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'level': level,
        'isGuest': isGuest,
        'consentAccepted': consentAccepted,
        'consentAcceptedAt': consentAcceptedAt?.toIso8601String(),
        'consentVersion': consentVersion,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'colorBlindMode': colorBlindMode,
        'createdAt': createdAt.toIso8601String(),
        'lastSessionAt': lastSessionAt?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        name: (json['name'] as String?) ?? 'Kashish',
        email: (json['email'] as String?) ?? '',
        level: (json['level'] as int?) ?? 1,
        isGuest: (json['isGuest'] as bool?) ?? false,
        consentAccepted: (json['consentAccepted'] as bool?) ?? false,
        consentAcceptedAt: json['consentAcceptedAt'] != null
            ? DateTime.tryParse(json['consentAcceptedAt'] as String)
            : null,
        consentVersion: (json['consentVersion'] as String?) ?? '1.0',
        soundEnabled: (json['soundEnabled'] as bool?) ?? true,
        hapticsEnabled: (json['hapticsEnabled'] as bool?) ?? true,
        colorBlindMode: (json['colorBlindMode'] as bool?) ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        lastSessionAt: json['lastSessionAt'] != null
            ? DateTime.tryParse(json['lastSessionAt'] as String)
            : null,
      );
}

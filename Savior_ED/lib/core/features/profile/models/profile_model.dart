import 'package:equatable/equatable.dart';

/// Profile model
class ProfileModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? avatar;
  final bool pushNotifications;
  final bool emailNotifications;
  final String language;
  final bool lightMode;
  final String colorScheme;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.avatar,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.language,
    required this.lightMode,
    required this.colorScheme,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      pushNotifications: json['push_notifications'] as bool,
      emailNotifications: json['email_notifications'] as bool,
      language: json['language'] as String,
      lightMode: json['light_mode'] as bool,
      colorScheme: json['color_scheme'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'avatar': avatar,
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'language': language,
      'light_mode': lightMode,
      'color_scheme': colorScheme,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        avatar,
        pushNotifications,
        emailNotifications,
        language,
        lightMode,
        colorScheme,
        createdAt,
        updatedAt,
      ];
}


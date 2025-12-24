import 'package:equatable/equatable.dart';

/// User model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props => [id, email, name, avatar];
}


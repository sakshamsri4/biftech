import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// {@template user_model}
/// Model for a user in the application.
/// {@endtemplate}
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  /// {@macro user_model}
  UserModel({
    required this.name,
    required this.email,
    required this.password,
  });

  /// The name of the user.
  @HiveField(0)
  final String name;

  /// The email of the user.
  @HiveField(1)
  final String email;

  /// The password of the user.
  @HiveField(2)
  final String password;

  /// Creates a copy of this [UserModel] with the given values.
  UserModel copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'UserModel(name: $name, email: $email)';
}

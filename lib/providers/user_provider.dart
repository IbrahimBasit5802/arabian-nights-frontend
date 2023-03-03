import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<UserModel>((ref) {
  return UserModel(
    name: "",
    email: "",
    phoneNumber: "",
    role: "",
  );
});

class UserModel {
  String name, email, phoneNumber, role;
  UserModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });
}

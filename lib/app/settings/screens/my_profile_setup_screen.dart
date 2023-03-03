import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

class MyProfileSetupScreen extends ConsumerWidget {
  const MyProfileSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel userModel = ref.watch(userProvider);

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "my profile"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(
              left: 30,
            ),
            child: const Text("Name"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userModel.name.isNotEmpty ? userModel.name : "Name not provided!",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(
              left: 30,
            ),
            child: const Text("Email"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userModel.email.isNotEmpty
                  ? userModel.email
                  : "Email not provided!",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(
              left: 30,
            ),
            child: const Text("Phone"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userModel.phoneNumber,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(
              left: 30,
            ),
            child: const Text("Role"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userModel.role,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

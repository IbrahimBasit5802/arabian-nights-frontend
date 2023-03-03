import 'package:flutter/material.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
                AssetImage("assets/images/splash_screen/splash_screen_bg.png"),
          ),
        ),
        child: SizedBox(
          width: size.width > 400 ? 400 : size.width,
          child: const Text(
            "Your account is created,\nContact your Restaurant Owner/Manager\nto assign you the Role.\n\nRestart the App once you get your Role assigned.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

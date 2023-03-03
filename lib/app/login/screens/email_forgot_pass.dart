import 'package:flutter/material.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/app/login/controller/email_auth_controller.dart';

class EmailPassForgotScreen extends StatefulWidget {
  const EmailPassForgotScreen({Key? key}) : super(key: key);

  @override
  State<EmailPassForgotScreen> createState() => _EmailPassForgotScreenState();
}

class _EmailPassForgotScreenState extends State<EmailPassForgotScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isBtnForgotClicked = false;

  _sendForgotPassLink() {
    setState(() {
      _isBtnForgotClicked = true;
    });
    String email = _emailController.text;

    if (email.isEmpty) {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Please provide your email id.",
      );
      setState(() {
        _isBtnForgotClicked = false;
      });
      return;
    }

    sendPasswordResetLink(email: email).then((value) {
      setState(() {
        _isBtnForgotClicked = false;
      });
      showAlertDialog(
        context: context,
        title: "Done!",
        description:
            "We sent password reset link to your Email, reset your password and do sign in.",
      );
      Navigator.pop(context);
    }).catchError((error) {
      String message = error.message;
      showAlertDialog(
        context: context,
        title: "oops!",
        description: message,
      );
      setState(() {
        _isBtnForgotClicked = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
                AssetImage("assets/images/splash_screen/splash_screen_bg.png"),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: size.width > 400 ? 400 : size.width,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text(
                  "Enter your email, we will send you password reset link to your email.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Email"),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your email here...",
                    icon: Icon(Icons.email_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: _isBtnForgotClicked ? null : _sendForgotPassLink,
                  child: const Text("Send Password Reset Link"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

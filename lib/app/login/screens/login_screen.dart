import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/app/login/controller/auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/controller/google_sign_in_controller.dart';
import 'package:arabian_nights_frontend/app/login/screens/email_login_screen.dart';
import 'package:arabian_nights_frontend/app/login/screens/otp_send_verify_screen.dart';
import 'package:arabian_nights_frontend/app/pos/screens/pos_homescreen.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

import 'account_created_successfully_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _phoneNumber = '';

  _doGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please wait..."),
      ),
    );

    signInWithGoogle().then((user) async {
      if (user != null) {
        Map<String, dynamic>? userData = await getUserInfo();
        if (userData != null) {
          UserModel userModel = UserModel(
            name: userData["name"] ?? "",
            email: userData["email"] ?? "",
            phoneNumber: userData["phoneNumber"] ?? "",
            role: userData["role"] ?? "",
          );
          ref.read(userProvider.notifier).state = userModel;

          if (userModel.role != "" && userModel.role != "user") {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const POSHomeScreen(),
              ),
              (route) => false,
            );
          } else {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountCreatedScreen(),
              ),
              (route) => false,
            );
          }
        } else {
          addUserInfo(
            email: user.email ?? "",
            userId: user.uid,
            name: user.displayName ?? "",
          ).then((value) async {
            Map<String, dynamic>? userData = await getUserInfo();
            if (userData != null) {
              UserModel userModel = UserModel(
                name: userData["name"] ?? "",
                email: userData["email"] ?? "",
                phoneNumber: userData["phoneNumber"] ?? "",
                role: userData["role"] ?? "",
              );
              ref.read(userProvider.notifier).state = userModel;

              if (userModel.role != "" && userModel.role != "user") {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const POSHomeScreen(),
                  ),
                  (route) => false,
                );
              } else {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountCreatedScreen(),
                  ),
                  (route) => false,
                );
              }
            }
          }).catchError((error) {
            String message = error.message;
            showAlertDialog(
              context: context,
              title: "oops!",
              description: message,
            );
          });
        }
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong, try again"),
        ),
      );
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
            children: [
              const SizedBox(height: 80),
              Center(
                child: Image(
                  image: const AssetImage("assets/images/logo/logo.png"),
                  width: size.width > 400 ? 300 : size.width * .7,
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "manage orders, prints\nfor your cafe/restaurant/hotel",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Phone"),
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
                child: IntlPhoneField(
                  initialCountryCode: 'IN',
                  decoration: const InputDecoration(
                    hintText: "Enter your phone number",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  disableLengthCheck: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (phone) {
                    setState(() {
                      _phoneNumber = phone.completeNumber;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: () {
                    if (_phoneNumber.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtpSendAndVerifyScreen(phoneNumber: _phoneNumber),
                        ),
                      );
                    }
                  },
                  child: const Text("login with OTP"),
                ),
              ),
              const SizedBox(height: 70),
              const Center(
                child: Text("OR"),
              ),
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _doGoogleSignIn();
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECEC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SvgPicture.asset(
                        "assets/google_g.svg",
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailLoginScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECEC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.mail_rounded,
                        color: Color(0xFF545454),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

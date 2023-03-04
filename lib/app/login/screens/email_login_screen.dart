import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/app/login/controller/auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/controller/email_auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/screens/email_forgot_pass.dart';
import 'package:arabian_nights_frontend/app/login/screens/email_signup_screen.dart';
import 'package:arabian_nights_frontend/app/pos/screens/pos_homescreen.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import 'account_created_successfully_screen.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isBtnSignInClicked = false;

  _doSignIn() async {
    setState(() {
      _isBtnSignInClicked = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAlertDialog(
        context: context,
        title: "Oops!",
        description: "Please provide all details.",
      );
      setState(() {
        _isBtnSignInClicked = false;
      });
      return;
    }
    var response;
    try {
      response = await Dio().post(
        Constants.baseUrl + Constants.authenticateUrl,
        data: {
          "email": email,
          "password": password,
        },
      );
    } catch(e) {
      print(e);
    }

    if (response.data['success'] == false) {
      String message = response.data['msg'];

      showAlertDialog(
        context: context,
        title: "Oops!",
        description: message,
      );
      setState(() {
        _isBtnSignInClicked = false;
      });
    }

    else {
      var token = response.data['token'];
      var res;
      var dio = Dio();
      try {
        res = await dio.get(Constants.baseUrl + Constants.userInfoUrl,
            options:Options(headers: {
              "Authorization": "Bearer $token",
            })
        );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
      } catch(e) {
        print(e);
      }
       UserModel userModel = UserModel(
        name: res.data['name'] ?? "",
        email: res.data['email'] ?? "",
        phoneNumber: res.data['phone'] ?? "",
        role: res.data['userType'] ?? "",
      );

      ref.read(userProvider.notifier).state = userModel;
      if (userModel.role != "" && userModel.role != "user") {
                print("userModel.role: ${userModel.role}");
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

    // signInWithEmail(email: email, password: password).then((user) async {
    //   if (user != null) {
    //     setState(() {
    //       _isBtnSignInClicked = false;
    //     });
    //
    //     Map<String, dynamic>? userData = await getUserInfo();
    //     if (userData != null) {
    //       UserModel userModel = UserModel(
    //         name: userData["name"] ?? "",
    //         email: userData["email"] ?? "",
    //         phoneNumber: userData["phoneNumber"] ?? "",
    //         role: userData["role"] ?? "",
    //       );
    //       ref.read(userProvider.notifier).state = userModel;
    //
    //       if (userModel.role != "" && userModel.role != "user") {
    //         if (!mounted) return;
    //         Navigator.pushAndRemoveUntil(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => const POSHomeScreen(),
    //           ),
    //           (route) => false,
    //         );
    //       } else {
    //         if (!mounted) return;
    //         Navigator.pushAndRemoveUntil(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => const AccountCreatedScreen(),
    //           ),
    //           (route) => false,
    //         );
    //       }
    //     }
    //   }
    // }).catchError((error) {
    //   String message = error.message;
    //   showAlertDialog(
    //     context: context,
    //     title: "oops!",
    //     description: message,
    //   );
    //   setState(() {
    //     _isBtnSignInClicked = false;
    //   });
    // });
    }





  Future<UserModel> _getUserInfo(String tok) async {
    var dio = Dio();
    var res;
      try {
        res = await dio.get(Constants.baseUrl + Constants.userInfoUrl,
                    options:Options(headers: {
                      "Authorization": "Bearer $tok",
                    })
        );
      } catch(e) {
        print(e);
      }
      return UserModel(
        name: res.data['name'],
        email: res.data['email'],
        phoneNumber: res.data['phone'],
        role: res.data['userType'],
      );
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
              const SizedBox(height: 120),
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Center(
                child: Text(
                  "login using email and password.",
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
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your email here...",
                    icon: Icon(Icons.email_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Password"),
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
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your password here...",
                    icon: Icon(Icons.password_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: _isBtnSignInClicked ? null : _doSignIn,
                  child: const Text("Sign in"),
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text("OR"),
              ),
              const SizedBox(height: 40),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailPassForgotScreen(),
                          ),
                        );
                      },
                      child: const Text("Forgot Password?"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailSignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Create account"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

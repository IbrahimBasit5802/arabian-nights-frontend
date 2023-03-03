import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/app/login/controller/auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/controller/email_auth_controller.dart';
import 'package:arabian_nights_frontend/app/pos/screens/pos_homescreen.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

import '../../../constants.dart';
import 'account_created_successfully_screen.dart';

class EmailSignupScreen extends ConsumerStatefulWidget {
  const EmailSignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isBtnSignupClicked = false;

  _doSignUp() async {
    setState(() {
      _isBtnSignupClicked = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      showAlertDialog(
        context: context,
        title: "Oops!",
        description: "Please provide all details.",
      );
      setState(() {
        _isBtnSignupClicked = false;
      });
      return;
    }

    var response;
    try {
      response = await Dio().post(
        Constants.baseUrl + Constants.signUpUrl,
        data: {
          "email": email,
          "password": password,
          "name": name,
        },
      );
    } catch (e) {
      print(e);
    }

    if (response.data['success'] == false) {
      String message = response.data['msg'];

      showAlertDialog(
        context: context,
        title: "oops!",
        description: message,
      );
      setState(() {
        _isBtnSignupClicked = false;
      });
    }

    else {
      var response;
      response = await Dio().post(
        Constants.baseUrl + Constants.authenticateUrl,
        data: {
          "email": email,
          "password": password,
        },
      );
      var token = response.data['token'];
      var res;
      var dio = Dio();
      try {
        res = await dio.get(Constants.baseUrl + Constants.userInfoUrl,
            options: Options(headers: {
              "Authorization": "Bearer $token",
            })
        );
      } catch (e) {
        print(e);
      }
      UserModel userModel = UserModel(
        name: res.data['name'] ?? "",
        email: res.data['email'] ?? "",
        phoneNumber: res.data['phone'] ?? "",
        role: res.data['userType'] ?? "",
      );

      ref
          .read(userProvider.notifier)
          .state = userModel;

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

      // signUpUserWithEmail(email: email, password: password, name: name)
      //     .then((user) {
      //   if (user != null) {
      //     addUserInfo(
      //       email: email,
      //       userId: user.uid,
      //       name: name,
      //     ).then((value) async {
      //       setState(() {
      //         _isBtnSignupClicked = false;
      //       });
      //
      //       Map<String, dynamic>? userData = await getUserInfo();
      //       if (userData != null) {
      //         UserModel userModel = UserModel(
      //           name: userData["name"] ?? "",
      //           email: userData["email"] ?? "",
      //           phoneNumber: userData["phoneNumber"] ?? "",
      //           role: userData["role"] ?? "",
      //         );
      //         ref.read(userProvider.notifier).state = userModel;
      //
      //         if (userModel.role != "" && userModel.role != "user") {
      //           if (!mounted) return;
      //           Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const POSHomeScreen(),
      //             ),
      //             (route) => false,
      //           );
      //         } else {
      //           if (!mounted) return;
      //           Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const AccountCreatedScreen(),
      //             ),
      //             (route) => false,
      //           );
      //         }
      //       }
      //     }).catchError((error) {
      //       String message = error.message;
      //       showAlertDialog(
      //         context: context,
      //         title: "oops!",
      //         description: message,
      //       );
      //       setState(() {
      //         _isBtnSignupClicked = false;
      //       });
      //     });
      //   }
      // }).catchError((error) {
      //   String message = error.message;
      //   showAlertDialog(
      //     context: context,
      //     title: "Oops!",
      //     description: message,
      //   );
      //   setState(() {
      //     _isBtnSignupClicked = false;
      //   });
      // });
    }
  }

    @override
    Widget build(BuildContext context) {
      Size size = MediaQuery
          .of(context)
          .size;
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
                    "Create Account",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  width: size.width > 400 ? 400 : size.width,
                  margin: const EdgeInsets.only(
                    left: 30,
                  ),
                  child: const Text("Name"),
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
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your name here...",
                      icon: Icon(Icons.person_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                    onPressed: _isBtnSignupClicked ? null : _doSignUp,
                    child: const Text("Create account"),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    }
  }



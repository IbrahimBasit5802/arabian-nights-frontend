import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/app/login/controller/auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/screens/account_created_successfully_screen.dart';
import 'package:arabian_nights_frontend/app/pos/screens/pos_homescreen.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

class OtpSendAndVerifyScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpSendAndVerifyScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  ConsumerState<OtpSendAndVerifyScreen> createState() =>
      _OtpSendAndVerifyScreenState();
}

class _OtpSendAndVerifyScreenState
    extends ConsumerState<OtpSendAndVerifyScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String _verificationId = '';
  bool _isVerifyingOTP = false;

  @override
  void initState() {
    // send OTP to phone number
    sendOTP(phoneNumber: widget.phoneNumber);

    super.initState();
  }

  void sendOTP({required String phoneNumber}) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _signInWithPhoneOTP,
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(e.toString());
          debugPrint(e.code);

          if (e.code == 'invalid-phone-number') {
            showAlertDialog(
              context: context,
              title: "oops!",
              description: "Invalid phone number provided.",
            );
          } else {
            showAlertDialog(
              context: context,
              title: "oops!",
              description: "Something went wrong! Try again later.",
            );
          }
        },
        codeSent: (String vId, int? resendToken) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP sent successfully."),
            ),
          );
          setState(() {
            _verificationId = vId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-phone-number') {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Invalid phone number provided.",
        );
      } else {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Something went wrong! Try again later.",
        );
      }
    }
  }

  void verifyOTP(String otp) async {
    setState(() {
      _isVerifyingOTP = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: otp);
      _signInWithPhoneOTP(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isVerifyingOTP = false;
      });

      debugPrint(e.toString());
      debugPrint(e.code);
      if (e.code == "invalid-verification-code") {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "OTP verification failed, provide correct OTP.",
        );
      } else {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Something went wrong, try again later.",
        );
      }
    }
  }

  _signInWithPhoneOTP(PhoneAuthCredential credential) async {
    User? user = (await auth.signInWithCredential(credential)).user;

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
          phoneNumber: user.phoneNumber ?? "",
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
              const SizedBox(height: 80),
              Center(
                child: Image(
                  image: const AssetImage("assets/images/logo/logo.png"),
                  width: size.width > 400 ? 400 : size.width * .7,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Enter OTP, sent on your ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Pinput(
                  enabled: !_isVerifyingOTP,
                  length: 6,
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  onCompleted: (String pin) async {
                    _pinPutFocusNode.unfocus();

                    verifyOTP(pin);
                  },
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: _isVerifyingOTP
                      ? null
                      : () {
                          String otp = _pinPutController.text;
                          verifyOTP(otp);
                        },
                  child: const Text("verify OTP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

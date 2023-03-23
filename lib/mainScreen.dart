import 'package:arabian_nights_frontend/app/login/screens/email_login_screen.dart';
import 'package:flutter/material.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Center(
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(

            width: size.width > 400 ? 400 : size.width,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  EmailLoginScreen()),
                );
              },
              child: const Text("Retailer"),
            ),
          ),
          const SizedBox(height: 30),

          Container(
            width: size.width > 400 ? 400 : size.width,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  EmailLoginScreen()),
                );
              },
              child: const Text("Cafe"),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: size.width > 400 ? 400 : size.width,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  EmailLoginScreen()),
                );
              },
              child: const Text("WholeSale"),
            ),
          ),
        ],
      ),
      )

    );
  }
}

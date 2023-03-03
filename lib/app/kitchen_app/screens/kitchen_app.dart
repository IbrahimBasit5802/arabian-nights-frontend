import 'package:flutter/material.dart';
import 'package:arabian_nights_frontend/app/kitchen_app/components/kitchen_orders_list_widget.dart';
import 'package:arabian_nights_frontend/app/pos/widgets/custom_icon_button.dart';
import 'package:arabian_nights_frontend/app/settings/settings_screen.dart';

class KitchenApp extends StatelessWidget {
  const KitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Image(
          image: AssetImage("assets/images/logo/logo.png"),
          height: 40,
        ),
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: CustomIconButton(
              icon: Icons.settings_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: const KitchenOrdersListWidget(),
    );
  }
}

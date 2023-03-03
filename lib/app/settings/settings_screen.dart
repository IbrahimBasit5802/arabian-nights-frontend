import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/login/controller/auth_controller.dart';
import 'package:arabian_nights_frontend/app/login/screens/login_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/floors_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/invoice_details_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/menu_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/my_profile_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/reports_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/staff_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/tables_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/view_all_invoice_screen.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/setting_list_tile.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/common/open_url.dart';
import 'package:arabian_nights_frontend/config/app.dart';
import 'package:arabian_nights_frontend/config/theme.dart';
import 'package:arabian_nights_frontend/constants/roles.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel userModel = ref.watch(userProvider);

    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            customAppBar(context: context, title: "setup"),
            const SizedBox(height: 20),
            SettingListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileSetupScreen(),
                  ),
                );
              },
              title: "My Profile",
              iconBackground: const Color(0xFF7438EB),
              icon: Icons.person,
            ),
            if (userModel.role == UserRoles.manager.name) ...[
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FloorsSetupScreen(),
                    ),
                  );
                },
                title: "Floors",
                iconBackground: const Color(0xFFFA1E0E),
                icon: Icons.apartment_rounded,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TablesSetupScreen(),
                    ),
                  );
                },
                title: "Tables",
                iconBackground: const Color(0xFF702727),
                icon: Icons.table_restaurant_rounded,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MenuSetupScreen(),
                    ),
                  );
                },
                title: "Menu",
                iconBackground: const Color(0xFFF68837),
                icon: Icons.restaurant_menu_rounded,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoiceDetailsScreen(),
                    ),
                  );
                },
                title: "Invoice Details",
                iconBackground: const Color(0xFF46AAE1),
                icon: Icons.receipt_long_rounded,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffSetupScreen(),
                    ),
                  );
                },
                title: "Staff",
                iconBackground: const Color(0xFF4340F3),
                icon: Icons.people,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  );
                },
                title: "Reports",
                iconBackground: const Color(0xFF7B7B7B),
                icon: Icons.insights,
              ),
            ],
            if (userModel.role == UserRoles.manager.name ||
                userModel.role == UserRoles.recieptionist.name) ...[
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllInvoiceScreen(),
                    ),
                  );
                },
                title: "All Invoices",
                iconBackground: const Color(0xFFEFA856),
                icon: Icons.receipt_outlined,
              ),
            ],
            SettingListTile(
              onTap: () {
                openURL(supportURL);
              },
              title: "Contact Support",
              iconBackground: const Color(0xFF43BE56),
              icon: Icons.message,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        customPalette.shade500.withOpacity(.2)),
                    foregroundColor:
                        MaterialStateProperty.all(customPalette.shade500),
                    overlayColor: MaterialStateProperty.all(
                        customPalette.shade500.withOpacity(.5))),
                onPressed: () async {
                  //logout
                  try {
                    final NavigatorState navigatorState = Navigator.of(context);

                    await logOut();

                    // remove all screen and push login screen
                    navigatorState.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    log("$e", name: "settings_screen.dart");
                    showAlertDialog(
                      context: context,
                      title: "oops!",
                      description: "something went wrong!, try later",
                    );
                  }
                },
                child: const Text("logout"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

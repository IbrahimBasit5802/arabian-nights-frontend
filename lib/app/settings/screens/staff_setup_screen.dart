import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/staff_controller.dart';
import 'package:arabian_nights_frontend/app/settings/screens/staff_add_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/staff_update_screen.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:arabian_nights_frontend/providers/staff_users_provider.dart';

import '../../../constants.dart';

class StaffSetupScreen extends ConsumerStatefulWidget {
  const StaffSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffSetupScreen> createState() => _StaffSetupScreenState();
}

class _StaffSetupScreenState extends ConsumerState<StaffSetupScreen> {
  bool _loading = true;

  @override
  void initState() {
    _getStaffUsers();
    super.initState();
  }

  _getStaffUsers() async {
    setState(() {
      _loading = true;
    });
    try {
      var dio = Dio();
      var res = await dio.get(Constants.baseUrl + Constants.getAllUsersUrl);
      List<dynamic> staff = [];
      for (int i = 0; i < res.data["users"].length; i++) {
         Map<String, dynamic> curr = {
           "uid" : res.data["users"][i]["_id"],
           "name" : res.data["users"][i]["name"],
           "email" : res.data["users"][i]["email"],
           "role" : res.data["users"][i]["userType"],
            "phone" : res.data["users"][i]["phone"],
         };
         staff.add(curr);
      }
      if (res != null) {
        ref.read(staffUsersProvider.notifier).state = staff;
      }
    } catch (e) {
      debugPrint("$e");
    }
    setState(() {
      _loading = false;
    });
  }

  void _removeStaffUser(Map<String, dynamic> doc) async {
    try {
      showConfirmAlertDialog(
        context: context,
        title: "Are you sure?",
        description: "selected user will be removed from staff!",
        onConfirm: () async {

          var dio = Dio();
          await dio.post(Constants.baseUrl + Constants.deleteUserUrl, data: {
            "email": doc["email"],
          });
          _getStaffUsers();
        },
      );
    } catch (e) {
      debugPrint("$e");
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "couldn't able to remove the user, try again later.",
      );
    }
  }

  void _updateStaffUser(Map<String, dynamic> doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffUpdateScreen(doc: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> staffUsers = ref.watch(staffUsersProvider);

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "Staff settings"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          if (_loading) ...[
            _widgetSkeleton(),
          ] else ...[
            if (staffUsers.isNotEmpty) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (ctx, index) {
                  return _staffUserItemWidget(doc: staffUsers[index]);
                },
                separatorBuilder: (ctx, index) => const Divider(),
                itemCount: staffUsers.length,
              ),
              const SizedBox(height: 60),
              const Text(
                "Swipe to remove user. or view more options.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ] else ...[
              const Text("No staff users found."),
            ],
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffAddScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_search_rounded),
      ),
    );
  }

  Widget _widgetSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF2F2F2),
      highlightColor: Colors.white,
      child: Column(
        children: [
          ...List.generate(
            10,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 140,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).toList()
        ],
      ),
    );
  }

  Widget _staffUserItemWidget({required Map<String, dynamic> doc}) {

    String role = doc!["role"] ?? "-";
    String name = doc["name"] ?? "-";
    String contact = doc["phoneNumber"] ?? doc["email"] ?? "-";
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              _updateStaffUser(doc);
            },
            label: "edit",
            icon: Icons.edit_outlined,
            backgroundColor: const Color(0xFFFDE1CD),
            foregroundColor: Colors.black,
          ),
          SlidableAction(
            onPressed: (ctx) {
              _removeStaffUser(doc);
            },
            label: "remove",
            icon: Icons.delete_outline_rounded,
            backgroundColor: const Color(0xFFFF6054),
            foregroundColor: Colors.white,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _updateStaffUser(doc);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contact,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

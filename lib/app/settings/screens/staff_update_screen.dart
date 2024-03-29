import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/staff_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/constants/roles.dart';
import 'package:arabian_nights_frontend/providers/staff_users_provider.dart';

import '../../../constants.dart';

class StaffUpdateScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> doc;
  const StaffUpdateScreen({Key? key, required this.doc}) : super(key: key);

  @override
  ConsumerState<StaffUpdateScreen> createState() => _StaffUpdateScreenState();
}

class _StaffUpdateScreenState extends ConsumerState<StaffUpdateScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String _dropdownUserRole = '';

  bool _isBtnDisabled = false;

  @override
  void initState() {
    Map<String, dynamic>? data = widget.doc as Map<String, dynamic>?;

    String name = data!["name"] ?? "";
    String email = data["email"] ?? "";
    String phoneNumber = data["phone"] ?? "";
    String role = data["role"] ?? "";

    _nameTextController.text = name;
    _emailTextController.text = email;
    _phoneNumberController.text = phoneNumber;

    setState(() {
      _dropdownUserRole = role;
    });

    super.initState();
  }

  void _btnUpdateStaffUserTap() async {
    setState(() {
      _isBtnDisabled = true;
    });

    if (_dropdownUserRole.isEmpty) {
      showAlertDialog(
        context: context,
        title: "Oops!",
        description: "Please Select role",
      );
      setState(() {
        _isBtnDisabled = false;
      });
      return;
    }

    try {
      var dio = Dio();

      var response = await dio.post(Constants.baseUrl + Constants.updateUserUrl, data: {
          "_id": widget.doc["uid"],
          "name": _nameTextController.text,
          "email": _emailTextController.text,
          "phone": _phoneNumberController.text,
          "role": _dropdownUserRole,
      });

      showAlertDialog(
        context: context,
        title: "Done ✅",
        description: "User's profile updated",
      );


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
      showAlertDialog(
        context: context,
        title: "oops!",
        description: e.toString(),
      );
    }

    setState(() {
      _isBtnDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "Update staff member"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          _staffUserUpdateForm(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _staffUserUpdateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 30,
          ),
          child: const Text("Name"),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _nameTextController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter name here",
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(
            left: 30,
          ),
          child: const Text("Email"),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _emailTextController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter email here",
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(
            left: 30,
          ),
          child: const Text("Phone"),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _phoneNumberController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter phone here",
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(
            left: 30,
          ),
          child: const Text("Role"),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _dropdownUserRole,
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text("Select Role"),
              ),
              ...userRoles
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
            ],
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            isExpanded: true,
            hint: const Text("Select Role"),
            borderRadius: BorderRadius.circular(12),
            underline: Container(),
            onChanged: (String? selectedOption) {
              if (selectedOption != null) {
                setState(() {
                  _dropdownUserRole = selectedOption;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            onPressed: _isBtnDisabled ? null : _btnUpdateStaffUserTap,
            child: const Text("Update"),
          ),
        ),
      ],
    );
  }
}

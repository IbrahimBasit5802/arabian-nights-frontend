import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/staff_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/constants/roles.dart';
import 'package:arabian_nights_frontend/providers/staff_users_provider.dart';

import '../../../constants.dart';

class StaffAddScreen extends ConsumerStatefulWidget {
  const StaffAddScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffAddScreen> createState() => _StaffAddScreenState();
}

class _StaffAddScreenState extends ConsumerState<StaffAddScreen> {
  final TextEditingController _searchInputController = TextEditingController();
  String _dropdownSearchBy = '';

  String _uid = '';
  String _name = '';
  String _email = '';
  String _phoneNumber = '';

  String _dropdownUserRole = '';

  bool _isSearched = false;
  bool _isBtnDisabled = false;

  void _btnSearchUserTap() async {
    try {
      setState(() {
        _isBtnDisabled = true;
      });
      String searchText = _searchInputController.text;

      if (_dropdownSearchBy.isEmpty) {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Please Select 'Search User' 🔎 field",
        );
        setState(() {
          _isBtnDisabled = false;
        });
        return;
      }

      if (searchText.isEmpty) {
        showAlertDialog(
          context: context,
          title: "Oops!",
          description: "Please provide search value!",
        );
        setState(() {
          _isBtnDisabled = false;
        });
        return;
      }
      var dio = Dio();
      var response = await dio.get(Constants.baseUrl + Constants.getUserUrl, data: {
        "email": _searchInputController.text,
      });

      print(searchText);
      if (response == null) {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "no user found!",
        );
        setState(() {
          _isBtnDisabled = false;
        });
        return;
      } else {

        if (response.data != null) {
          String name = response.data["name"] ?? "";
          String email = response.data["email"] ?? "";
          String phoneNumber = response.data["phone"] ?? "";

          setState(() {
            _name = name;
            _email = email;
            _phoneNumber = phoneNumber;
            _uid = response.data["_id"] ?? "";
          });
        }
      }

      _searchInputController.clear();
      setState(() {
        _isBtnDisabled = false;
        _isSearched = true;
      });
    } catch (e) {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: e.toString(),
      );
    }
  }

  void _btnAddStaffTap() async {
    setState(() {
      _isBtnDisabled = true;
    });

    if (_dropdownUserRole.isEmpty) {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Please Select role",
      );
      setState(() {
        _isBtnDisabled = false;
      });
      return;
    }

    try {
      await updateStaffRole(uid: _uid, role: _dropdownUserRole);
      showAlertDialog(
        context: context,
        title: "Done ✅",
        description: "User's role updated",
      );

      List<QueryDocumentSnapshot>? res = await getStaffUsers();
      if (res != null) {
        ref.read(staffUsersProvider.notifier).state = res;
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
          customAppBar(context: context, title: "add staff member"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          if (!_isSearched) ...[
            _staffSearchForm(),
          ] else ...[
            _staffAddForm(),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _staffSearchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 30,
          ),
          child: const Text("Search User"),
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
            value: _dropdownSearchBy,
            items: const [
              DropdownMenuItem(
                  value: '', child: Text("Select field search by")),
              DropdownMenuItem(value: 'name', child: Text("Using Name")),
              DropdownMenuItem(value: 'email', child: Text("Using Email")),
              DropdownMenuItem(
                  value: 'phoneNumber', child: Text("Using Phone")),
            ],
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            isExpanded: true,
            hint: const Text("Using Name/Email/Phone"),
            borderRadius: BorderRadius.circular(12),
            underline: Container(),
            onChanged: (String? selectedOption) {
              if (selectedOption != null) {
                setState(() {
                  _dropdownSearchBy = selectedOption;
                });
              }
            },
          ),
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
            controller: _searchInputController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            enableSuggestions: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "enter search value here...",
            ),
            onEditingComplete: () {
              _btnSearchUserTap();
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            onPressed: _isBtnDisabled ? null : _btnSearchUserTap,
            child: const Text("search"),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _staffAddForm() {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _name.isNotEmpty ? _name : "Name not provided!",
            style: const TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _email.isNotEmpty ? _email : "Email not provided!",
            style: const TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _phoneNumber,
            style: const TextStyle(color: Colors.grey),
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
            onPressed: _isBtnDisabled ? null : _btnAddStaffTap,
            child: const Text("add"),
          ),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/menu_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';

import '../../../constants.dart';

class MenuAddCategoryScreen extends ConsumerStatefulWidget {
  const MenuAddCategoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MenuAddCategoryScreen> createState() =>
      _MenuAddCategoryScreenState();
}

class _MenuAddCategoryScreenState extends ConsumerState<MenuAddCategoryScreen> {
  final TextEditingController _categoryTitleController =
      TextEditingController();

  bool _isBtnTapped = false;

  _btnSaveTap() async {
    setState(() {
      _isBtnTapped = true;
    });

    try {
      // save category to DB
      String category = _categoryTitleController.text;
      if (category.isNotEmpty) {
        await addMenuCategory(title: category);

        //  update state provider for menu
        var dio = Dio();
        var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
        //List<QueryDocumentSnapshot>? menuCategories = await getMenuCategories();
        List<dynamic> menu = [];

        List<dynamic> items;
        for (int i = 0; i < menuResponse.data["categories"].length; i++) {
          var category = menuResponse.data["categories"][i]["categoryName"];
          items = [];
          for (int j = 0; j < menuResponse.data["categories"][i]["items"].length; j++) {

            Map<String, dynamic> curr = {
              "itemName" : menuResponse.data["categories"][i]["items"][j]["name"],
              "itemPrice" : menuResponse.data["categories"][i]["items"][j]["price"],
              "itemImage" : menuResponse.data["categories"][i]["items"][j]["picUrl"],
            };
            items.add(curr);
          }
          Map<String, dynamic> curr = {
            "category" : category,
            "items" : items
          };
          menu.add(curr);
        }

        ref.read(menuProvider.notifier).state = menu;

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Provide category title.",
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "something went wrong while saving category.",
      );
    }

    setState(() {
      _isBtnTapped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "add category"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Category Title"),
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
              controller: _categoryTitleController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              enableSuggestions: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Category Title here...",
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _isBtnTapped ? null : _btnSaveTap,
              child: const Text("save"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/menu_controller.dart';
import 'package:arabian_nights_frontend/app/settings/screens/menu_add_category_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/menu_items_setup_screen.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';

import '../../../constants.dart';

class MenuSetupScreen extends ConsumerStatefulWidget {
  const MenuSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MenuSetupScreen> createState() => _MenuSetupScreenState();
}

class _MenuSetupScreenState extends ConsumerState<MenuSetupScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<dynamic> menuCategories = ref.watch(menuProvider);
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "menu setup"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          // if (_loading) ...[
          // _skeleton(),
          // ] else ...[
          for (var categoryItem in menuCategories) ...[
            categoryItemListWidget(categoryItem),
          ],
          const SizedBox(height: 50),
          const Center(
            child: Text(
              "Swipe to remove/edit category.\nor Tap to view more",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
        ],
        // ],
      ),
      floatingActionButtonLocation: size.width > 500
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MenuAddCategoryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  _deleteMenuCategory(String docid) async {
    var dio = Dio();
    try {
      var response = await dio.post(Constants.baseUrl + Constants.deleteCategoryUrl,
          data: {"categoryName": docid});

    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Something went wrong while saving category");
    }

    var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
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

    if (menu != null) {
      ref.read(menuProvider.notifier).state = menu;
    }
  }

  Widget categoryItemListWidget(Map<String, dynamic> categoryItem) {

    String categoryTitle = categoryItem!["category"] ?? "";
    List<dynamic> categoryMenuItems = categoryItem["items"] ?? [];

    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              if (categoryMenuItems.isEmpty) {
                _deleteMenuCategory(categoryItem["category"]);
              } else {
                showAlertDialog(
                  context: context,
                  title: "Oops!",
                  description:
                      "There are items available inside this category, remove them first and then remove the category.",
                );
              }
            },
            label: "Remove",
            icon: Icons.delete_outline_rounded,
            backgroundColor: const Color(0xFFFF6054),
            foregroundColor: Colors.white,
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemsSetupScreen(
                categoryItem: categoryItem,
              ),
            ),
          );
        },
        title: Text(categoryTitle),
        subtitle: Text("${categoryMenuItems.length} items"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      ),
    );
  }

  // Widget _skeleton() {
  //   return Shimmer.fromColors(
  //     baseColor: const Color(0xFFF2F2F2),
  //     highlightColor: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 30),
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF2F2F2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 30),
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF2F2F2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 30),
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF2F2F2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 30),
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF2F2F2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }
}

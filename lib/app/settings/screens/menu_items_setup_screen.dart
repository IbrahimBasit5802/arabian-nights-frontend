import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/screens/menu_item_add_screen.dart';
import 'package:arabian_nights_frontend/app/settings/screens/menu_item_update_screen.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';

class MenuItemsSetupScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> categoryItem;
  const MenuItemsSetupScreen({Key? key, required this.categoryItem})
      : super(key: key);

  @override
  ConsumerState<MenuItemsSetupScreen> createState() =>
      _MenuItemsSetupScreenState();
}

class _MenuItemsSetupScreenState extends ConsumerState<MenuItemsSetupScreen> {
  @override
  Widget build(BuildContext context) {
    List<dynamic>? menuCategories = ref.watch(menuProvider);
    List<dynamic> menuItems = [];
    if (menuCategories != null) {
      String categoryId = widget.categoryItem["category"];

      var result = menuCategories.where((mC) => mC["category"] == categoryId);


        if (result != null) {
          menuItems = result.toList()[0]["items"] ?? [];
        }

    }

    Size size = MediaQuery.of(context).size;
    int gridCount = size.width > 1000
        ? 4
        : size.width > 500
            ? 3
            : 2;

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "menu items"),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                ...menuItems
                    .map(
                      (item) => _menuItemWidget(
                        itemName: item["itemName"],
                        itemPrice: item["itemPrice"],
                        image: item["itemImage"] ?? "",
                        menuItem: item,
                        menuItems: menuItems,
                      ),
                    )
                    .toList()
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemAddScreen(
                categoryId: widget.categoryItem["category"],
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add new Item"),
      ),
    );
  }

  Widget _menuItemWidget({
    required String itemName,
    required num itemPrice,
    String image = "",
    dynamic menuItem,
    List<dynamic> menuItems = const [],
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemUpdateScreen(
              oldItemName: itemName,
              itemName: itemName,
              itemPrice: itemPrice,
              menuItem: menuItem,
              menuItems: menuItems,
              categoryId: widget.categoryItem["category"],
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (image != "") ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: image,
                placeholder: (c, _) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey,
                  child: const Text("Loading..."),
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.black.withOpacity(.4),
            ),
            alignment: Alignment.center,
            child: Text(
              itemName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

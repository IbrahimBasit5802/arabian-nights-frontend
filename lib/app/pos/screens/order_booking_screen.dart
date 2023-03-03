import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/pos/models/order_item_model.dart';
import 'package:arabian_nights_frontend/app/pos/screens/order_complete_screen.dart';
import 'package:arabian_nights_frontend/app/pos/screens/order_confirmation_screen.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/config/theme.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';

class OrderBookingScreen extends ConsumerStatefulWidget {
  final num table;
  final num floor;

  const OrderBookingScreen({
    Key? key,
    required this.floor,
    required this.table,
  }) : super(key: key);

  @override
  ConsumerState<OrderBookingScreen> createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends ConsumerState<OrderBookingScreen> {
  final List<MenuOrderItemModel> order = [];

  _addItemToOrder(int exsistingOrderItemIndex, dynamic menuItem) {
    if (exsistingOrderItemIndex != -1) {
      setState(() {
        MenuOrderItemModel prevItemData = order[exsistingOrderItemIndex];
        int newQty = prevItemData.quantity + 1;
        MenuOrderItemModel newItemData = MenuOrderItemModel(
          itemName: prevItemData.itemName,
          quantity: newQty,
          rate: prevItemData.rate,
        );
        order[exsistingOrderItemIndex] = newItemData;
      });
    } else {
      setState(() {
        order.add(
          MenuOrderItemModel(
            itemName: menuItem["itemName"],
            quantity: 1,
            rate: menuItem["itemPrice"],
          ),
        );
      });
    }
  }

  _removeItemToOrder(int exsistingOrderItemIndex, dynamic menuItem) {
    if (exsistingOrderItemIndex != -1) {
      setState(() {
        MenuOrderItemModel prevItemData = order[exsistingOrderItemIndex];
        int newQty = prevItemData.quantity - 1;
        if (newQty != 0) {
          MenuOrderItemModel newItemData = MenuOrderItemModel(
            itemName: prevItemData.itemName,
            quantity: newQty,
            rate: prevItemData.rate,
          );
          order[exsistingOrderItemIndex] = newItemData;
        } else {
          order.removeAt(exsistingOrderItemIndex);
        }
      });
    }
  }

  _orderNowBtnTap() async {
    if (order.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            floor: widget.floor,
            table: widget.table,
            orderedItems: order,
          ),
        ),
      );
    } else {
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "There is no order!\nPlease order something to proceed.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> menu = ref.watch(menuProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        isExtended: order.isNotEmpty,
        icon: const Icon(Icons.restaurant_rounded),
        label: const Text("order now"),
        onPressed: () {
          _orderNowBtnTap();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(
            context: context,
            title:
                "${getOrdinalNumber(number: widget.floor.toInt(), short: true)}F-T${widget.table.toInt()}",
            action: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderCompleteScreen(
                          floor: widget.floor,
                          table: widget.table,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  tooltip: "get bill",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: _menuCategoriesSelectorWidget(menu),
            ),
          ),
          const SizedBox(height: 30),


          ...menu.map((menuCategory) {
            print("ok");
            String categoryTitle = menuCategory["category"];

            List<dynamic> items = menuCategory["items"];

            return _menuCategoryItemWidget(categoryTitle, items);
          }).toList(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _menuCategoriesSelectorWidget(
      List<dynamic> menu) {
    return ListView.builder(
      itemBuilder: (context, index) => Row(
        children: [
          ActionChip(
            onPressed: () {
              try {
                String categoryId = menu[index]["category"];
                GlobalObjectKey key = GlobalObjectKey(categoryId);
                BuildContext context = key.currentContext!;
                Scrollable.ensureVisible(
                  context,
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 700),
                  alignment: 0.5,
                );
              } catch (e) {
                debugPrint("$e");
              }
            },
            elevation: 0,
            pressElevation: 2,
            label: Text(
              menu[index]["category"],
              style: const TextStyle(
                color: Color(0xFF717171),
                fontSize: 14,
              ),
            ),
            backgroundColor: const Color(0xFFF5F5F5),
          ),
          const SizedBox(width: 8),
        ],
      ),
      itemCount: menu.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
    );
  }

  Padding _menuCategoryItemWidget(String categoryTitle, List<dynamic> items) {
    return Padding(
      key: GlobalObjectKey(categoryTitle),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          _menuCategoryItemsGrid(items),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  GridView _menuCategoryItemsGrid(List<dynamic> items) {
    Size size = MediaQuery.of(context).size;
    int gridCount = size.width > 1000
        ? 4
        : size.width > 500
            ? 3
            : 2;
    return GridView.count(
      crossAxisCount: gridCount,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        ...items
            .map(
              (item) => _menuItemWidget(
                itemName: item["itemName"],
                itemPrice: item["itemPrice"],
                image: item["itemImage"]??"",
                menuItem: item,
              ),
            )
            .toList()
      ],

    );
  }

  Widget _menuItemWidget({
    required String itemName,
    required num itemPrice,
    String image = "",
    dynamic menuItem,
  }) {
    var exsistingOrderItemIndex =
        order.indexWhere((element) => element.itemName == itemName);

    return GestureDetector(
      onTap: () {
        _addItemToOrder(exsistingOrderItemIndex, menuItem);

        debugPrint(order.toString());
      },
      onLongPress: () {
        _removeItemToOrder(exsistingOrderItemIndex, menuItem);
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
          if (exsistingOrderItemIndex != -1) ...[
            Positioned(
              bottom: 18,
              right: 18,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: customPalette.withOpacity(.7),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${order[exsistingOrderItemIndex].quantity}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

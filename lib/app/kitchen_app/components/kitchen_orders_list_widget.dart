import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/kitchen_app/controllers/kitchen_orders_controller.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:arabian_nights_frontend/packages/staggered_grid/flutter_staggered_grid_view.dart';
import 'package:arabian_nights_frontend/providers/kitchen_order_provider.dart';

class KitchenOrdersListWidget extends ConsumerWidget {
  const KitchenOrdersListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitchenOrdersAsync = ref.watch(kitchenOrdersProvider);
    Size size = MediaQuery.of(context).size;

    int gridColumns = size.width > 1000
        ? 4
        : size.width > 500
            ? 2
            : 1;

    return kitchenOrdersAsync.when(
      data: (kitchenOrders) {
        if (kitchenOrders.docs.isEmpty) {
          return const Center(
            child: Text("No orders Available right now 🧑‍🍳"),
          );
        }

        // return StaggeredGrid.count(
        //   crossAxisCount: gridColumns,
        //   children: [
        //     ...kitchenOrders.docs
        //         .map(
        //           (kitchenOrder) => _kitchenOrderItem(
        //             kitchenOrder: kitchenOrder,
        //             context: context,
        //           ),
        //         )
        //         .toList()
        //   ],
        // );
        return MasonryGridView.count(
          crossAxisCount: gridColumns,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: kitchenOrders.docs.length,
          itemBuilder: (context, index) {
            final kitchenOrder = kitchenOrders.docs[index];

            return _kitchenOrderItem(
              kitchenOrder: kitchenOrder,
              context: context,
            );
          },
        );
      },
      error: (e, st) => const Center(
        child: Text("oops!, something went wrong"),
      ),
      loading: () => _ordersListSkeleton(),
    );
  }

  Widget _kitchenOrderItem({
    required QueryDocumentSnapshot kitchenOrder,
    required BuildContext context,
  }) {
    Map<String, dynamic>? kitchenOrderData =
        kitchenOrder.data() as Map<String, dynamic>?;

    if (kitchenOrderData == null) {
      return Container();
    }

    List<dynamic> orderedItems = kitchenOrderData["ordered_items"] ?? [];

    if (orderedItems.isEmpty) {
      return Container();
    }

    num floor = kitchenOrderData["floor"] ?? 0;
    num table = kitchenOrderData["table"] ?? 0;
    String notes = kitchenOrderData["notes"] ?? "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          //
          // order information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (notes.isNotEmpty) ...[
                TextButton.icon(
                  icon: const Icon(Icons.info),
                  label: const Text("notes"),
                  onPressed: () {
                    showAlertDialog(
                      context: context,
                      title: "Order Notes",
                      description: notes,
                    );
                  },
                ),
              ] else ...[
                Container(),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${getOrdinalNumber(number: floor.toInt(), short: true)}F",
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      color: const Color(0xFFFDE1CD),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "T${table.toInt()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFA1E0E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // order information
          //

          const SizedBox(height: 8),

          //
          // orders list
          ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              ...orderedItems.map((orderedItem) {
                bool ready = orderedItem["ready"] ?? false;
                String itemName = orderedItem["itemName"] ?? "";
                num quantity = orderedItem["quantity"] ?? 0;

                return Material(
                  color: Colors.transparent,
                  child: Ink(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () async {
                        ScaffoldMessengerState scaffoldMessengerState =
                            ScaffoldMessenger.of(context);

                        scaffoldMessengerState.showSnackBar(
                          SnackBar(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.grey,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              textColor: Colors.red[100],
                              label: "dismiss",
                              onPressed: () {
                                scaffoldMessengerState.removeCurrentSnackBar();
                              },
                            ),
                            content: Row(
                              children: const [
                                Text("Order status update, received."),
                              ],
                            ),
                          ),
                        );

                        await markOrderItemAsCompleted(
                          docid: kitchenOrder.id,
                          orders: orderedItems,
                          orderIndex: orderedItems.indexOf(orderedItem),
                        );
                      },
                      leading: Icon(
                        ready ? Icons.done_all : Icons.timelapse,
                        color: ready
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFEFA856),
                      ),
                      title: Text(
                        itemName,
                        style: TextStyle(
                          color: ready ? Colors.grey : Colors.black,
                          decoration: ready
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Text(
                        "x ${quantity.toInt()}",
                        style: TextStyle(
                          color: ready ? Colors.grey : Colors.black,
                          decoration: ready
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          // orders list
          //
        ],
      ),
    );
  }

  Widget _ordersListSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF2F2F2),
      highlightColor: Colors.white,
      child: ListView.builder(
        itemBuilder: (c, i) {
          return Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5F5F5),
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}

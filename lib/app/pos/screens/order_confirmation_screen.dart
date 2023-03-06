import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:arabian_nights_frontend/app/pos/controllers/order_controller.dart';
import 'package:arabian_nights_frontend/app/pos/models/order_item_model.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/config/app.dart';

import '../../../constants.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final num floor;
  final num table;
  final List<MenuOrderItemModel> orderedItems;

  const OrderConfirmationScreen({
    Key? key,
    required this.floor,
    required this.table,
    required this.orderedItems,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  List<MenuOrderItemModel> orders = [];

  final TextEditingController _extraNotesTextController =
      TextEditingController();

  @override
  void initState() {
    setState(() {
      orders = widget.orderedItems;
    });
    super.initState();
  }

  _showEditDialog(MenuOrderItemModel item) {
    Size size = MediaQuery.of(context).size;
    double dialogWidth = size.width > 1000
        ? size.width * .6
        : size.width > 500
            ? size.width * .8
            : size.width;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final TextEditingController newQtyController =
            TextEditingController(text: item.quantity.toString());
        return Dialog(
          child: SizedBox(
            width: dialogWidth,
            height: 230,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Text(
                    "Edit Quantity",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: newQtyController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter quantity here...",
                    ),
                    onEditingComplete: () {
                      int? newQty = int.tryParse(newQtyController.text);
                      if (newQty != null) {
                        if (newQty > 0) {
                          _editQuantity(
                            item,
                            newQty,
                          );
                        } else if (newQty == 0) {
                          _removeItem(item);
                        }
                      }
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Dismiss"),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                      TextButton(
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.green),
                        ),
                        onPressed: () {
                          int? newQty = int.tryParse(newQtyController.text);
                          if (newQty != null) {
                            if (newQty > 0) {
                              _editQuantity(
                                item,
                                newQty,
                              );
                            } else if (newQty == 0) {
                              _removeItem(item);
                            }
                          }
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _removeItem(MenuOrderItemModel item) {
    setState(() {
      orders.remove(item);
    });
  }

  _editQuantity(MenuOrderItemModel item, int newQty) {
    setState(() {
      orders[orders.indexOf(item)] = MenuOrderItemModel(
        itemName: item.itemName,
        quantity: newQty,
        rate: item.rate,
      );
    });
  }

  void _confirmOrderBtnTap() async {
    String extraNotes = _extraNotesTextController.text;
    try {
      NavigatorState navigatorState = Navigator.of(context);
      var dio = Dio();
      var check = await dio.get(Constants.baseUrl + Constants.checkOrderExistenceUrl, data: {
        "floorNum": widget.floor,
        "tableNum": widget.table,
      });

      if (check.data["success"] == true) {
        // reset order items:
        await dio.post(Constants.baseUrl + Constants.resetOrderItemsUrl, data: {
          "floorNum": widget.floor,
          "tableNum": widget.table,
        });
        // overwrite existing order
        for (var item in orders) {
          await dio.post(
              Constants.baseUrl + Constants.addItemToOrderUrl, data: {
            "floorNum": widget.floor,
            "tableNum": widget.table,
            "itemName": item.itemName,
            "quantity": item.quantity,
            "rate": item.rate,
            "ready": item.ready,
          });
        }

        navigatorState.pop();
      }
      else {
        var res = await dio.post(
            Constants.baseUrl + Constants.createOrderUrl, data: {
          "floorNum": widget.floor,
          "tableNum": widget.table,
          "extras": extraNotes,
        });
        for (var item in orders) {
          await dio.post(
              Constants.baseUrl + Constants.addItemToOrderUrl, data: {
            "floorNum": widget.floor,
            "tableNum": widget.table,
            "itemName": item.itemName,
            "quantity": item.quantity,
            "rate": item.rate,
            "ready": item.ready,
          });
        }

        navigatorState.pop();
      }
      } catch (e) {
      showAlertDialog(
        context: context,
        title: "Oops!",
        description: e.toString(),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _confirmOrderBtnTap();
        },
        icon: const Icon(Icons.done),
        label: Text(
            "Confirm order: ${getOrdinalNumber(number: widget.floor.toInt(), short: true)}F-T${widget.table.toInt()}"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "Order confirmation"),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Items"), numeric: false),
                DataColumn(label: Text("Qty."), numeric: true),
                DataColumn(label: Text("Rate"), numeric: true),
              ],
              rows: [
                ...widget.orderedItems
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.itemName)),
                          DataCell(
                            Text("${item.quantity}"),
                            showEditIcon: true,
                            onTap: () {
                              _showEditDialog(item);
                            },
                          ),
                          DataCell(Text("${item.rate}$appCurrencySymbol")),
                        ],
                      ),
                    )
                    .toList()
              ],
            ),
          ),
          const SizedBox(height: 50),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text("Extra Notes"),
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
              controller: _extraNotesTextController,
              enableSuggestions: true,
              maxLines: 5,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Write instructions here...",
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

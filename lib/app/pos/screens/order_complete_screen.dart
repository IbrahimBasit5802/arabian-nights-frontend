import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/pos/controllers/order_controller.dart';
import 'package:arabian_nights_frontend/app/pos/screens/invoice_view_screen.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/invoice_details_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/config/app.dart';
import 'package:arabian_nights_frontend/config/payment_methods.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';

class OrderCompleteScreen extends ConsumerStatefulWidget {
  final num floor, table;

  const OrderCompleteScreen({
    Key? key,
    required this.floor,
    required this.table,
  }) : super(key: key);

  @override
  ConsumerState<OrderCompleteScreen> createState() =>
      _OrderCompleteScreenState();
}

class _OrderCompleteScreenState extends ConsumerState<OrderCompleteScreen> {
  bool _loading = true;
  num _taxRate = 0;

  num _itemsTotal = 0;
  num _itemsTotalTax = 0;
  num _payableTotal = 0;

  InvoiceDetailsModel? _invoiceDetails;
  List<dynamic> _orders = [];

  PaymentMethod? paymentMethod = PaymentMethod.card;

  @override
  void initState() {
    _getOrderInformation();
    super.initState();
  }

  _getOrderInformation() async {
    try {
      num taxRate = 0;
      DocumentSnapshot<InvoiceDetailsModel> arabian_nights_frontendInvoiceDetails =
          await getRestroInvoiceDetails();
      if (arabian_nights_frontendInvoiceDetails.exists) {
        InvoiceDetailsModel? invoiceDetails = arabian_nights_frontendInvoiceDetails.data();
        if (invoiceDetails != null) {
          taxRate = invoiceDetails.taxRate ?? 0;
          setState(() {
            _taxRate = invoiceDetails.taxRate ?? 0;
            _invoiceDetails = invoiceDetails;
          });
        }
      }

      // get orders
      Map<String, dynamic>? orderData =
          await getOrders(floor: widget.floor, table: widget.table);

      if (orderData != null) {
        List<dynamic> orderedItems = orderData["ordered_items"] ?? [];

        num itemsTotal = 0;
        num itemsTotalTax = 0;
        num totalPayable = 0;

        if (orderedItems.isNotEmpty) {
          for (var orderItem in orderedItems) {
            num quantity = orderItem["quantity"] ?? 1;
            num rate = orderItem["rate"] ?? 1;

            num orderItemTotal = rate * quantity;
            itemsTotal += orderItemTotal;
          }

          itemsTotalTax = (itemsTotal * taxRate) / 100;
          totalPayable = itemsTotal + itemsTotalTax;
        }

        setState(() {
          _orders = orderedItems;
          _itemsTotal = itemsTotal;
          _itemsTotalTax = itemsTotalTax;
          _payableTotal = totalPayable;
        });
      }
    } catch (e) {
      debugPrint("$e");
      showAlertDialog(context: context, title: "oops", description: "$e");
    }
    setState(() {
      _loading = false;
    });
  }

  void _btnCompleteOrderTap() async {
    if (_invoiceDetails != null &&
        paymentMethod != null &&
        _orders.isNotEmpty) {
      try {
        NavigatorState navigatorState = Navigator.of(context);
        ScaffoldMessengerState scaffoldMessengerState =
            ScaffoldMessenger.of(context);

        scaffoldMessengerState.showSnackBar(SnackBar(
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              CupertinoActivityIndicator(),
              Text("Please wait"),
            ],
          ),
        ));

        setState(() {
          _loading = true;
        });

        DocumentSnapshot? invoiceSnap = await completeOrder(
          floor: widget.floor,
          table: widget.table,
          orderedItems: _orders,
          taxRate: _taxRate,
          paymentMethod: PaymentMethod.card == paymentMethod
              ? PaymentMethod.card.name
              : PaymentMethod.cash.name,
        );

        if (invoiceSnap == null) {
          showAlertDialog(
            context: context,
            title: "oops!",
            description:
                "invoice not found!, you can check in invoices screen.",
          );
          setState(() {
            _loading = false;
          });
          return;
        }

        Map<String, dynamic>? invoiceData =
            invoiceSnap.data() as Map<String, dynamic>?;

        if (invoiceData == null) {
          showAlertDialog(
            context: context,
            title: "oops!",
            description:
                "invoice not found!, you can check in invoices screen.",
          );
          setState(() {
            _loading = false;
          });
          return;
        }

        scaffoldMessengerState.clearSnackBars();

        // goto invoice view page, and pop all other screen
        // navigatorState.popAndPushNamed(routeName)
        navigatorState.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => InvoiceViewScreen(
              invoiceData: invoiceData,
              arabian_nights_frontendInvoiceDetails: _invoiceDetails!,
            ),
          ),
          (route) => route.isFirst,
        );
      } catch (e) {
        log("$e", name: "order_complete_screen.dart");
        showAlertDialog(
          context: context,
          title: "oops!",
          description: "Error occured while completing order.",
        );
        setState(() {
          _loading = false;
        });
      }
    } else {
      showAlertDialog(
        context: context,
        title: "oops!",
        description:
            "arabian_nights_frontend Invoice details are missing.\nPlease add your arabian_nights_frontend's invoice details from settings.\nSo you can generate invoices.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _orders.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _loading ? null : _btnCompleteOrderTap,
              label: const Text("complete order"),
            ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(
              context: context,
              title:
                  "${getOrdinalNumber(number: widget.floor.toInt(), short: true)}F-T${widget.table.toInt()}"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          if (_loading) ...[
            _skeleton(),
          ] else ...[
            if (_orders.isNotEmpty) ...[
              _orderSummaryWidget(),
              const SizedBox(height: 40),
              _orderedItemsListWidget(),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Payment"),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.card,
                      groupValue: paymentMethod,
                      title: Text("Paid by ${PaymentMethod.card.name}"),
                      onChanged: (PaymentMethod? v) {
                        setState(() {
                          paymentMethod = v;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.cash,
                      groupValue: paymentMethod,
                      title: Text("Paid by ${PaymentMethod.cash.name}"),
                      onChanged: (v) {
                        setState(() {
                          paymentMethod = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                "There is no order(s) on this Table.",
                textAlign: TextAlign.center,
              ),
            ],
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Padding _orderedItemsListWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Items"), numeric: false),
          DataColumn(label: Text("Qty."), numeric: true),
          DataColumn(label: Text("Rate"), numeric: true),
        ],
        rows: [
          ..._orders
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        Icon(
                          item["ready"] ? Icons.done : Icons.timer_outlined,
                          color: item["ready"] ? Colors.green : Colors.amber,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            item["itemName"],
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )),
                    DataCell(
                      Text("${item['quantity']}"),
                    ),
                    DataCell(Text("${item['rate']}$appCurrencySymbol")),
                  ],
                ),
              )
              .toList()
        ],
      ),
    );
  }

  Padding _orderSummaryWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items Total"),
              Text("${_itemsTotal.toStringAsFixed(2)}$appCurrencySymbol"),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tax @ ${_taxRate.toStringAsFixed(2)}%"),
              Text("${_itemsTotalTax.toStringAsFixed(2)}$appCurrencySymbol"),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Payable Amount"),
              Text(
                "${_payableTotal.toStringAsFixed(2)}$appCurrencySymbol",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF2F2F2),
      highlightColor: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text("Please wait"),
        ],
      ),
    );
  }
}

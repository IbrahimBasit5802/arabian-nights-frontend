import 'dart:developer';

import 'package:arabian_nights_frontend/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:arabian_nights_frontend/app/pos/models/order_item_model.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> orderItems({
  required num floor,
  required num table,
  required String extras,
  required List<MenuOrderItemModel> items,
}) async {
  try {
    String docid = "${floor}f_t$table";

    DocumentReference ordersRef =
        _firestore.collection("table_orders").doc(docid);

    DocumentSnapshot docSnap = await ordersRef.get();

    List<Map<String, dynamic>> itemsMapList = [];

    for (var element in items) {
      itemsMapList.add({
        "rate": element.rate,
        "itemName": element.itemName,
        "ready": element.ready,
        "quantity": element.quantity,
      });
    }

    List<dynamic> existingItems = [];
    bool booked = false;

    if (docSnap.exists) {
      Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
      if (data != null) {
        booked = data["booked"] ?? false;
        existingItems = data["ordered_items"] ?? [];
      }
    }

    if (booked) {
      existingItems.addAll(itemsMapList);
      await ordersRef.set({
        "ordered_items": existingItems,
        "notes": extras,
      }, SetOptions(merge: true));
    } else {
      await ordersRef.set({
        "booked": true,
        "ordered_items": itemsMapList,
        "floor": floor,
        "table": table,
        "notes": extras,
        "order_booking_time": FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    debugPrint("$e");
    throw Exception("something went wrong while, ordering!");
  }
}

Future<Map<String, dynamic>?> getOrders({
  required num floor,
  required num table,
}) async {
  var res;
  try {
      var dio = Dio();
      res = await dio.get(Constants.baseUrl + Constants.getOrderUrl, data: {
        "floorNum": floor,
        "tableNum": table,
      });

    }


   catch (e) {
    debugPrint("$e");
    throw Exception("error while getting order details");
  }

  Map<String, dynamic> data = {};
  data["tableNum"] = res.data["order"]["tableNum"];
  data["floorNum"] = res.data["order"]["floorNum"];
  data["orderStatus"] = res.data["order"]["orderStatus"];
  data["extras"] = res.data["order"]["extras"];
  data["items"] = [];
  for (int i = 0; i < res.data["order"]["menuOrderItems"].length; i++) {
    Map<String, dynamic> item = {};
    item["itemName"] = res.data["order"]["menuOrderItems"][i]["itemName"];
    item["quantity"] = res.data["order"]["menuOrderItems"][i]["quantity"];
    item["rate"] = res.data["order"]["menuOrderItems"][i]["rate"];
    item["ready"] = res.data["order"]["menuOrderItems"][i]["ready"];
    data["items"].add(item);
  }
  print(data);
  return data;


}

// complete the order
Future<Map<String, dynamic>> completeOrder({
  required num floor,
  required num table,
  required List<dynamic> orderedItems,
  required num taxRate,
  required String paymentMethod,
}) async {
  try {
    DateTime now = DateTime.now();
    print(now.toString());
    String uniqueInvoiceID =
        "${getOrdinalNumber(number: floor.toInt(), short: true)}F-T$table-${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";
    var dio = Dio();
    var res = await dio.post(Constants.baseUrl + Constants.generateInvoiceUrl, data: {
      "floorNum": floor,
      "tableNum": table,
      "dateOfOrder": now.toString(),
      "orderedItems": orderedItems,
      "taxRate": taxRate,
      "payment_method": paymentMethod,
      "invoiceID": uniqueInvoiceID,
    });

    await dio.post(Constants.baseUrl + Constants.deleteOrderUrl, data: {
      "floorNum": floor,
      "tableNum": table,
    });
    Map<String, dynamic> data = {};
    data["tableNum"] = table;
    data["floorNum"] = floor;
    data["dateOfOrder"] = now.toString();
    data["orderedItems"] = orderedItems;
    data["taxRate"] = taxRate;
    data["payment_method"] = paymentMethod;
    data["invoiceID"] = uniqueInvoiceID;
    // add details to invoice collection

    return data;
  } catch (e) {
    log("$e");
    throw Exception("Error while completing order.");
  }
}

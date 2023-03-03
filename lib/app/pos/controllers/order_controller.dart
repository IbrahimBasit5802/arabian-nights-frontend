import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  try {
    String docid = "${floor}f_t$table";

    DocumentReference ordersRef =
        _firestore.collection("table_orders").doc(docid);

    DocumentSnapshot docSnap = await ordersRef.get();

    if (docSnap.exists) {
      Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
      if (data != null) {
        return data;
      }
    }

    return null;
  } catch (e) {
    debugPrint("$e");
    throw Exception("error while getting order details");
  }
}

// complete the order
Future<DocumentSnapshot?> completeOrder({
  required num floor,
  required num table,
  required List<dynamic> orderedItems,
  required num taxRate,
  required String paymentMethod,
}) async {
  try {
    String uidOfLoggedInarabian_nights_frontendUser = _auth.currentUser!.uid;

    String docid = "${floor}f_t$table";

    DateTime now = DateTime.now();
    String uniqueInvoiceID =
        "${getOrdinalNumber(number: floor.toInt(), short: true)}F-T$table-${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";

    DocumentReference tableDocRef =
        _firestore.collection("table_orders").doc(docid);

    // clear the table details
    await tableDocRef.set({
      "booked": false,
    });

    // add details to invoice collection
    DocumentReference invoiceRef = await _firestore.collection("invoices").add({
      'floor': floor,
      'table': table,
      'date': Timestamp.now(),
      'ordered_items': orderedItems,
      'generated_by': uidOfLoggedInarabian_nights_frontendUser,
      'unique_invoice_id': uniqueInvoiceID,
      'payment_method': paymentMethod,
      'taxRate': taxRate,
    });

    return await invoiceRef.get();
  } catch (e) {
    log("$e");
    throw Exception("error while completing order.");
  }
}

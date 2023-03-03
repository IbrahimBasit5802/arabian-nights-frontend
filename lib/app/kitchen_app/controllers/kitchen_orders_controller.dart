import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// get orders stream
Stream<QuerySnapshot> getKitcherOrdersStream({int limit = 50}) {
  return _firestore
      .collection("table_orders")
      .orderBy("order_booking_time", descending: false)
      .limit(limit)
      .snapshots();
}

Future<void> markOrderItemAsCompleted({
  required String docid,
  required List<dynamic> orders,
  required int orderIndex,
}) async {
  try {
    orders[orderIndex]["ready"] = true;

    await _firestore.collection("table_orders").doc(docid).update({
      "ordered_items": orders,
    });
  } catch (e) {
    log("$e", name: "kitchen_orders_controller.dart");
  }
}

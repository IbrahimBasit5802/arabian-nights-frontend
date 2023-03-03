import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<bool> addFloor() async {
  try {
    // await _firestore
    //     .collection("config")
    //     .doc("floors")
    //     .update({"total_floors": FieldValue.increment(1)});
    await _firestore.collection("config").doc("floors").set(
        {"total_floors": FieldValue.increment(1)}, SetOptions(merge: true));
    return true;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error saving invoice details.");
  }
}

Future<bool> minusFloor(int floor) async {
  try {
    if (floor > 0) {
      await _firestore
          .collection("config")
          .doc("floors")
          .update({"total_floors": FieldValue.increment(-1)});
      return true;
    }
    return false;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error saving invoice details.");
  }
}

Future<num> getFloors() async {
  try {
    DocumentSnapshot snap =
        await _firestore.collection("config").doc("floors").get();
    if (snap.exists) {
      Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;
      if (data != null) {
        num totalFloors = data["total_floors"] ?? 0;
        return totalFloors;
      }
    }
    return 0;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong.");
  }
}

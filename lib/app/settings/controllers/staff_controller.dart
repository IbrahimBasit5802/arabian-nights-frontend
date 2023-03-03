import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<QueryDocumentSnapshot?> searchUserForStaff(
    {required String fieldName, required String searchValue}) async {
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .where(fieldName, isEqualTo: searchValue)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while searching user.");
  }
}

Future<void> updateStaffRole(
    {required String uid, required String role}) async {
  try {
    await _firestore.collection("users").doc(uid).update({"role": role});
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while updating user.");
  }
}

Future<void> updateStaffDetails({
  required String uid,
  required String role,
  required String name,
  required String email,
  required String phoneNumber,
}) async {
  try {
    await _firestore.collection("users").doc(uid).update({
      "role": role,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
    });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while updating user.");
  }
}

Future<void> resetStaffRole({required String uid}) async {
  try {
    await _firestore.collection("users").doc(uid).update({"role": "user"});
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while updating user.");
  }
}

Future<List<QueryDocumentSnapshot>?> getStaffUsers() async {
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .where("role", isNotEqualTo: "user")
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs;
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while searching user.");
  }
}

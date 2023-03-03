import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<void> addUserInfo({
  required String email,
  required String userId,
  required String name,
  String phoneNumber = "",
}) async {
  try {
    await firestore.collection("users").doc(userId).set({
      "email": email,
      "createdAt": FieldValue.serverTimestamp(),
      "role": "user",
      "name": name,
      "phoneNumber": phoneNumber
    });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("Error adding User information to DB.");
  }
}

Future<Map<String, dynamic>?> getUserInfo() async {
  User? user = auth.currentUser;

  if (user != null) {
    String userId = user.uid;
    DocumentSnapshot docSnap =
        await firestore.collection("users").doc(userId).get();
    if (docSnap.exists) {
      Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
      return data;
    }
  }
  return null;
}

Future<void> logOut() async {
  FirebaseAuth auth = FirebaseAuth.instance;

  await auth.signOut();
}

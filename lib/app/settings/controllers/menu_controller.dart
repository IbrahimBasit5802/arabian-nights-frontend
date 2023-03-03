import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../constants.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

Future<void> addMenuCategory({required String title}) async {
  var dio = Dio();
  try {
    var response = await dio.post(Constants.baseUrl + Constants.createCategoryUrl,
        data: {"categoryName": title});

  } catch (e) {
    debugPrint(e.toString());
    throw Exception("Something went wrong while saving category");
  }
}



Future<List<QueryDocumentSnapshot>?> getMenuCategories() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection("menu").get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs;
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while getting menu categories");
  }
}

Future<String?> uploadMenuItemImage({
  required File file,
  required String category,
}) async {
  try {
    String fileName = file.uri.pathSegments.last;
    Reference storageRef = _storage.ref("menu_item_images/$category/$fileName");
    TaskSnapshot uploadTask = await storageRef.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error while uploading item image to Firebase storage.");
  }
}

Future<void> addMenuItem({
  required String itemName,
  required num itemPrice,
  required String categoryDocumentId,
  String image = "",
}) async {
  try {
    await _firestore.collection("menu").doc(categoryDocumentId).update({
      "items": FieldValue.arrayUnion([
        {
          "itemName": itemName,
          "itemPrice": itemPrice,
          "image": image,
        }
      ]),
    });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong while saving menu item");
  }
}

Future<void> deleteMenuItem(
    {required String categoryDocumentId,
    required dynamic menuItem,
    required List<dynamic> menuItems}) async {
  try {
    menuItems
        .removeWhere((element) => element["itemName"] == menuItem["itemName"]);
    if (menuItems.isEmpty) {
      await _firestore.collection("menu").doc(categoryDocumentId).update({
        "items": FieldValue.delete(),
      });
      return;
    }

    await _firestore.collection("menu").doc(categoryDocumentId).update({
      "items": menuItems,
    });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong while removing menu item.");
  }
}

Future<void> updateMenuItem({
  required String categoryDocumentId,
  required List<dynamic> menuItems,
}) async {
  try {
    await _firestore.collection("menu").doc(categoryDocumentId).update({
      "items": menuItems,
    });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong while removing menu item.");
  }
}

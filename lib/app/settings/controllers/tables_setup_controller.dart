import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../constants.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<dynamic> getTotalTables() async {
  try {
    DocumentSnapshot snapshot =
        await _firestore.collection("config").doc("tables").get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        return data["tables"] ?? [];
      }
    }
    return [];
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong. while fetching getTotalTables()");
  }
}

Future<void> updateTotalTables({required List<dynamic> tables, index}) async {
  try {
    var dio = Dio();
    await dio.post(
      Constants.baseUrl + Constants.updateTablesUrl,
      data: {"floorNum": index, "numTables": tables[index]["tables"]},
    );

  } catch (e) {
    debugPrint(e.toString());
    throw Exception("something went wrong. while updating updateTotalTables()");
  }
}

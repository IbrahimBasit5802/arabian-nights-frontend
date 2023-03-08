import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// get initial invoices
Future<List<dynamic>> getInvoices({
  int limit = 20,
  required String startDate,
}) async {
  try {
    var dio = Dio();

    List<dynamic> invoices = [];
    String endDate = startDate;
    var response;

    if (startDate != null) {
      response = await dio.get(Constants.baseUrl + Constants.getInvoiceByDateUrl, data:
      {
        "startDate": startDate,
        "endDate": endDate,
      }
      );

      for (var element in response.data["invoice"]) {
        List<dynamic> items = [];
        Map<String, dynamic> curr = {
          "invoiceId": element["invoiceId"],
          "floorNum": element["floorNum"],
          "tableNum": element["tableNum"],
          "dateOfOrder": element["dateOfOrder"],
          "payment_method": element["payment_method"],
          "taxRate": element["taxRate"],

        };
        for(var item in element["orderedItems"]){
          Map<String, dynamic> curr2 = {};

          curr2["itemName"] = item["itemName"];
          curr2["quantity"] = item["quantity"];
          curr2["rate"] = item["rate"];

          items.add(curr2);
        }
        curr["orderedItems"] = items;
        invoices.add(curr);
      }
    } else {
      response = await dio.get(Constants.baseUrl + Constants.getInvoiceByDateUrl, data:
      {
        "startDate": startDate,
        "endDate": endDate,
      }
      );
      for (var element in response.data["invoice"]) {
        List<dynamic> items = [];
        Map<String, dynamic> curr = {
          "invoiceId": element["invoiceId"],
          "floorNum": element["floorNum"],
          "tableNum": element["tableNum"],
          "dateOfOrder": element["dateOfOrder"],
          "payment_method": element["payment_method"],
          "taxRate": element["taxRate"],

        };
        for(var item in element["orderedItems"]){
          Map<String, dynamic> curr2 = {};

          curr2["itemName"] = item["itemName"];
          curr2["quantity"] = item["quantity"];
          curr2["rate"] = item["rate"];

          items.add(curr2);
        }
        curr["orderedItems"] = items;
        invoices.add(curr);
      }
    }

    if (invoices != null) {
      return invoices;
    }
    return [];
  } catch (e) {
    log("$e", name: "all_invoices_controller.dart");
    throw Exception("error while getting all invoices.");
  }
}


// get more invoices
Future<List<QueryDocumentSnapshot>> getMoreInvoices({
  int limit = 20,
  required QueryDocumentSnapshot lastDocument,
  DateTimeRange? dateRange,
}) async {
  try {
    QuerySnapshot invoices;

    if (dateRange != null) {
      invoices = await _firestore
          .collection("invoices")
          .orderBy("date", descending: true)
          .startAfterDocument(lastDocument)
          .where("date", isGreaterThanOrEqualTo: dateRange.start)
          .where("date", isLessThanOrEqualTo: dateRange.end)
          .limit(limit)
          .get();
    } else {
      invoices = await _firestore
          .collection("invoices")
          .orderBy("date", descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();
    }

    if (invoices.docs.isNotEmpty) {
      return invoices.docs;
    }
    return [];
  } catch (e) {
    log("$e", name: "all_invoices_controller.dart");
    throw Exception("error while getting all invoices.");
  }
}

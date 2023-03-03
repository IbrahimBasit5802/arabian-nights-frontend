import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// get initial invoices
Future<List<QueryDocumentSnapshot>> getInvoices({
  int limit = 20,
  DateTimeRange? dateRange,
}) async {
  try {
    QuerySnapshot invoices;

    if (dateRange != null) {
      invoices = await _firestore
          .collection("invoices")
          .orderBy("date", descending: true)
          .where("date", isGreaterThanOrEqualTo: dateRange.start)
          .where("date", isLessThanOrEqualTo: dateRange.end)
          .limit(limit)
          .get();
    } else {
      invoices = await _firestore
          .collection("invoices")
          .orderBy("date", descending: true)
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

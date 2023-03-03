import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> saveRestroInvoiceDetails({
  required InvoiceDetailsModel invoiceDetails,
}) async {
  try {
    await _firestore
        .collection("config")
        .doc("invoice")
        .withConverter(
          fromFirestore: InvoiceDetailsModel.fromFirestore,
          toFirestore: (InvoiceDetailsModel invoiceDetailsModel, options) =>
              invoiceDetailsModel.toFirestore(),
        )
        .set(invoiceDetails, SetOptions(merge: true));
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error saving invoice details.");
  }
}

Future<DocumentSnapshot<InvoiceDetailsModel>> getRestroInvoiceDetails() async {
  DocumentSnapshot<InvoiceDetailsModel> invoiceDetailsSnap = await _firestore
      .collection("config")
      .doc("invoice")
      .withConverter(
        fromFirestore: InvoiceDetailsModel.fromFirestore,
        toFirestore: (InvoiceDetailsModel invoiceDetailsModel, options) =>
            invoiceDetailsModel.toFirestore(),
      )
      .get();

  return invoiceDetailsSnap;
}

class InvoiceDetailsModel {
  final String? restaurantName;
  final String? address;
  final String? phone;
  final String? email;
  final num? taxRate;
  final String? taxId;
  final String? companyRegisterNumber;
  final String? foodLicenseNumber;
  final String? extraDetails;

  InvoiceDetailsModel({
    this.restaurantName,
    this.address,
    this.phone,
    this.email,
    this.taxRate = 0,
    this.taxId,
    this.companyRegisterNumber,
    this.foodLicenseNumber,
    this.extraDetails,
  });

  factory InvoiceDetailsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return InvoiceDetailsModel(
      restaurantName: data?["restaurantName"],
      address: data?["address"],
      phone: data?["phone"],
      email: data?["email"],
      taxRate: data?["taxRate"],
      taxId: data?["taxId"],
      companyRegisterNumber: data?["companyRegisterNumber"],
      foodLicenseNumber: data?["foodLicenseNumber"],
      extraDetails: data?["extraDetails"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (restaurantName != null) "restaurantName": restaurantName,
      if (address != null) "address": address,
      if (phone != null) "phone": phone,
      if (email != null) "email": email,
      if (taxRate != null) "taxRate": taxRate,
      if (taxId != null) "taxId": taxId,
      if (companyRegisterNumber != null)
        "companyRegisterNumber": companyRegisterNumber,
      if (foodLicenseNumber != null) "foodLicenseNumber": foodLicenseNumber,
      if (extraDetails != null) "extraDetails": extraDetails,
    };
  }
}

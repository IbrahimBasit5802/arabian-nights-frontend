import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../constants.dart';


Future<void> saveRestroInvoiceDetails({
  required InvoiceDetailsModel invoiceDetails,
}) async {
  try {
    var dio = Dio();
    await dio.post(Constants.baseUrl + Constants.saveInvoiceDetailsUrl,
        data: {
          "restaurantName": invoiceDetails.restaurantName,
          "address": invoiceDetails.address,
          "phone": invoiceDetails.phone,
          "email": invoiceDetails.email,
          "taxRate": invoiceDetails.taxRate,
          "taxId": invoiceDetails.taxId,
          "companyRegisterNumber": invoiceDetails.companyRegisterNumber,
          "foodLicenseNumber": invoiceDetails.foodLicenseNumber,
          "extraDetails": invoiceDetails.extraDetails,
        });
  } catch (e) {
    debugPrint(e.toString());
    throw Exception("error saving invoice details.");
  }
}

Future<Map<String, dynamic>> getRestroInvoiceDetails() async {

  Map<String, dynamic> invoiceDetailsData = {};
  try {
    var dio = Dio();
    Response response = await dio.get(Constants.baseUrl + Constants.getInvoiceDetailsUrl);
    invoiceDetailsData["restaurantName"] = response.data["invoice"]["restaurantName"];
    invoiceDetailsData["address"] = response.data["invoice"]["address"];
    invoiceDetailsData["phone"] = response.data["invoice"]["phone"];
    invoiceDetailsData["email"] = response.data["invoice"]["email"];
    invoiceDetailsData["taxRate"] = response.data["invoice"]["taxRate"];
    invoiceDetailsData["taxId"] = response.data["invoice"]["taxId"];
    invoiceDetailsData["companyRegisterNumber"] = response.data["invoice"]["companyRegisterNumber"];
    invoiceDetailsData["foodLicenseNumber"] = response.data["invoice"]["foodLicenseNumber"];
    invoiceDetailsData["extraDetails"] = response.data["invoice"]["extraDetails"];

  } catch (e) {
    debugPrint(e.toString());
    throw Exception("Error getting invoice details.");
  }
  return invoiceDetailsData;
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


}

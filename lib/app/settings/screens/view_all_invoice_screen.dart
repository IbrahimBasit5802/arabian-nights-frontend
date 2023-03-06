// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:arabian_nights_frontend/app/pos/screens/invoice_view_screen.dart';
// import 'package:arabian_nights_frontend/app/settings/controllers/all_invoices_controller.dart';
// import 'package:arabian_nights_frontend/app/settings/controllers/invoice_details_controller.dart';
// import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
// import 'package:arabian_nights_frontend/packages/shimmer.dart';
//
// class ViewAllInvoiceScreen extends StatefulWidget {
//   const ViewAllInvoiceScreen({super.key});
//
//   @override
//   State<ViewAllInvoiceScreen> createState() => _ViewAllInvoiceScreenState();
// }
//
// class _ViewAllInvoiceScreenState extends State<ViewAllInvoiceScreen> {
//   bool _isLoading = true;
//   final List<QueryDocumentSnapshot> _invoices = [];
//   late QueryDocumentSnapshot lastVisibleDocument;
//
//   late InvoiceDetailsModel _arabian_nights_frontendInvoiceDetails;
//
//   final ScrollController _invoiceListScrollController = ScrollController();
//
//   DateTimeRange? dateTimeRange;
//
//   @override
//   void initState() {
//     _getInvoices();
//     _getarabian_nights_frontendInvoiceDetails();
//
//     _invoiceListScrollController.addListener(() {
//       if (_invoiceListScrollController.position.extentBefore ==
//           _invoiceListScrollController.position.maxScrollExtent) {
//         if (dateTimeRange != null) {
//           _getMoreInvoices(dateRange: dateTimeRange);
//         } else {
//           _getMoreInvoices();
//         }
//       }
//     });
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _invoiceListScrollController.dispose();
//     super.dispose();
//   }
//
//   // get invoice meta data like : restaurant name, address, tax rate, contact, etc.
//   _getarabian_nights_frontendInvoiceDetails() async {
//     try {
//       Map<String, dynamic> invoiceDetails =
//           await getRestroInvoiceDetails();
//
//         if (invoiceDetails != null) {
//           setState(() {
//             invoiceDetails = invoiceDetails;
//           });
//         }
//       }
//     } catch (e) {
//       log("$e", name: "view_all_invoice_screen.dart");
//     }
//   }
//
//   _getInvoices({DateTimeRange? dateRange}) async {
//     //
//     try {
//       List<QueryDocumentSnapshot> allInvoices = [];
//       if (dateRange != null) {
//         allInvoices = await getInvoices(dateRange: dateRange);
//       } else {
//         allInvoices = await getInvoices();
//       }
//       _invoices.clear();
//       if (allInvoices.isNotEmpty) {
//         setState(() {
//           _isLoading = false;
//           _invoices.addAll(allInvoices);
//           lastVisibleDocument = allInvoices.last;
//         });
//         return;
//       }
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       log("$e", name: "view_all_invoice_screen.dart");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   _getMoreInvoices({DateTimeRange? dateRange}) async {
//     // get more invoices
//
//     try {
//       List<QueryDocumentSnapshot> allInvoices = [];
//       if (dateRange != null) {
//         allInvoices = await getMoreInvoices(
//             lastDocument: lastVisibleDocument, dateRange: dateRange);
//       } else {
//         allInvoices = await getMoreInvoices(lastDocument: lastVisibleDocument);
//       }
//       if (allInvoices.isNotEmpty) {
//         setState(() {
//           _invoices.addAll(allInvoices);
//           lastVisibleDocument = allInvoices.last;
//         });
//         return;
//       }
//     } catch (e) {
//       log("$e", name: "view_all_invoice_screen.dart");
//     }
//   }
//
//   _showFilterModal() async {
//     DateTimeRange? dateRange = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(DateTime.now().year - 20),
//       lastDate: DateTime.now(),
//     );
//
//     if (dateRange != null) {
//       log("$dateRange", name: "date range: view_all_invoice_screen.dart");
//       setState(() {
//         dateTimeRange = dateRange;
//       });
//       await _getInvoices(dateRange: dateRange);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("all invoices"),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               setState(() {
//                 dateTimeRange = null;
//               });
//               await _getInvoices();
//             },
//             icon: const Icon(Icons.settings_backup_restore_rounded),
//           ),
//           IconButton(
//             onPressed: () {
//               _showFilterModal();
//             },
//             icon: const Icon(Icons.filter_alt_outlined),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? _skeleton()
//           : _invoices.isNotEmpty
//               ? ListView.separated(
//                   separatorBuilder: (context, index) => const Divider(),
//                   controller: _invoiceListScrollController,
//                   itemBuilder: (ctx, index) {
//                     return _invoiceItemWidget(_invoices[index]);
//                   },
//                   itemCount: _invoices.length,
//                 )
//               : const Center(
//                   child: Text("No invoice found!"),
//                 ),
//     );
//   }
//
//   Widget _invoiceItemWidget(QueryDocumentSnapshot doc) {
//     Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
//     if (data == null) {
//       return Container();
//     }
//
//     String invoiceID = data["unique_invoice_id"] ?? "";
//     DateTime date = data["date"].toDate() ?? DateTime.now();
//     num floor = data["floor"] ?? 0;
//     num table = data["table"] ?? 0;
//
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => InvoiceViewScreen(
//               invoiceData: data,
//               arabian_nights_frontendInvoiceDetails: _arabian_nights_frontendInvoiceDetails,
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.apartment,
//                             color: Colors.grey,
//                           ),
//                           Text(
//                             "${getOrdinalNumber(number: floor.toInt(), short: true)}F",
//                             style: const TextStyle(
//                               color: Colors.grey,
//                             ),
//                           )
//                         ],
//                       ),
//                       const SizedBox(width: 30),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.table_bar,
//                             color: Colors.grey,
//                           ),
//                           Text(
//                             "T$table",
//                             style: const TextStyle(
//                               color: Colors.grey,
//                             ),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Invoice # $invoiceID",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     date.toString(),
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _skeleton() {
//     return Shimmer.fromColors(
//       baseColor: const Color(0xFFF2F2F2),
//       highlightColor: Colors.white,
//       child: ListView(
//         children: [
//           ...List.generate(
//             10,
//             (index) => Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
//               child: Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 100,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF2F2F2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         width: 140,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF2F2F2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: 180,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF2F2F2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ).toList()
//         ],
//       ),
//     );
//   }
// }

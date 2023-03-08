import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/all_invoices_controller.dart';
import 'package:arabian_nights_frontend/config/app.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _date;
  final List<dynamic> _invoices = [];
  bool _isLoading = false;

  // report data
  int _totalInvoicesGenerated = 0;
  num _totalItemsSold = 0;
  num _totalSaleAmount = 0;
  // report data

  _selectTheDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(const Duration(days: -(365 * 5))),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _isLoading = true;
      });


      // date
      DateTime startDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(startDate);
      DateTime endDate = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      DateTimeRange dateRange = DateTimeRange(start: startDate, end: endDate);


      List<dynamic> invoices =
          await getInvoices(limit: 1000, startDate: formattedDate);

      int totalInvoices = invoices.length;
      num totalItemsSold = 0;
      num totalSaleAmount = 0;

      for(var invoice in invoices) {
        totalItemsSold += invoice["orderedItems"].length;
        for (var item in invoice["orderedItems"]) {
          totalSaleAmount += item["rate"] * item["quantity"];
        }
      }

      setState(() {
        _date = selectedDate;
        _invoices.clear();
        _invoices.addAll(invoices);
        _isLoading = false;
        _totalInvoicesGenerated = totalInvoices;
        _totalItemsSold = totalItemsSold;
        _totalSaleAmount = totalSaleAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                _selectTheDate();
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text("Select the Date"),
            ),
          ),
          if (_date != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                  "Report showing for the Date ${_date!.year}/${_date!.month}/${_date!.day}"),
            ),
            const SizedBox(height: 20),
            if (_isLoading == false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.amber[100],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.receipt_long_rounded),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Total Invoices:",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$_totalInvoicesGenerated",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green[100],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.payments),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Total Sales:",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$_totalSaleAmount$appCurrencySymbol*",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Amount is Exclusive of Tax",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue[100],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.local_mall),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Items Sold:",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$_totalItemsSold",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ] else ...[
              // shimmer
              _shimmer()
              // shimmer
            ]
          ],
        ],
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber[100],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 28,
                    width: 100,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber[100],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 28,
                    width: 100,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber[100],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 28,
                    width: 100,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber[100],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 28,
                    width: 100,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

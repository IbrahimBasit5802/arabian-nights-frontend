import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:arabian_nights_frontend/app/pos/helpers/generate_order_pdf.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/invoice_details_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/config/app.dart';

class InvoiceViewScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;
  final InvoiceDetailsModel arabian_nights_frontendInvoiceDetails;

  const InvoiceViewScreen({
    super.key,
    required this.invoiceData,
    required this.arabian_nights_frontendInvoiceDetails,
  });

  @override
  Widget build(BuildContext context) {
    String uniqueInvoiceID = invoiceData["invoiceID"] ?? "";
    num table = invoiceData["tableNum"] ?? 0;
    num floor = invoiceData["floorNum"] ?? 0;
    String paymentMethod = invoiceData["payment_method"] ?? "";
    num taxRate = invoiceData["taxRate"] ?? 0;

    num itemsTotal = 0;
    num itemsTotalTax = 0;
    num totalPayable = 0;

    String invoiceDate = invoiceData["dateOfOrder"] ?? "";
    print(invoiceDate);
    List<dynamic> orderedItems = invoiceData["orderedItems"] ?? [];
    // calculate total
    if (orderedItems.isNotEmpty) {
      for (var orderItem in orderedItems) {
        num quantity = orderItem["quantity"] ?? 1;
        num rate = orderItem["rate"] ?? 1;

        num orderItemTotal = rate * quantity;
        itemsTotal += orderItemTotal;
      }

      itemsTotalTax = (itemsTotal * taxRate) / 100;
      totalPayable = itemsTotal + itemsTotalTax;
    }

    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final invoicePDF = generateOrderPdf(
                invoiceId: uniqueInvoiceID,
                paymentMethod: paymentMethod,
                date: invoiceDate,
                itemTotal: itemsTotal,
                taxRate: taxRate,
                totalTax: itemsTotalTax,
                payableTotal: totalPayable,
                items: orderedItems,
                arabian_nights_frontendInvoiceDetails: arabian_nights_frontendInvoiceDetails,
              );

              await Printing.layoutPdf(
                onLayout: (format) {
                  return Future(() => invoicePDF);
                },
                format: PdfPageFormat.roll80,
                name:
                    arabian_nights_frontendInvoiceDetails.restaurantName! + invoiceDate,
              );
            },
            key: UniqueKey(),
            heroTag: 'print_btn',
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.print_rounded),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              final invoicePDF = await generateOrderPdf(
                invoiceId: uniqueInvoiceID,
                paymentMethod: paymentMethod,
                date: invoiceDate,
                itemTotal: itemsTotal,
                taxRate: taxRate,
                totalTax: itemsTotalTax,
                payableTotal: totalPayable,
                items: orderedItems,
                arabian_nights_frontendInvoiceDetails: arabian_nights_frontendInvoiceDetails,
              );
              String fileName =
                  "${arabian_nights_frontendInvoiceDetails.restaurantName ?? ''}-${invoiceDate}.pdf";

              await Printing.sharePdf(
                filename: fileName,
                bytes: invoicePDF,
                subject:
                    "Invoice for your recent order from ${arabian_nights_frontendInvoiceDetails.restaurantName ?? ''}",
              );
            },
            key: UniqueKey(),
            heroTag: 'share_btn',
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(
            context: context,
            title: "Invoice detail",
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invoice # $uniqueInvoiceID",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Date: ${invoiceDate.toString()}",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.apartment,
                          color: Colors.grey,
                        ),
                        Text(
                          "${getOrdinalNumber(number: floor.toInt())} Floor",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 30),
                    Row(
                      children: [
                        const Icon(
                          Icons.table_bar,
                          color: Colors.grey,
                        ),
                        Text(
                          "T$table",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Text("Paid by $paymentMethod"),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Items Total"),
                    Text("$appCurrencySymbol${itemsTotal.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tax (VAT/GST) @ $taxRate%"),
                    Text(
                        "$appCurrencySymbol${itemsTotalTax.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Payable Amount"),
                    Text(
                        "$appCurrencySymbol${totalPayable.toStringAsFixed(2)}"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _orderedItemsListWidget(orderedItems),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  _orderedItemsListWidget(orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Items"), numeric: false),
          DataColumn(label: Text("Qty."), numeric: true),
          DataColumn(label: Text("Rate"), numeric: true),
        ],
        rows: [
          ...orders
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text(
                      item["itemName"],
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )),
                    DataCell(Text("${item['quantity']}")),
                    DataCell(Text("${item['rate']}$appCurrencySymbol")),
                  ],
                ),
              )
              .toList()
        ],
      ),
    );
  }
}

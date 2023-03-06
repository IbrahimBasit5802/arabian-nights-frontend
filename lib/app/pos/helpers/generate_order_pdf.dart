import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/invoice_details_controller.dart';
import 'package:arabian_nights_frontend/config/app.dart';

Future<Uint8List> generateOrderPdf({
  required String invoiceId,
  required String paymentMethod,
  required String date,
  required num itemTotal,
  required num taxRate,
  required num totalTax,
  required num payableTotal,
  required List<dynamic> items,
  required InvoiceDetailsModel arabian_nights_frontendInvoiceDetails,
}) async {
  final emoji = await PdfGoogleFonts.notoColorEmoji();

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.FittedBox(
              fit: pw.BoxFit.fitWidth,
              child: pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (arabian_nights_frontendInvoiceDetails.restaurantName != null) ...[
                      pw.Text(
                        arabian_nights_frontendInvoiceDetails.restaurantName ?? "",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                    if (arabian_nights_frontendInvoiceDetails.address != null) ...[
                      pw.Text(
                        arabian_nights_frontendInvoiceDetails.address ?? "",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                    if (arabian_nights_frontendInvoiceDetails.phone != null) ...[
                      pw.Text(
                        "Phone: ${arabian_nights_frontendInvoiceDetails.phone ?? ""}",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            pw.Divider(),

            pw.FittedBox(
              fit: pw.BoxFit.fitWidth,
              child: pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Invoice # $invoiceId",
                      style: pw.TextStyle(
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "Date: $date",
                      style: pw.TextStyle(
                        fontFallback: [emoji],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              "Paid by $paymentMethod",
              style: pw.TextStyle(
                fontFallback: [emoji],
              ),
            ),
            pw.Divider(),

            // pw.SizedBox(height: 20),

            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      "Item Name",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "Qty",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "Rate.",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                  ],
                ),
                ...items
                    .map((item) => pw.TableRow(
                          children: [
                            pw.Text(
                              item["itemName"],
                              style: pw.TextStyle(
                                fontFallback: [emoji],
                              ),
                            ),
                            pw.Text(
                              "${item['quantity']}",
                              style: pw.TextStyle(
                                fontFallback: [emoji],
                              ),
                            ),
                            pw.Text(
                              "${item['rate']}$appCurrencySymbol",
                              style: pw.TextStyle(
                                fontFallback: [emoji],
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                pw.TableRow(
                  children: [
                    pw.Text(
                      "Items Total",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "${itemTotal.toStringAsFixed(2)}$appCurrencySymbol",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      "Tax",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "${totalTax.toStringAsFixed(2)}$appCurrencySymbol",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      "Payable Amount",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                    pw.Text(
                      "${payableTotal.toStringAsFixed(2)}$appCurrencySymbol",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emoji],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.FittedBox(
              fit: pw.BoxFit.fitWidth,
              child: pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (arabian_nights_frontendInvoiceDetails.companyRegisterNumber != null) ...[
                      pw.Text(
                        "Reg.no: ${arabian_nights_frontendInvoiceDetails.companyRegisterNumber ?? ""}",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                    if (arabian_nights_frontendInvoiceDetails.taxId != null) ...[
                      pw.Text(
                        "Tax ID: ${arabian_nights_frontendInvoiceDetails.taxId ?? ""}",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                    if (arabian_nights_frontendInvoiceDetails.foodLicenseNumber != null) ...[
                      pw.Text(
                        "Food License: ${arabian_nights_frontendInvoiceDetails.foodLicenseNumber ?? ""}",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                    if (arabian_nights_frontendInvoiceDetails.extraDetails != null) ...[
                      pw.Text(
                        arabian_nights_frontendInvoiceDetails.extraDetails ?? "",
                        style: pw.TextStyle(
                          fontFallback: [emoji],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ); // Center
      },
    ),
  ); // Page

  // Uint8List invoicePdf = await pdf.save();
  return pdf.save();
}

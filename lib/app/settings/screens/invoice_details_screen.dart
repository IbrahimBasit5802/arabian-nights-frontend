import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/invoice_details_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _companyRegisterNumberController =
      TextEditingController();
  final TextEditingController _foodLicenseNumberController =
      TextEditingController();
  final TextEditingController _extraDetailsController = TextEditingController();

  bool _isBtnTapped = false;
  bool _loading = true;

  @override
  void initState() {
    _getInvoiceDetails();
    super.initState();
  }

  _getInvoiceDetails() async {
    setState(() {
      _loading = true;
    });
    try {
      DocumentSnapshot<InvoiceDetailsModel> invoiceSnap =
          await getRestroInvoiceDetails();
      if (invoiceSnap.exists) {
        InvoiceDetailsModel? invoiceDetails = invoiceSnap.data();
        if (invoiceDetails != null) {
          _restaurantNameController.text = invoiceDetails.restaurantName ?? "";
          _addressController.text = invoiceDetails.address ?? "";
          _emailController.text = invoiceDetails.email ?? "";
          _phoneController.text = invoiceDetails.phone ?? "";
          _taxRateController.text = invoiceDetails.taxRate != null
              ? invoiceDetails.taxRate.toString()
              : "0";
          _taxIdController.text = invoiceDetails.taxId ?? "";
          _companyRegisterNumberController.text =
              invoiceDetails.companyRegisterNumber ?? "";
          _foodLicenseNumberController.text =
              invoiceDetails.foodLicenseNumber ?? "";
          _extraDetailsController.text = invoiceDetails.extraDetails ?? "";
        }
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _btnSaveTap() async {
    try {
      setState(() {
        _isBtnTapped = true;
      });

      await saveRestroInvoiceDetails(
          invoiceDetails: InvoiceDetailsModel(
        restaurantName: _restaurantNameController.text,
        address: _addressController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        taxRate: double.tryParse(_taxRateController.text) ?? 0,
        taxId: _taxIdController.text,
        foodLicenseNumber: _foodLicenseNumberController.text,
        companyRegisterNumber: _companyRegisterNumberController.text,
        extraDetails: _extraDetailsController.text,
      ));
      showAlertDialog(
        context: context,
        title: "Done! ✅",
        description: "Invoice Details Saved.",
      );

      setState(() {
        _isBtnTapped = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Error occured while saving invoice details.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            customAppBar(context: context, title: "invoice details"),
            const SizedBox(height: 20),
            const SizedBox(height: 8),
            if (_loading) ...[
              _invoiceSkeleton(),
            ] else ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("Restaurant Name"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _restaurantNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Restaurant Name here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Address"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Address here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Phone"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Phone here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Email"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter email here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Tax Rate"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _taxRateController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Tax Rate here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Tax ID (GST, VAT, etc.)"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _taxIdController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Tax Identification Number here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Company Reg. No."),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _companyRegisterNumberController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Company registration number here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Food License No."),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _foodLicenseNumberController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Food Licence no. here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                ),
                child: const Text("Extra Notes (Footer)"),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _extraDetailsController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Extra details for footer here...",
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: _isBtnTapped ? null : _btnSaveTap,
                  child: const Text("save"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _invoiceSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF2F2F2),
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

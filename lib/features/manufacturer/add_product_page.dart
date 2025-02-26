import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/constants/block.dart';
import 'package:pharma_supply/features/manufacturer/manufacturer_home_page.dart';
import 'package:pharma_supply/features/manufacturer/models/medical_product_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:pharma_supply/widgets/SnackBarHelper.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController batchNumberController = TextEditingController();
  final TextEditingController compositionController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController dosageFormController = TextEditingController();
  final TextEditingController packagingTypeController = TextEditingController();
  final TextEditingController storageConditionsController =
      TextEditingController();
  final TextEditingController directionsForUseController =
      TextEditingController();
  final TextEditingController indicationsController = TextEditingController();
  final TextEditingController contraindicationsController =
      TextEditingController();
  final TextEditingController precautionsController = TextEditingController();
  final TextEditingController sideEffectsController = TextEditingController();
  final TextEditingController manufacturerNameController =
      TextEditingController();
  final TextEditingController manufacturerAddressController =
      TextEditingController();
  final TextEditingController regulatoryApprovalNumberController =
      TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController shapeController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();

  DateTime? manufacturingDate;
  DateTime? expiryDate;
  bool showLoadingOnButton = false;

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isManufacturing) async {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000),
      maxTime: DateTime(2100),
      onConfirm: (date) {
        setState(() {
          if (isManufacturing) {
            manufacturingDate = date;
          } else {
            expiryDate = date;
          }
        });
      },
    );
  }

  void _submitForm() async {
    setState(() {
      showLoadingOnButton = true; // Show the loader
    });

    if (_formKey.currentState!.validate()) {
      // Create a new MedicalTablet object
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      MedicalProduct medicalTablet = MedicalProduct(
        productName: productNameController.text,
        batchNumber: batchNumberController.text,
        composition: compositionController.text,
        ingredients: ingredientsController.text.split(','),
        manufacturingDate: manufacturingDate ?? DateTime.now(),
        expiryDate: expiryDate ?? DateTime.now(),
        dosageForm: dosageFormController.text,
        packagingType: packagingTypeController.text,
        storageConditions: storageConditionsController.text,
        directionsForUse: directionsForUseController.text,
        indications: indicationsController.text,
        contraindications: contraindicationsController.text.split(','),
        precautions: precautionsController.text.split(','),
        sideEffects: sideEffectsController.text.split(','),
        manufacturerName: manufacturerNameController.text,
        manufacturerAddress: manufacturerAddressController.text,
        regulatoryApprovalNumber: regulatoryApprovalNumberController.text,
        barcode: barcodeController.text,
        netWeight: double.tryParse(netWeightController.text) ?? 0.0,
        color: colorController.text,
        shape: shapeController.text,
        serialNumber: serialNumberController.text,
        manufacturerId: currentUserId!,
      );

      medicalTablet.serialNumber = generateUniqueSerialNumber();
      medicalTablet.barcode = generateBarcode(
          manufacturingDate: medicalTablet.manufacturingDate,
          serialNumber: medicalTablet.serialNumber,
          batchNumber: medicalTablet.batchNumber,
          expiryDate: medicalTablet.expiryDate,
          netWeight: medicalTablet.netWeight,
          productName: medicalTablet.productName);
      Map<String, dynamic> medicalProductJson = medicalTablet.toJson();
      await addToDb(medicalProductJson, medicalTablet.serialNumber)
          .then((v) async {
        Map<String, dynamic> lastProductBlock =
            await FirebaseService.getLastProductsChainBlock();
        Block lastBlock = Block.fromJson(lastProductBlock);

        Block newBlock = Block.mineBlock(
            lastBlock.index + 1, lastBlock.hash, medicalTablet.serialNumber, 2);
        Map<String, dynamic> newBlockJson = newBlock.toJson();
        await addBlock(newBlockJson, lastBlock.index + 1);
      });
      // Show success message

      await Future.delayed(
          const Duration(seconds: 2)); // Simulate a network call

      SnackBarHelper.showSnackBar(
        context,
        "Product is succesfully added.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      setState(() {
        showLoadingOnButton = false; // Show the loader
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ManufacturerHomePage(),
        ),
      );
    }
  }

  String generateUniqueSerialNumber() {
    Random random = Random();
    int timestampPart = DateTime.now().millisecondsSinceEpoch % 1000000000;
    int randomPart =
        random.nextInt(900000) + 100000; // Ensures it's always a 6-digit number
    return '$timestampPart$randomPart'.substring(0, 9).toString();
  }

  String generateBarcode({
    required String serialNumber,
    required String productName,
    required String batchNumber,
    required DateTime expiryDate,
    required DateTime manufacturingDate,
    required double netWeight,
  }) {
    return '$serialNumber|$productName|$batchNumber|'
        '${expiryDate.toIso8601String().split('T').first}|'
        '${manufacturingDate.toIso8601String().split('T').first}|'
        '${netWeight.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        // backgroundColor: Colors.purple,
        title: Text(
          'Product Form',
          style: AppTheme.headlineTextStyle
              .copyWith(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField('Product Name', productNameController),
              buildTextField('Batch Number', batchNumberController),
              buildTextField('Composition', compositionController),
              buildTextField(
                  'Ingredients (comma-separated)', ingredientsController),
              buildDatePicker('Manufacturing Date', isManufacturing: true),
              buildDatePicker('Expiry Date', isManufacturing: false),
              buildTextField('Dosage Form', dosageFormController),
              buildTextField('Packaging Type', packagingTypeController),
              buildTextField('Storage Conditions', storageConditionsController),
              buildTextField('Directions for Use', directionsForUseController),
              buildTextField('Indications', indicationsController),
              buildTextField('Contraindications (comma-separated)',
                  contraindicationsController),
              buildTextField(
                  'Precautions (comma-separated)', precautionsController),
              buildTextField(
                  'Side Effects (comma-separated)', sideEffectsController),
              buildTextField('Manufacturer Name', manufacturerNameController),
              buildTextField(
                  'Manufacturer Address', manufacturerAddressController),
              buildTextField('Regulatory Approval Number',
                  regulatoryApprovalNumberController),
              // buildTextField('Barcode', barcodeController),
              buildTextField('Net Weight (g)', netWeightController,
                  keyboardType: TextInputType.number),
              buildTextField('Color', colorController),
              buildTextField('Shape', shapeController),
              // buildTextField('Serial Number', serialNumberController),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppTheme.elevatedButtonStyle,
                onPressed: showLoadingOnButton ? null : _submitForm,
                child: showLoadingOnButton
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'ADD PRODUCT',
                        style: AppTheme.buttonTextStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTheme.inputTextStyle,
        keyboardType: keyboardType,
        decoration: AppTheme.inputDecoration.copyWith(
          labelText: label,
          labelStyle: AppTheme.inputTextStyle,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget buildDatePicker(String label, {required bool isManufacturing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyTextStyle,
          ),
          TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(0), // Makes it a square shape
                ),
              ),
              textStyle: MaterialStateProperty.all(AppTheme.chipTextStyle),
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blueAccent.withOpacity(0.5)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(16),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              elevation: MaterialStateProperty.all<double>(5),
            ),
            onPressed: () => _selectDate(context, isManufacturing),
            child: Text(isManufacturing
                ? (manufacturingDate != null
                    ? manufacturingDate!.toLocal().toString().split(' ')[0]
                    : 'Select Date')
                : (expiryDate != null
                    ? expiryDate!.toLocal().toString().split(' ')[0]
                    : 'Select Date')),
          ),
          // ElevatedButton(
          //   onPressed: () => _selectDate(context, isManufacturing),
          //   child: Text(isManufacturing
          //       ? (manufacturingDate != null ? manufacturingDate!.toLocal().toString().split(' ')[0] : 'Select Date')
          //       : (expiryDate != null ? expiryDate!.toLocal().toString().split(' ')[0] : 'Select Date')),
          // ),
        ],
      ),
    );
  }

  Future<void> addToDb(
      Map<String, dynamic> medicalProductJson, String serialNo) async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection('Products').doc(serialNo);
    await doc.set(medicalProductJson);
  }

  Future<void> addBlock(Map<String, dynamic> blockJson, int index) async {
    DocumentReference doc = FirebaseFirestore.instance
        .collection('ProductsChain')
        .doc(index.toString());
    await doc.set(blockJson);
  }
}

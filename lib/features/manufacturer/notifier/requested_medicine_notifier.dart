
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:pharma_supply/constants/block.dart';
import 'package:pharma_supply/features/manufacturer/models/medical_product_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:pharma_supply/widgets/snackbar_helper.dart';


class RequestedMedicineNotifier extends ChangeNotifier{
  final formKey = GlobalKey<FormState>();

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

  void selectDate(BuildContext context, bool isManufacturing) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000),
      maxTime: DateTime(2100),
      onConfirm: (date) {
        if (isManufacturing) {
          manufacturingDate = date;
        } else {
          expiryDate = date;
        }
        notifyListeners();
      },
    );
  }

  Future<void> submitForm(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    showLoadingOnButton = true;
    notifyListeners();

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
      barcode: '',
      netWeight: double.tryParse(netWeightController.text) ?? 0.0,
      color: colorController.text,
      shape: shapeController.text,
      serialNumber: '',
      manufacturerId: currentUserId!,
    );

    medicalTablet.serialNumber = generateUniqueSerialNumber();
    medicalTablet.barcode = generateBarcode(medicalTablet);

    await addToDb(medicalTablet.toJson(), medicalTablet.serialNumber)
        .then((v) async {
      Map<String, dynamic> lastProductBlock =
          await FirebaseService.getLastProductsChainBlock();
      Block lastBlock = Block.fromJson(lastProductBlock);
      Block newBlock = Block.mineBlock(
          lastBlock.index + 1, lastBlock.hash, medicalTablet.serialNumber, 2);
      await addBlock(newBlock.toJson(), lastBlock.index + 1);
    });
    // Provider.of<ManufacturerNotifier>(context, listen: false).fetchMedicines();
    SnackBarHelper.showSnackBar(context, "Product successfully added.",
        backgroundColor: Colors.green, textColor: Colors.white);

    showLoadingOnButton = false;
    
    Navigator.pop(context);
    notifyListeners();
  }

  String generateUniqueSerialNumber() {
    Random random = Random();
    int timestampPart = DateTime.now().millisecondsSinceEpoch % 1000000000;
    int randomPart = random.nextInt(900000) + 100000;
    return '$timestampPart$randomPart'.substring(0, 9);
  }

  String generateBarcode(MedicalProduct product) {
    return '''${product.serialNumber}|${product.productName}|${product.batchNumber}|
            ${product.expiryDate.toIso8601String().split('T').first}|
            ${product.manufacturingDate.toIso8601String().split('T').first}|
            ${product.netWeight.toStringAsFixed(2)}''';
  }

  Future<void> addToDb(Map<String, dynamic> data, String serialNo) async {
    await FirebaseFirestore.instance
        .collection('Products')
        .doc(serialNo)
        .set(data);
  }

  Future<void> addBlock(Map<String, dynamic> blockJson, int index) async {
    await FirebaseFirestore.instance
        .collection('ProductsChain')
        .doc(index.toString())
        .set(blockJson);
  }
}
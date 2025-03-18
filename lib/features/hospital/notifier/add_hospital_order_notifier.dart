import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/order_block.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class AddHospitalOrderNotifier extends ChangeNotifier {
  Map<String, dynamic>? _selectedMedicine;
  String? _selectedPatient;
  String? _selectedPatientName;
  List<Map<String, dynamic>> _medicineList = [];
  List<Map<String, dynamic>> _patientsList = [];

  bool _isLoading = false;
  bool _isButtonLoading = false;

  String? get selectedPatient => _selectedPatient;
  String? get selectedPatientName => _selectedPatientName;
  List<Map<String, dynamic>> get medicineList => _medicineList;
  List<Map<String, dynamic>> get patientsList => _patientsList;
  Map<String, dynamic>? get selectedMedicine => _selectedMedicine;

  bool get isLoading => _isLoading;
  bool get isButtonLoading => _isButtonLoading;
  set isButtonLoading(bool value) {
    _isButtonLoading = value;
    notifyListeners();
  }

  AddHospitalOrderNotifier() {
    fetchMedicinesList();
    fetchPatientsList();
  }

  Future<void> fetchMedicinesList() async {
    _isLoading = true;
    notifyListeners();

    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();
    _medicineList = snapshot.docs
        .map((doc) => {
              'productName': doc['productName'] as String,
              'manufacturerId': doc['manufacturerId'] as String,
              'manufacturerName': doc['manufacturerName'] as String,
            })
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPatientsList() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'Patient')
        .get();
    _patientsList = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  void selectMedicine(Map<String, dynamic>? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
  }

  void selectPatient(String? patientId) {
    _selectedPatient = patientId;
    _selectedPatientName =
        _patientsList.firstWhere((p) => p['id'] == patientId)['name'];
    notifyListeners();
  }

  String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000))
        .toString(); // Generates 6-digit OTP
  }

  String generateBatchNumber() {
    DateTime now = DateTime.now();
    String datePart =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String randomPart =
        List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    return "$datePart-$randomPart";
  }

  Future<void> placeOrder(BuildContext context) async {
    if (_selectedMedicine == null || _selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient, medicine.')),
      );
      return;
    }

    _isButtonLoading = true;
    notifyListeners();

    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    UserModel hospitalData = await FirebaseService.loggedInUser();
    Map<String, dynamic> orderData = {
      'id': orderId,
      'orderedBy': 'Hospital_$hospitalId',
      'orderedById': hospitalId,
      'medicine': selectedMedicine!['productName'],
      'current_handler': "Manufacturer",
      'currentTransistStatement': "Order Placed by Hospital",
      'manufacturer_id': selectedMedicine!['manufacturerId'],
      'manufacturer_name': selectedMedicine!['manufacturerName'],
      'delivered': false,
      'hospital_id': hospitalId,
      'hospital_name': hospitalData.name,
      'latestModifiedBy': '${hospitalData.name}_$hospitalId',
      'latestModifiedTimestamp': DateTime.now().toIso8601String(),
      'orderTimestamp': DateTime.now().toIso8601String(),
      'patient_id': _selectedPatient,
      'patient_name': _selectedPatientName,
      'batchNo': generateBatchNumber(),
    };

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .set(orderData);
    await createOrderBlockchain(orderData);

    String otp = generateOTP();
    await FirebaseFirestore.instance.collection('Notifications').add({
      'order_id': orderData['id'],
      'otp': otp,
      'batchNo': orderData['batchNo'],
      'message':
          "Your order has been placed successfully.\nUse OTP: $otp for verification.\nBatch Number - ${orderData['batchNo']}.\nMedicine: ${orderData['medicine']}",
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'unverified',
      'user_id': hospitalId,
      'user_name': hospitalData.name,
    });

    _isButtonLoading = false;
    notifyListeners();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed for $_selectedMedicine')),
    );
  }

  Future<void> createOrderBlockchain(Map<String, dynamic> orderData) async {
    Map<String, dynamic>? lastBlockData =
        await FirebaseService.getLastOrdersChainBlock(orderData['id']);

    OrderBlock lastBlock;
    if (lastBlockData.isEmpty) {
      lastBlock = OrderBlock(
          index: 0,
          previousHash: "0",
          nonce: 1,
          hash:
              'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
          order: 'Genesis Block',
          timeStamp: '',
          label: "0th Block",
          by: '',
          to: '');
    } else {
      lastBlock = OrderBlock.fromJson(lastBlockData);
    }

    int newIndex = lastBlock.index + 1;
    OrderBlock newBlock = OrderBlock.mineBlock(
        newIndex,
        lastBlock.hash,
        orderData['id'],
        2,
        'Order Created By Hospital',
        orderData['orderedBy'],
        'Manufacturer');

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderData['id'])
        .collection('orderChain')
        .doc(newIndex.toString())
        .set(newBlock.toJson());
  }
}

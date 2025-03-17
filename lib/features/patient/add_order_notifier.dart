import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/order_block.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class AddOrderNotifier extends ChangeNotifier {
  Map<String, dynamic>? _selectedMedicine;
  List<Map<String, dynamic>> _medicineList = [];
  bool _isLoading = false;
  String? _selectedManufacturer;
  String? _selectedManufacturerName;
  List<Map<String, dynamic>> _manufacturersList = [];

  String? get selectedManufacturer => _selectedManufacturer;
  String? get selectedManufacturerName => _selectedManufacturerName;
  List<Map<String, dynamic>> get manufacturersList => _manufacturersList;
  Map<String, dynamic>? get selectedMedicine => _selectedMedicine;
  List<Map<String, dynamic>> get medicineList => _medicineList;
  bool get isLoading => _isLoading;

  AddOrderNotifier() {
    fetchMedicinesList();
    // fetchManufacturersList();
  }

  Future<void> fetchManufacturersList() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'Manufacturer')
        .get();
    _manufacturersList = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();
    notifyListeners();
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

  void selectMedicine(Map<String, dynamic>? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
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

  String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000))
        .toString(); // Generates 6-digit OTP
  }

  Future<void> placeOrder(
      BuildContext context, Map<String, dynamic> orderData) async {
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a medicine before placing an order.')),
      );
      return;
    }

    _isLoading = true;
    if (context.mounted) notifyListeners();

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderData['id'])
        .set(orderData);
    await createOrderBlockchain(orderData);

    String otp = generateOTP();
    await FirebaseFirestore.instance.collection('Notifications').add({
      'order_id': orderData['id'],
      'otp': otp,
      'batchNo': orderData['batchNo'],
      'message':
          "Your order has been placed successfully. Use OTP: $otp for verification.",
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'unverified',
      'user_id': orderData['patient_id'],
      'user_name': orderData['patient_name'],
    });

    _isLoading = false;
    if (context.mounted) notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Order placed for ${_selectedMedicine?['productName']}')),
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
        'Order Created By ${FirebaseAuth.instance.currentUser!.uid}',
        orderData['orderedBy'],
        'Manufacturer');

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderData['id'])
        .collection('orderChain')
        .doc(newIndex.toString())
        .set(newBlock.toJson());
  }

  Future<void> addBlockToOrderChain(Map<String, dynamic> orderData) async {
    try {
      Map<String, dynamic>? lastBlockData =
          await FirebaseService.getLastOrdersChainBlock(orderData['id']);
      if (lastBlockData.isEmpty) {
        return;
      }

      OrderBlock lastBlock = OrderBlock.fromJson(lastBlockData);
      int newIndex = lastBlock.index + 1;
      OrderBlock newBlock = OrderBlock.mineBlock(
        newIndex,
        lastBlock.hash,
        orderData['id'],
        2,
        orderData['label'],
        orderData['by'],
        orderData['to'],
      );

      // Add the new block to Firestore in the same orderChain subcollection
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderData['id'])
          .collection('orderChain')
          .doc(newIndex.toString())
          .set(newBlock.toJson());

      // print("New block added to orderChain successfully!");
    } catch (e) {
      // print("Error adding block to orderChain: $e");
    }
  }
}

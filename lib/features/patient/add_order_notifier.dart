import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/order_block.dart';
import 'package:pharma_supply/features/patient/patient_home_notifier.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:provider/provider.dart';

class AddOrderNotifier extends ChangeNotifier {
  String? _selectedMedicine;
  List<String> _medicineList = [];
  bool _isLoading = false;

  String? get selectedMedicine => _selectedMedicine;
  List<String> get medicineList => _medicineList;
  bool get isLoading => _isLoading;

  AddOrderNotifier() {
    fetchMedicinesList();
  }

  Future<void> fetchMedicinesList() async {
    _isLoading = true;
    notifyListeners();

    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();
    _medicineList =
        snapshot.docs.map((doc) => doc['productName'] as String).toList();

    _isLoading = false;
    notifyListeners();
  }

  void selectMedicine(String? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
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
    notifyListeners();

    // String? patientId = FirebaseAuth.instance.currentUser?.uid;
    // String? patientName = FirebaseAuth.instance.currentUser?.displayName;
    // String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderData['id'])
        .set(orderData);
    await createOrderBlockchain(orderData);

    _isLoading = false;
    notifyListeners();

    // Ensure fetchOrders completes before closing the screen
    await Provider.of<PatientHomeNotifier>(context, listen: false)
        .fetchOrders();

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
    print("Calling from addBlockTOORderChain");
    try {
      Map<String, dynamic>? lastBlockData =
          await FirebaseService.getLastOrdersChainBlock(orderData['id']);
      print("${orderData['id']}");
      print("$lastBlockData");
      if (lastBlockData.isEmpty) {
        print(
            "No existing blocks found. Please create the Genesis block first.");
        return;
      }

      OrderBlock lastBlock = OrderBlock.fromJson(lastBlockData);
      print("COntinue 2");
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
      print("COntinue 3");

      // Add the new block to Firestore in the same orderChain subcollection
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderData['id'])
          .collection('orderChain')
          .doc(newIndex.toString())
          .set(newBlock.toJson());

      print("COntinue 4");
      // print("New block added to orderChain successfully!");
    } catch (e) {
      // print("Error adding block to orderChain: $e");
    }
  }
}

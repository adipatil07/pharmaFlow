import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/block.dart';
import 'package:pharma_supply/services/firebase_service.dart';

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

    final snapshot = await FirebaseFirestore.instance.collection('Products').get();
    _medicineList = snapshot.docs.map((doc) => doc['productName'] as String).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  void selectMedicine(String? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
  }

  Future<void> placeOrder(BuildContext context) async {
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medicine before placing an order.')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    String? patientId = FirebaseAuth.instance.currentUser?.uid;
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    Map<String, dynamic> orderData = {
      'orderId': orderId,
      'patientId': patientId,
      'medicine': _selectedMedicine,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance.collection('PatientOrders').doc(orderId).set(orderData);
    await updateOrderBlockchain(orderId);

    _isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed for $_selectedMedicine')),
    );
  }

  Future<void> updateOrderBlockchain(String orderId) async {
    Map<String, dynamic>? lastBlockData = await FirebaseService.getLastOrdersChainBlock();
        
    Block lastBlock;
    if (lastBlockData.isEmpty) {
      lastBlock = Block(
        index: 0,
        previousHash: "0",
        nonce: 1,
        hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        product: 'Genesis Block',
        timeStamp: '',
      );
    } else {
      lastBlock = Block.fromJson(lastBlockData);
    }

    int newIndex = lastBlock.index + 1;
    Block newBlock = Block.mineBlock(newIndex, lastBlock.hash, orderId, 2);

    await FirebaseFirestore.instance.collection('PatientOrderChain').doc(newIndex.toString()).set(newBlock.toJson());
  }
}

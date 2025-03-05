import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/order_block.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class AddHospitalOrderNotifier extends ChangeNotifier {
  String? _selectedMedicine;
  String? _selectedPatient;
  String? _selectedPatientName;
  List<String> _medicineList = [];
  List<Map<String, dynamic>> _patientsList = [];
  bool _isLoading = false;

  String? get selectedMedicine => _selectedMedicine;
  String? get selectedPatient => _selectedPatient;
  String? get selectedPatientName => _selectedPatientName;
  List<String> get medicineList => _medicineList;
  List<Map<String, dynamic>> get patientsList => _patientsList;
  bool get isLoading => _isLoading;

  AddHospitalOrderNotifier() {
    fetchMedicinesList();
    fetchPatientsList();
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

  void selectMedicine(String? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
  }

  void selectPatient(String? patientId) {
    _selectedPatient = patientId;
    _selectedPatientName =
        _patientsList.firstWhere((p) => p['id'] == patientId)['name'];
    notifyListeners();
  }

  Future<void> placeOrder(BuildContext context) async {
    if (_selectedMedicine == null || _selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient and medicine.')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    UserModel hospitalData = await FirebaseService.loggedInUser();
    Map<String, dynamic> orderData = {
      'id': orderId,
      'orderedBy': 'Hospital_$hospitalId',
      'orderedById': hospitalId,
      'medicine': _selectedMedicine,
      'current_handler': "Hospital",
      'currentTransistStatement': "Order Placed by Hospital",
      'delivered': false,
      'hospital_id': hospitalId,
      'hospital_name': hospitalData.name,
      'latestModifiedBy': '${hospitalData.name}_$hospitalId',
      'latestModifiedTimestamp': DateTime.now().toIso8601String(),
      'orderTimestamp': DateTime.now().toIso8601String(),
      'patient_id': _selectedPatient,
      'patient_name': _selectedPatientName,
    };

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .set(orderData);
    await createOrderBlockchain(orderData);

    _isLoading = false;
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
        'Distributor');

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderData['id'])
        .collection('orderChain')
        .doc(newIndex.toString())
        .set(newBlock.toJson());
  }
}

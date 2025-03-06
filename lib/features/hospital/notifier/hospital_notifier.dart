import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class HospitalNotifier extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  String? _selectedManufacturer;
  String? _selectedManufacturerName;
  bool _isButtonLoading = false;

  List<Map<String, dynamic>> _manufacturersList = [];
  List<Map<String, dynamic>> _pastOrders = [];
  List<Map<String, dynamic>> _requestedOrders = [];

  String? get selectedManufacturer => _selectedManufacturer;
  String? get selectedManufacturerName => _selectedManufacturerName;
  List<Map<String, dynamic>> get manufacturersList => _manufacturersList;
  List<Map<String, dynamic>> get pastOrders => _pastOrders;
  List<Map<String, dynamic>> get requestedOrders => _requestedOrders;
  bool get isButtonLoading => _isButtonLoading;

  set isButtonLoading(bool value) {
    _isButtonLoading = value;
    notifyListeners();
  }

  HospitalNotifier() {
    fetchOrders();
    fetchPastOrders();
    fetchManufacturersList();
    fetchRequestedOrders();
  }

  void updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
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

  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where("hospital_id",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('delivered', isEqualTo: false)
          .get();

      orders = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'medicine': doc['medicine'] ?? 'Unknown',
          'patient_name': doc['patient_name'] ?? 'Unknown',
          // 'status': doc['status'] ?? 'Pending',
        };
      }).toList();
    } catch (e) {
      // print("Error fetching orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPastOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isEmpty) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('orderedById', isEqualTo: userId)
          .where('delivered', isEqualTo: true)
          .get();

      _pastOrders = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // print("Error fetching orders: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRequestedOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isEmpty) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RequestedMedicines')
          .where('hospital_id', isEqualTo: userId)
          .orderBy('orderTimestamp', descending: true)
          .get();

      _requestedOrders = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // print("Error fetching orders: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void selectManufacturer(String? manufacturerId) {
    _selectedManufacturer = manufacturerId;
    _selectedManufacturerName =
        _manufacturersList.firstWhere((m) => m['id'] == manufacturerId)['name'];
    notifyListeners();
  }

  Future<void> placeMedicineOrder(BuildContext context, String text) async {
    isButtonLoading = true;
    notifyListeners();

    String? hospitalId = FirebaseAuth.instance.currentUser?.uid;
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    UserModel hospitalData = await FirebaseService.loggedInUser();
    Map<String, dynamic> orderData = {
      'id': orderId,
      'orderedBy': 'Hospital_$hospitalId',
      'orderedById': hospitalId,
      'medicine': text,
      'currentTransistStatement': "Medicine Requested by Hospital",
      'delivered': false,
      'hospital_id': hospitalId,
      'hospital_name': hospitalData.name,
      'latestModifiedBy': '${hospitalData.name}_$hospitalId',
      'latestModifiedTimestamp': DateTime.now().toIso8601String(),
      'orderTimestamp': DateTime.now().toIso8601String(),
      'status': 'Requested',
      'manufacturer_id': selectedManufacturer,
      'manufacturer_name': selectedManufacturerName,
    };

    await FirebaseFirestore.instance
        .collection('RequestedMedicines')
        .doc(orderId)
        .set(orderData);

    isButtonLoading = false;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed Successfully')),
    );
  }
}

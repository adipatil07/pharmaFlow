import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManufacturerNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get medicines => _medicines;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  ManufacturerNotifier() {
    fetchMedicines();
    fetchOrders();
  }

  Future<void> fetchMedicines() async {
    _isLoading = true;
    notifyListeners();
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('manufacturerId', isEqualTo: currentUserId)
          .get();
      _medicines = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _medicines = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    // String manufacturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          // .where('manufacturerId', isEqualTo: manufacturerId)
          .get();
      _orders = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}

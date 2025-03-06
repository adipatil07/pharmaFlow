import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManufacturerNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _pastOrders = [];
  List<Map<String, dynamic>> _requestedOrders = [];
  bool _isLoading = false;
  int selectedIndex = 0;

  List<Map<String, dynamic>> get medicines => _medicines;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get pastOrders => _pastOrders;
  List<Map<String, dynamic>> get requestedOrders => _requestedOrders;
  bool get isLoading => _isLoading;

  ManufacturerNotifier() {
    fetchMedicines();
    fetchOrders();
    fetchRequestedOrders();
    fetchPastOrders();
  }

  void updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchRequestedOrders() async {
    _isLoading = true;
    notifyListeners();
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('RequestedMedicines')
          .where('manufacturer_id', isEqualTo: currentUserId)
          .where('status', whereIn: ['Requested', 'In Review']).get();
      _requestedOrders = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _requestedOrders = [];
    }
    _isLoading = false;
    notifyListeners();
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
    String manufacturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('current_handler', isEqualTo: "Manufacturer")
          .where('manufacturer_id', isEqualTo: manufacturerId)
          .get();
      _orders = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPastOrders() async {
    _isLoading = true;
    notifyListeners();
    String manufacturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('delivered', isEqualTo: true)
          .where('manufacturer_id', isEqualTo: manufacturerId)
          .get();
      _pastOrders = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _pastOrders = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}

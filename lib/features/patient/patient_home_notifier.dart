import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHomeNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _pastOrders = [];
  bool _isLoading = false;

  int get selectedIndex => _selectedIndex;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get pastOrders => _pastOrders;
  bool get isLoading => _isLoading;

  void updateIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isEmpty) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('orderedById', isEqualTo: userId)
          .where('delivered', isEqualTo: false)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching orders: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPastOrders() async {
    _isLoading = true;
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
      print("Error fetching orders: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}

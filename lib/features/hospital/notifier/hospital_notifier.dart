import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HospitalNotifier extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];

  List<Map<String, dynamic>> _pastOrders = [];
  List<Map<String, dynamic>> _requestedOrders = [];

  List<Map<String, dynamic>> get pastOrders => _pastOrders;
  List<Map<String, dynamic>> get requestedOrders => _requestedOrders;

  void updateIndex(int index) {
    selectedIndex = index;
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
}

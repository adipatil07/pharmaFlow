import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HospitalNotifier extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];

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
      print("Error fetching orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}

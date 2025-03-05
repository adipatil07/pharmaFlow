import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class TransporterNotifier extends ChangeNotifier {
  int _screenSelected = 0;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> pastOrders = [];
  List<Map<String, dynamic>> activeOrders = [];
  bool isLoading = false;
  String? selectedOrderId;

  int get screenSelected => _screenSelected;

  void updateScreen(int index) {
    _screenSelected = index;
    fetchTransporterOrders();
    notifyListeners();
  }

  Future<void> fetchTransporterOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      UserModel transporter = await FirebaseService.loggedInUser();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where("assigned_transporter",
              isEqualTo: '${transporter.name}_${transporter.id}')
          .get();

      orders = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'medicine': doc['medicine'] ?? 'Unknown',
                'patient_name': doc['patient_name'] ?? 'Unknown',
                'hospital_name': doc['hospital_name'] ?? 'Unknown',
                'status': doc['status'] ?? 'Pending',
              })
          .where((order) => order['status'] != 'Delivered')
          .toList();

      activeOrders =
          orders.where((order) => order['status'] != 'Pending').toList();
    } catch (e) {
      print("Error fetching orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPastTransporterOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      UserModel transporter = await FirebaseService.loggedInUser();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where("assigned_transporter",
              isEqualTo: '${transporter.name}_${transporter.id}')
          .where("status", isEqualTo: "Delivered")
          .get();

      pastOrders = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'medicine': doc['medicine'] ?? 'Unknown',
          'patient_name': doc['patient_name'] ?? 'Unknown',
          'hospital_name': doc['hospital_name'] ?? 'Unknown',
          'status': doc['status'] ?? 'Pending',
        };
      }).toList();

      pastOrders =
          pastOrders.where((order) => order['status'] != 'Pending').toList();
    } catch (e) {
      print("Error fetching orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void selectOrder(String orderId) {
    selectedOrderId = orderId;
    notifyListeners();
  }

  Future<void> acceptOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'status': 'Accepted',
    });
    fetchTransporterOrders();
  }

  Future<void> rejectOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'status': 'Rejected',
    });
    fetchTransporterOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'status': newStatus,
    });
    fetchTransporterOrders();
  }

  Future<void> markAsDelivered(String orderId) async {
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'delivered': true,
    });
    fetchTransporterOrders();
  }
}

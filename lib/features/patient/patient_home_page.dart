import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/constants/block.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String? selectedMedicine;
  List<String> medicineList = [];

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Future<void> fetchMedicines() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();
    setState(() {
      medicineList =
          snapshot.docs.map((doc) => doc['productName'] as String).toList();
    });
  }

  Future<void> placeOrder() async {
    if (selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a medicine before placing an order.')),
      );
      return;
    }

    String? patientId = FirebaseAuth.instance.currentUser?.uid;
    String orderId = generateUniqueOrderId();
    Map<String, dynamic> orderData = {
      'orderId': orderId,
      'patientId': patientId,
      'medicine': selectedMedicine,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection('PatientOrders')
        .doc(orderId)
        .set(orderData);

    await updateOrderBlockchain(orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed for $selectedMedicine')),
    );
  }

  Future<void> updateOrderBlockchain(String orderId) async {
    Map<String, dynamic>? lastBlockData =
        await FirebaseService.getLastOrdersChainBlock();
        
    Block lastBlock;
    if (lastBlockData.isEmpty) {
      lastBlock = Block(
          index: 0,
          previousHash: "0",
          nonce: 1,
          hash:
              'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
          product: 'Genesis Block',
          timeStamp: '');
    } else {
      lastBlock = Block.fromJson(lastBlockData);
    }

    int newIndex = lastBlock.index + 1;
    Block newBlock = Block.mineBlock(newIndex, lastBlock.hash, orderId, 2);

    await FirebaseFirestore.instance
        .collection('PatientOrderChain')
        .doc(newIndex.toString())
        .set(newBlock.toJson());
  }

  String generateUniqueOrderId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Home',
            style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Medicine',
                border: OutlineInputBorder(),
              ),
              value: selectedMedicine,
              items: medicineList.map((medicine) {
                return DropdownMenuItem<String>(
                  value: medicine,
                  child: Text(medicine, style: AppTheme.bodyTextStyle),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedicine = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Place Order', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}

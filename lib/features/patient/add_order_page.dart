import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/features/patient/add_order_notifier.dart';
import 'package:pharma_supply/features/patient/patient_home_notifier.dart';
import 'package:provider/provider.dart';

class AddOrderPage extends StatelessWidget {
  const AddOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddOrderNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Order',
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AddOrderNotifier>(
            builder: (context, notifier, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  notifier.isLoading
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            labelText: 'Select Medicine',
                            border: OutlineInputBorder(),
                          ),
                          value: notifier.selectedMedicine,
                          items: notifier.medicineList.map((medicine) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: medicine,
                              child: Text(
                                  '${medicine['productName']}-${medicine['manufacturerName']}',
                                  style: AppTheme.bodyTextStyle),
                            );
                          }).toList(),
                          onChanged: (value) {
                            notifier.selectMedicine(value);
                          },
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: notifier.isLoading
                        ? null
                        : () async {
                            String? patientId =
                                FirebaseAuth.instance.currentUser?.uid;
                            DocumentSnapshot userDoc = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(patientId)
                                .get();
                            UserModel loggedInUser = UserModel.fromMap(
                                userDoc.data() as Map<String, dynamic>);
                            String orderId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            Map<String, dynamic> orderData = {
                              'id': orderId,
                              'orderedBy': '${loggedInUser.name}_$patientId',
                              'orderedById': '$patientId',
                              'patient_name': loggedInUser.name,
                              'patient_id': '$patientId',
                              'medicine':
                                  notifier.selectedMedicine!['productName'],
                              'current_handler': "Manufacturer",
                              'currentTransistStatement':
                                  "Order is Placed By Patient",
                              'manufacturer_id':
                                  notifier.selectedMedicine!['manufacturerId'],
                              'manufacturer_name': notifier
                                  .selectedMedicine!['manufacturerName'],
                              'delivered': false,
                              'hospital_name': 'NA',
                              'hospital_id': "NA",
                              'latestModifiedBy':
                                  '${loggedInUser.name}_$patientId',
                              'latestModifiedTimestamp':
                                  DateTime.now().toIso8601String(),
                              'orderTimestamp':
                                  DateTime.now().toIso8601String(),
                              'batchNo': notifier.generateBatchNumber(),
                            };
                            notifier.placeOrder(context, orderData);
                            Navigator.of(context).pop();
                            Provider.of<PatientHomeNotifier>(context,
                                    listen: false)
                                .fetchOrders();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: notifier.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Place Order', style: AppTheme.buttonTextStyle),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

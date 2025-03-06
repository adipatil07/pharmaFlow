import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/hospital/add_hospital_order.dart';
import 'package:pharma_supply/features/hospital/notifier/add_hospital_order_notifier.dart';
import 'package:pharma_supply/features/hospital/notifier/hospital_notifier.dart';
import 'package:pharma_supply/widgets/tracking_card.dart';
import 'package:provider/provider.dart';

class HospitalHomePage extends StatelessWidget {
  const HospitalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HospitalNotifier()..fetchOrders(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hospital Home',
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<HospitalNotifier>(
                  builder: (context, notifier, child) {
                    return ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: AppTheme.primaryColor,
                      color: Colors.black87,
                      textStyle: AppTheme.bodyTextStyle,
                      constraints: BoxConstraints(
                        minWidth: (MediaQuery.of(context).size.width - 64) / 3,
                      ),
                      isSelected: [
                        notifier.selectedIndex == 0,
                        notifier.selectedIndex == 1,
                        notifier.selectedIndex == 2,
                      ],
                      onPressed: (index) {
                        notifier.updateIndex(index);
                        if (index == 0) {
                          notifier.fetchOrders();
                        } else if (index == 1) {
                          notifier.fetchPastOrders();
                        }
                      },
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text("Active Orders"),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text("Past Orders"),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text("Request Medicine"),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Consumer<HospitalNotifier>(
                builder: (context, notifier, child) {
                  if (notifier.selectedIndex == 0) {
                    return _buildTrackOrders(notifier);
                  } else if (notifier.selectedIndex == 1) {
                    return _buildPastOrders(notifier);
                  } else {
                    return _buildRequestMedicine(
                        context, AddHospitalOrderNotifier());
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.accentColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddHospitalOrderPage()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

Widget _buildTrackOrders(HospitalNotifier notifier) {
  return notifier.isLoading
      ? const Center(child: CircularProgressIndicator())
      : notifier.orders.isEmpty
          ? const Center(
              child: Text("No active orders.",
                  style: TextStyle(color: Colors.black54)),
            )
          : ListView.builder(
              itemCount: notifier.orders.length,
              itemBuilder: (context, index) {
                final order = notifier.orders[index];
                return Card(
                  color: AppTheme.cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(vertical: 15),
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      "${order['patient_name']} - ${order['medicine']}",
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Order Id: ${order['id']}"),
                    children: [
                      TrackingCard(
                        orderId: order['id'],
                      ),
                    ],
                  ),
                );
              },
            );
}

Widget _buildPastOrders(HospitalNotifier notifier) {
  return notifier.isLoading
      ? const Center(child: CircularProgressIndicator())
      : notifier.pastOrders.isEmpty
          ? const Center(
              child: Text("No active orders.",
                  style: TextStyle(color: Colors.black54)),
            )
          : ListView.builder(
              itemCount: notifier.pastOrders.length,
              itemBuilder: (context, index) {
                final order = notifier.pastOrders[index];
                return Card(
                  color: AppTheme.cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    childrenPadding: EdgeInsets.symmetric(vertical: 15),
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      order['medicine'],
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Order Id: ${order['id']}"),
                    children: [
                      TrackingCard(
                        orderId: order['id'],
                        // status: 'Status',
                        // currentStep: 1,
                        // hasHospitalStep: true,
                      ),
                    ],
                  ),
                );
              },
            );
}

Widget _buildRequestMedicine(
    BuildContext context, AddHospitalOrderNotifier notifier) {
  TextEditingController medicineController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: medicineController,
          maxLines: 5,
          style: AppTheme.bodyTextStyle.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Medicine',
            labelStyle: AppTheme.bodyTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          onPressed: () {
            // if (notifier.isLoading) {
            //   const CircularProgressIndicator(color: Colors.white);
            // } else {
            String requestedMedicine = medicineController.text.trim();
            if (requestedMedicine.isNotEmpty) {
              // Handle the medicine request submission
              notifier.placeMedicineOrder(context, requestedMedicine);
              print("Requested Medicine: $requestedMedicine");
            }
            // }
          },
          child: const Text("Request Medicine",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

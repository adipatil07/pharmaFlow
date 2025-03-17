import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/hospital/add_hospital_order.dart';
import 'package:pharma_supply/features/hospital/notifier/hospital_notifier.dart';
import 'package:pharma_supply/features/patient/notification_page.dart';
import 'package:pharma_supply/widgets/tracking_card.dart';
import 'package:provider/provider.dart';

class HospitalHomePage extends StatelessWidget {
  const HospitalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HospitalNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hospital Home',
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Scanning') {
                  // Navigate to scanning page
                } else if (value == 'Notifications') {
                  // Navigate to notifications page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(),
                    ),
                  );
                } else if (value == 'Logout') {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'Scanning',
                  child: Text('Scanning'),
                ),
                PopupMenuItem(
                  value: 'Notifications',
                  child: Text('Notifications'),
                ),
                PopupMenuItem(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],
            ),
            // IconButton(
            //     onPressed: () async {
            //       await FirebaseAuth.instance.signOut();
            //       Navigator.pushReplacement(context,
            //           MaterialPageRoute(builder: (context) => LoginPage()));
            //     },
            //     icon: Icon(Icons.logout))
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
                        } else if (index == 2) {
                          notifier.fetchRequestedOrders();
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
                    return _buildRequestMedicine(context, notifier);
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
              child: Text("No Past orders.",
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
                      ),
                    ],
                  ),
                );
              },
            );
}

Widget _buildRequestMedicine(BuildContext context, HospitalNotifier notifier) {
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
        SizedBox(
          height: 15,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Manufacturer',
            border: OutlineInputBorder(),
          ),
          value: notifier.selectedManufacturer,
          items: notifier.manufacturersList.map((manufacturer) {
            return DropdownMenuItem<String>(
              value: manufacturer['id'],
              child: Text(manufacturer['name'], style: AppTheme.bodyTextStyle),
            );
          }).toList(),
          onChanged: notifier.selectManufacturer,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          onPressed: () {
            String requestedMedicine = medicineController.text.trim();
            if (requestedMedicine.isNotEmpty &&
                notifier.selectedManufacturer != null) {
              notifier.placeMedicineOrder(context, requestedMedicine);
              medicineController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Please enter medicine name & Manufacturer name."),
                ),
              );
            }
          },
          child: notifier.isButtonLoading
              ? const CircularProgressIndicator()
              : const Text(
                  "Request Medicine",
                  style: TextStyle(color: Colors.white),
                ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Consumer<HospitalNotifier>(
            builder: (context, notifier, child) {
              if (notifier.requestedOrders.isEmpty) {
                return const Center(
                  child: Text(
                    "No requested medicines.",
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }
              return ListView.builder(
                itemCount: notifier.requestedOrders.length,
                itemBuilder: (context, index) {
                  final medicine = notifier.requestedOrders[index];
                  return Card(
                    color: AppTheme.cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        medicine['medicine'],
                        style: AppTheme.bodyTextStyle.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Order Id: ${medicine['id']}",
                        style: AppTheme.bodyTextStyle.copyWith(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(medicine['status']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medicine['status'],
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'requested':
      return Colors.orange;
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.blueGrey;
  }
}

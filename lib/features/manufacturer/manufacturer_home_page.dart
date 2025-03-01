import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/features/manufacturer/add_product_page.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/manufacturer/notifier/manufacturer_notifier.dart';
import 'package:pharma_supply/features/patient/add_order_notifier.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:pharma_supply/widgets/transporter_selection_widget.dart';
import 'package:provider/provider.dart';

class ManufacturerHomePage extends StatefulWidget {
  const ManufacturerHomePage({super.key});

  @override
  _ManufacturerHomePageState createState() => _ManufacturerHomePageState();
}

class _ManufacturerHomePageState extends State<ManufacturerHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ManufacturerNotifier>(context, listen: false)
          .fetchMedicines();
      Provider.of<ManufacturerNotifier>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final manufacturerNotifier = Provider.of<ManufacturerNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manufacturer Dashboard",
          style: AppTheme.headlineTextStyle
              .copyWith(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: AppTheme.primaryColor,
              color: Colors.black87,
              textStyle: AppTheme.bodyTextStyle,
              constraints: BoxConstraints(
                minWidth: (MediaQuery.of(context).size.width - 48) / 2,
              ),
              isSelected: [_selectedIndex == 0, _selectedIndex == 1],
              onPressed: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                manufacturerNotifier.fetchOrders();
                manufacturerNotifier.fetchMedicines();
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("Medicines"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("View Orders"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildMedicinesList(manufacturerNotifier)
                : _buildOrdersList(manufacturerNotifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductForm()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicinesList(ManufacturerNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.medicines.isEmpty) {
      return const Center(
          child: Text("No medicines found.",
              style: TextStyle(color: Colors.black54)));
    }
    return ListView.builder(
      itemCount: notifier.medicines.length,
      itemBuilder: (context, index) {
        var medicine = notifier.medicines[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              medicine['productName'] ?? 'No Name',
              style: AppTheme.subtitleTextStyle
                  .copyWith(fontSize: 16, color: AppTheme.primaryColor),
            ),
            subtitle: Text(
              "Batch: ${medicine['batchNumber'] ?? 'N/A'}",
              style: AppTheme.chipTextStyle
                  .copyWith(color: AppTheme.headlineColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(ManufacturerNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      itemCount: notifier.orders.length,
      itemBuilder: (context, index) {
        var order = notifier.orders[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID: ${order['id']}",
                      style: AppTheme.subtitleTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Medicine: ${order['medicine']}",
                      style: AppTheme.chipTextStyle.copyWith(
                          fontSize: 14, color: AppTheme.headlineColor),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        Map<String, dynamic> orderData = {
                          'id': order['id'],
                          'label': "Manufacturer to Transporter",
                          "by": "Manufacturer",
                          "to": "Transporter",
                        };
                        try {
                          UserModel loggedInUser =
                              await FirebaseService.loggedInUser();
                          await FirebaseService.updateOrderDetails(
                              orderData['id'], {
                            "latestModifiedBy":
                                '${loggedInUser.name}_${loggedInUser.id}',
                            "latestModifiedTimestamp":
                                DateTime.now().toIso8601String(),
                            "current_handler": "Manufacturer",
                            "currentTransistStatement":
                                "Manufacturing to Transporter"
                          });
                        } catch (e) {
                          print("error");
                        }
                        if (order['id'] != null) {
                          await Provider.of<AddOrderNotifier>(context,
                                  listen: false)
                              .addBlockToOrderChain(orderData);
                        } else {
                          print("Error: Order ID is null");
                        }

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return TransporterSelectionWidget(
                                orderId: order['id'], notifier: notifier);
                          },
                        );
                      },
                      icon: Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

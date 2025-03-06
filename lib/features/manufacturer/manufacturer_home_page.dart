import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/features/manufacturer/add_product_page.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/manufacturer/notifier/manufacturer_notifier.dart';
import 'package:pharma_supply/features/manufacturer/requested_medicine_page.dart';
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
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
                isSelected: [
                  manufacturerNotifier.selectedIndex == 0,
                  manufacturerNotifier.selectedIndex == 1,
                  manufacturerNotifier.selectedIndex == 2,
                  manufacturerNotifier.selectedIndex == 3
                ],
                onPressed: (index) {
                  if (index == 0) {
                    manufacturerNotifier.fetchMedicines();
                  }
                  if (index == 1) {
                    manufacturerNotifier.fetchOrders();
                  }
                  if (index == 2) {
                    manufacturerNotifier.fetchPastOrders();
                  }
                  if (index == 3) {
                    manufacturerNotifier.fetchRequestedOrders();
                  }
                  manufacturerNotifier.updateIndex(index);
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Past Orders"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Requested Medcinies"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<ManufacturerNotifier>(
                builder: (context, ManufacturerNotifier notifier, child) {
              if (notifier.selectedIndex == 0) {
                return _buildMedicinesList(notifier);
              } else if (notifier.selectedIndex == 1) {
                return _buildOrdersList(notifier);
              } else if (notifier.selectedIndex == 2) {
                return _buildPastOrdersList(notifier);
              } else {
                return _buildRequestedMedicinesList(notifier);
              }
            }),
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

  Widget _buildRequestedMedicinesList(ManufacturerNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.requestedOrders.isEmpty) {
      return const Center(
          child: Text("No medicines found.",
              style: TextStyle(color: Colors.black54)));
    }
    return ListView.builder(
      itemCount: notifier.requestedOrders.length,
      itemBuilder: (context, index) {
        var medicine = notifier.requestedOrders[index];
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: ${medicine['id']}",
                        style: AppTheme.subtitleTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Medicine: ${medicine['medicine']}",
                        style: AppTheme.chipTextStyle.copyWith(
                            fontSize: 14, color: AppTheme.headlineColor),
                        // maxLines: 5,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await FirebaseService.updateRequestedMedicineDetails(
                            medicine['id'], {
                          "status": "In Review",
                          "currentTransistStatement":
                              "In Progress by Manufacturer"
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestedMedicinePage(
                              medicineId: medicine['id'],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await FirebaseService.updateRequestedMedicineDetails(
                            medicine['id'], {
                          "status": "Rejected",
                          "currentTransistStatement": "Rejected by Manufacturer"
                        });
                        notifier.fetchRequestedOrders();
                      },
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
                            "currentTransistStatement":
                                "Manufacturing to Transporter",
                            "status": "Pending"
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
                      onPressed: () {
                        _showCancelOrderDialog(context, order['id']);
                      },
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

Widget _buildPastOrdersList(ManufacturerNotifier notifier) {
  if (notifier.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (notifier.pastOrders.isEmpty) {
    return const Center(
      child: Text(
        "No Past Orders yet.",
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
  return ListView.builder(
    itemCount: notifier.pastOrders.length,
    itemBuilder: (context, index) {
      var order = notifier.pastOrders[index];
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
                    style: AppTheme.chipTextStyle
                        .copyWith(fontSize: 14, color: AppTheme.headlineColor),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showCancelOrderDialog(BuildContext context, String orderId) {
  TextEditingController reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Cancel Order",
          style: AppTheme.headlineTextStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please provide a reason for cancellation:"),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter reason...",
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reason cannot be empty!")),
                );
                return;
              }

              try {
                UserModel loggedInUser = await FirebaseService.loggedInUser();
                await FirebaseService.updateOrderDetails(orderId, {
                  // "status": "Cancelled",
                  "cancelReason": reasonController.text,
                  "latestModifiedBy": '${loggedInUser.name}_${loggedInUser.id}',
                  "latestModifiedTimestamp": DateTime.now().toIso8601String(),
                  "current_handler": "Patient",
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Order cancelled successfully!")),
                );
                Navigator.pop(context);
              } catch (e) {
                print("Error cancelling order: $e");
              }
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}

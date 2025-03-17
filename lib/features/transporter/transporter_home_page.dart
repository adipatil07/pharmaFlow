import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/constants/constants.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/features/patient/add_order_notifier.dart';
import 'package:pharma_supply/features/transporter/notifier/transporter_notifier.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_bar_code/qr/src/qr_code.dart';

class TransporterHomePage extends StatelessWidget {
  const TransporterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransporterNotifier()..fetchTransporterOrders(),
      child: Consumer<TransporterNotifier>(
        builder: (context, notifier, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Transporter Home Page",
                style: AppTheme.headlineTextStyle.copyWith(color: Colors.white),
              ),
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
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<TransporterNotifier>(
                      builder: (context, notifier, child) {
                        return ToggleButtons(
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Colors.white,
                          fillColor: AppTheme.primaryColor,
                          color: Colors.black87,
                          textStyle: AppTheme.bodyTextStyle,
                          constraints: BoxConstraints(
                            minWidth:
                                (MediaQuery.of(context).size.width - 48) / 2,
                          ),
                          isSelected: [
                            notifier.screenSelected == 0,
                            notifier.screenSelected == 1
                          ],
                          onPressed: (index) {
                            notifier.updateScreen(index);
                            if (index == 0) {
                              notifier.fetchTransporterOrders();
                            } else if (index == 1) {
                              notifier.fetchPastTransporterOrders();
                            }
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Text("Active"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Text("Past"),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Consumer<TransporterNotifier>(
                      builder: (context, notifier, child) {
                        return notifier.screenSelected == 0
                            ? _buildActiveOrders(notifier)
                            : _buildPastOrders(notifier);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastOrders(TransporterNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (notifier.pastOrders.isEmpty) {
      return const Center(
        child: Text(
          "No Past Orders Found",
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        itemCount: notifier.pastOrders.length,
        itemBuilder: (context, index) {
          final order = notifier.pastOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOrderTile(context, order, notifier, isPastOrder: true),
          );
        },
      );
    }
  }

  Widget _buildActiveOrders(TransporterNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (notifier.orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        itemCount: notifier.orders.length,
        itemBuilder: (context, index) {
          final order = notifier.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOrderTile(context, order, notifier),
          );
        },
      );
    }
  }

  void _showQRCodeDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: QRCode(data: data),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderTile(BuildContext context, Map<String, dynamic> order,
      TransporterNotifier notifier,
      {bool isPastOrder = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                Constants.PACKAGE_BOX_URL,
                width: 70,
                height: 70,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                },
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['medicine'] ?? "Unknown",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Patient: ${order['patient_name'] ?? "N/A"}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () {
                    _showQRCodeDialog(
                        context, '${order['batchNo']}|${order['id']}');
                  },
                  child:
                      const Icon(Icons.qr_code, size: 30, color: Colors.black)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn("Patient Name", order['patient_name'] ?? "N/A"),
              _infoColumn("Hospital", order['hospital_name'] ?? "N/A"),
            ],
          ),
          const SizedBox(height: 15),
          if (!isPastOrder &&
              order['status'] != "Accepted" &&
              order['status'] != "Picked Up" &&
              order['status'] != "In Transit" &&
              order['status'] != "Delivered")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Accept Order Logic
                      notifier.acceptOrder(order['id']);
                    },
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    label: Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Reject Order Logic
                    },
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
              ],
            )
          else if (!isPastOrder)
            SizedBox(
              height: 60,
              child: DropdownButtonFormField<String>(
                value: order['status'] ?? "Pending",
                decoration: InputDecoration(
                  labelText: "Update Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ["Accepted", "Picked Up", "In Transit", "Delivered"]
                    .map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newStatus) async {
                  notifier.updateOrderStatus(order['id'], newStatus!);

                  Map<String, dynamic> orderData = {
                    'id': order['id'],
                    'label': newStatus,
                    "by": "Transporter",
                    "to": "Patient",
                  };
                  try {
                    if (newStatus == "Delivered") {
                      notifier.markAsDelivered(order['id']);
                    }
                    if (order['id'] != null) {
                      await Provider.of<AddOrderNotifier>(context,
                              listen: false)
                          .addBlockToOrderChain(orderData);
                    } else {}
                    UserModel loggedInUser =
                        await FirebaseService.loggedInUser();
                    await FirebaseService.updateOrderDetails(orderData['id'], {
                      "latestModifiedBy":
                          '${loggedInUser.name}_${loggedInUser.id}',
                      "latestModifiedTimestamp":
                          DateTime.now().toIso8601String(),
                      "current_handler":
                          newStatus == "Delivered " ? "Patient" : "Transporter",
                      "currentTransistStatement": newStatus
                    });
                  } catch (e) {}
                },
              ),
            ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

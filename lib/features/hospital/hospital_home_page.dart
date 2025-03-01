import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/hospital/add_hospital_order.dart';
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
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
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
                      minWidth: (MediaQuery.of(context).size.width - 48) / 2,
                    ),
                    isSelected: [
                      notifier.selectedIndex == 0,
                      notifier.selectedIndex == 1
                    ],
                    onPressed: (index) {
                      notifier.updateIndex(index);
                      notifier.fetchOrders();
                    },
                    children: const [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text("Past Orders"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text("Track Orders"),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<HospitalNotifier>(
                builder: (context, notifier, child) {
                  return notifier.selectedIndex == 0
                      ? _buildPastOrders()
                      : _buildTrackOrders(notifier);
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
                        trackingId: order['id'],
                        status: 'Status',
                        currentStep: 1,
                        hasHospitalStep: true,
                      ),
                    ],
                  ),
                );
              },
            );
}

Widget _buildPastOrders() {
  return const Center(
    child: Text("Past Orders (Coming Soon)",
        style: TextStyle(color: Colors.black54)),
  );
}

import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/patient/add_order_page.dart';
import 'package:pharma_supply/features/patient/patient_home_notifier.dart';
import 'package:provider/provider.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientHomeNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Patient Home',
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<PatientHomeNotifier>(
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
                    onPressed: (index) => notifier.updateIndex(index),
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
              child: Consumer<PatientHomeNotifier>(
                builder: (context, notifier, child) {
                  return notifier.selectedIndex == 0
                      ? _buildPastOrders()
                      : _buildTrackOrders();
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
              MaterialPageRoute(builder: (context) => const AddOrderPage()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

Widget _buildTrackOrders() {
  return const Center(
    child: Text("Track Orders (Coming Soon)",
        style: TextStyle(color: Colors.black54)),
  );
}

Widget _buildPastOrders() {
  return const Center(
    child: Text("Past Orders (Coming Soon)",
        style: TextStyle(color: Colors.black54)),
  );
}

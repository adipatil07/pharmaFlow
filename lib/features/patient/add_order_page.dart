import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/patient/add_order_notifier.dart';
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
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Medicine',
                            border: OutlineInputBorder(),
                          ),
                          value: notifier.selectedMedicine,
                          items: notifier.medicineList.map((medicine) {
                            return DropdownMenuItem<String>(
                              value: medicine,
                              child:
                                  Text(medicine, style: AppTheme.bodyTextStyle),
                            );
                          }).toList(),
                          onChanged: notifier.selectMedicine,
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: notifier.isLoading
                        ? null
                        : () => notifier.placeOrder(context),
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

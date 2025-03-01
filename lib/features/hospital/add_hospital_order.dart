import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/hospital/notifier/add_hospital_order_notifier.dart';
import 'package:provider/provider.dart';

class AddHospitalOrderPage extends StatelessWidget {
  const AddHospitalOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddHospitalOrderNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Hospital Order',
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AddHospitalOrderNotifier>(
            builder: (context, notifier, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  notifier.isLoading
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Patient',
                            border: OutlineInputBorder(),
                          ),
                          value: notifier.selectedPatient,
                          items: notifier.patientsList.map((patient) {
                            return DropdownMenuItem<String>(
                              value: patient['id'],
                              child: Text(patient['name'],
                                  style: AppTheme.bodyTextStyle),
                            );
                          }).toList(),
                          onChanged: notifier.selectPatient,
                        ),
                  const SizedBox(height: 20),
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
                        : () async {
                            await notifier.placeOrder(context);
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

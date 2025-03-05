import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/manufacturer/notifier/manufacturer_notifier.dart';
import 'package:pharma_supply/services/firebase_service.dart';

class TransporterSelectionWidget extends StatefulWidget {
  final String orderId;
  final ManufacturerNotifier notifier;

  const TransporterSelectionWidget({
    super.key,
    required this.orderId,
    required this.notifier,
  });

  @override
  _TransporterSelectionWidgetState createState() =>
      _TransporterSelectionWidgetState();
}

class _TransporterSelectionWidgetState
    extends State<TransporterSelectionWidget> {
  String? selectedTransporter;
  List<Map<String, dynamic>> transporters = [];

  @override
  void initState() {
    super.initState();
    _fetchTransporters();
  }

  Future<void> _fetchTransporters() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("type", isEqualTo: "Transporter")
        .get();

    setState(() {
      transporters = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      // color: AppTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select a Transporter",
            style: AppTheme.headlineTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: transporters.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: transporters.length,
                    itemBuilder: (context, index) {
                      var transporter = transporters[index];
                      return RadioListTile<String>(
                        title: Text(
                          transporter['name'],
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        value: transporter['id'],
                        groupValue: selectedTransporter,
                        // fillColor: Color.fromARGB(255, 111, 136, 174),
                        onChanged: (value) {
                          setState(() {
                            selectedTransporter = value;
                          });
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedTransporter == null
                ? null
                : () async {
                    var selectedTransporterDetails = transporters.firstWhere(
                        (t) => t['id'] == selectedTransporter,
                        orElse: () => {});

                    if (selectedTransporterDetails.isNotEmpty) {
                      await FirebaseService.updateOrderDetails(widget.orderId, {
                        "assigned_transporter":
                            '${selectedTransporterDetails['name']}_${selectedTransporterDetails['id']}',
                        "current_handler": "Transporter"
                      });
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Center(
              child: Text(
                "Confirm Selection",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

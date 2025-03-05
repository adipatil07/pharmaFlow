import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_supply/constants/app_theme.dart';

class TrackingCard extends StatelessWidget {
  final String orderId;

  const TrackingCard({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .collection('orderChain') // Fetching subcollection
          .orderBy('index', descending: false) // Ensure correct order
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return Card(
          margin: const EdgeInsets.all(12),
          color: AppTheme.backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Order ID: $orderId",
                //   style: const TextStyle(
                //       fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 16),
                docs.isEmpty
                    ? const Center(child: Text("No tracking data available"))
                    : _buildStepper(docs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepper(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var step = docs[index].data() as Map<String, dynamic>;
        String label = step['label'] ?? "Unknown Step";
        String timestampStr = step['timeStamp'] ?? "";
        DateTime date = DateTime.tryParse(timestampStr) ?? DateTime.now();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      index == docs.length - 1 ? Colors.orange : Colors.green,
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                if (index < docs.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/patient/qr_view_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .where('user_id', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'unverified')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No notifications yet.",
                  style: TextStyle(color: Colors.black54)),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final message = notification['message'];
              final batchNo = notification['batchNo']; // Get batch number
              final otp = notification['otp']; // OTP stored in Firestore

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppTheme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.blue, size: 32),
                        onPressed: () {
                          // Open QR Scanner
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QRScannerScreen(batchNo: batchNo, otp: otp),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String batchNo;
  final String otp;

  const QRScannerScreen({super.key, required this.batchNo, required this.otp});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  void _updateStatus(String orderId) async {
    QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .where('batchNo', isEqualTo: widget.batchNo)
        .get();

    for (DocumentSnapshot doc in notificationsSnapshot.docs) {
      await doc.reference.update({'status': 'verified'});
    }

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .update({'status': 'verified', 'delivered': true});
  }

  void _validateQR(String scannedCode) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    if (scannedCode.split('|')[0].trim() == widget.batchNo) {
      Navigator.pop(context);
      Future.delayed(Duration(milliseconds: 300), () {
        _askForSecretKey(scannedCode.split('|')[1].trim());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("❌ Invalid QR Code! Batch number does not match")),
      );
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _askForSecretKey(String orderId) {
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Secret Key"),
        content: TextField(
          controller: otpController,
          decoration: const InputDecoration(hintText: "Enter OTP"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true; // Allow re-scanning if user cancels
              });
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (otpController.text == widget.otp) {
                // OTP matched - Verification successful
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Delivered Successfully!")),
                );
                _updateStatus(orderId); // Update status in Firestore
                Navigator.pop(context);
              } else {
                // Wrong OTP
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Wrong OTP! Try Again.")),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanning) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              String scannedCode = barcodes.first.rawValue ?? "";
              _validateQR(scannedCode);
            }
          }
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_supply/features/auth/login_page.dart';
import 'package:pharma_supply/features/manufacturer/add_product_page.dart';
import 'package:pharma_supply/constants/app_theme.dart';

class ManufacturerHomePage extends StatefulWidget {
  const ManufacturerHomePage({super.key});

  @override
  _ManufacturerHomePageState createState() => _ManufacturerHomePageState();
}

class _ManufacturerHomePageState extends State<ManufacturerHomePage> {
  int _selectedIndex = 0; // 0: Medicines, 1: View Orders

  Stream<List<Map<String, dynamic>>> fetchMedicines() {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance
        .collection('Products')
        .where('manufacturerId',
            isEqualTo: currentUserId) // Filter by manufacturerId
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
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
              isSelected: [_selectedIndex == 0, _selectedIndex == 1],
              onPressed: (index) {
                setState(() {
                  _selectedIndex = index;
                });
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
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildMedicinesList()
                : _buildViewOrders(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductForm(),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchMedicines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No medicines found.",
                  style: TextStyle(color: Colors.black54)));
        }
        var medicines = snapshot.data!;
        return ListView.builder(
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            var medicine = medicines[index];
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
      },
    );
  }

  Widget _buildViewOrders() {
    return const Center(
      child: Text("View Orders (Coming Soon)",
          style: TextStyle(color: Colors.black54)),
    );
  }
}

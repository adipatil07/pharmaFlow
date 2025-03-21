import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Future<Map<String, dynamic>?> getProductDetails(
      String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Products').doc(productId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null; // Product not found
      }
    } catch (e) {
      // print("Error fetching product details: $e");
      return null;
    }
  }

  static Future<int> getProductsListLength() async {
    final snapshot = await _firestore.collection('Products').get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.length;
    } else {
      return 0;
    }
  }

  static Future<Map<String, dynamic>> getLastProductsChainBlock() async {
    final snapshot = await _firestore.collection('ProductsChain').get();
    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> lastBlockData = snapshot.docs.last.data();
      return lastBlockData;
    } else {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getLastOrdersChainBlock(
      String orderId) async {
    try {
      final orderChainSnapshot = await _firestore
          .collection('Orders')
          .doc(orderId)
          .collection('orderChain') 
          .get();
      if (orderChainSnapshot.docs.isNotEmpty) {
        return orderChainSnapshot.docs.last
            .data(); 
      } else {
        return {};
      }
    } catch (e) {}

    return {}; // Return empty if no data found
  }

  static Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      // Register user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        type: userType,
        name: name,
        email: email,
        phone: phone,
        password:
            password, // Ideally, store only hashed passwords, but Firebase handles this internally
        isActive: true,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      return newUser;
    } catch (e) {
      // print("Error registering user: $e");
      return null;
    }
  }

  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID
      String userId = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Convert Firestore document to UserModel
        UserModel loggedInUser =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        return loggedInUser;
      } else {
        // print("User not found in Firestore.");
        return null;
      }
    } catch (e) {
      // print("Error logging in user: $e");
      return null;
    }
  }

  static Future<UserModel> loggedInUser() async {
    String? patientId = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();
    UserModel loggedInUser =
        UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    return loggedInUser;
  }

  static Future<void> updateOrderDetails(
      String id, Map<String, dynamic> data) async {
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('Orders').doc(id);
    await orderRef.update(data);
  }

  static Future<void> updateRequestedMedicineDetails(
      String id, Map<String, dynamic> data) async {
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('RequestedMedicines').doc(id);
    await orderRef.update(data);
  }
}

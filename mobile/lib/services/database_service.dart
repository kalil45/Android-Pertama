import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'balance': 0, // Initial balance
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile stream
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Save transaction
  Future<void> saveTransaction({
    required String uid,
    required String productCode,
    required String target,
    required double price,
    required String status,
  }) async {
    await _db.collection('users').doc(uid).collection('transactions').add({
      'productCode': productCode,
      'target': target,
      'price': price,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get transactions stream
  Stream<QuerySnapshot> getTransactions(String uid) {
    return _db.collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  // Top Up Balance (Simplified for Debugging)
  Future<void> topUpBalance(String uid, int amount) async {
    final userRef = _db.collection('users').doc(uid);
    
    try {
      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw Exception("User does not exist in database.");
      }

      int currentBalance = (snapshot.data()?['balance'] as num?)?.toInt() ?? 0;
      int newBalance = currentBalance + amount;
      
      await userRef.update({'balance': newBalance});
      
      // Also record this as a transaction
      await userRef.collection('transactions').add({
        'productCode': 'TOPUP',
        'target': 'E-Wallet',
        'price': amount,
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Purchase Product (Atomic)
  Future<void> purchaseProduct({
    required String uid,
    required String productCode,
    required String target,
    required int price,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    
    try {
      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        final data = snapshot.data();
        int currentBalance = (data?['balance'] as num?)?.toInt() ?? 0;
        
        if (currentBalance < price) {
          throw Exception("Insufficient balance!");
        }

        int newBalance = currentBalance - price;

        // Update balance
        transaction.update(userRef, {'balance': newBalance});
        
        // Record transaction
        final transactionRef = userRef.collection('transactions').doc();
        transaction.set(transactionRef, {
          'productCode': productCode,
          'target': target,
          'price': price,
          'status': 'success',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }
}

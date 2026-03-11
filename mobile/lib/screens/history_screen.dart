import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final databaseService = DatabaseService();
    
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (user == null) return const Center(child: Text('Please Login'));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0079C1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: databaseService.getTransactions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final productCode = data['productCode'] ?? 'Unknown';
              final target = data['target'] ?? '';
              final price = data['price'] ?? 0;
              final status = data['status'] ?? 'pending';
              final isSuccess = status == 'success';
              
              final timestamp = data['timestamp'] as Timestamp?;
              final dateStr = timestamp != null 
                  ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                  : 'Recent';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                leading: CircleAvatar(
                  backgroundColor: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  'Pembelian $productCode',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('$target'),
                    const SizedBox(height: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showTransactionDetail(context, data, currencyFormat),
              );
            },
          );
        },
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> data, NumberFormat currencyFormat) {
    final productCode = data['productCode'] ?? 'Unknown';
    final target = data['target'] ?? '';
    final price = data['price'] ?? 0;
    final status = data['status'] ?? 'pending';
    final isSuccess = status == 'success';
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null 
        ? DateFormat('dd MMMM yyyy, HH:mm:ss').format(timestamp.toDate())
        : 'Recent';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detail Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Status', status.toUpperCase(), valueColor: isSuccess ? Colors.green : Colors.red),
            _buildDetailRow('ID Transaksi', '#${timestamp?.millisecondsSinceEpoch ?? "N/A"}'),
            _buildDetailRow('Waktu', dateStr),
            const Divider(height: 32),
            _buildDetailRow('Produk', 'Pembelian $productCode'),
            _buildDetailRow('Nomor Tujuan', target),
            const Divider(height: 32),
            _buildDetailRow(
              'Total Bayar', 
              currencyFormat.format(price),
              isBold: true,
              fontSize: 18,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0079C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

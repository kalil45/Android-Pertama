import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final databaseService = DatabaseService();
    final authService = AuthService();

    if (user == null) return const Center(child: Text('Please Login'));

    return StreamBuilder<DocumentSnapshot>(
      stream: databaseService.getUserProfile(user.uid),
      builder: (context, snapshot) {
        String name = 'User';
        int balance = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? 'User';
          balance = (data['balance'] as num?)?.toInt() ?? 0;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildModernHeader(context, name, balance, authService),
                _buildActionGrid(context, user.uid, databaseService, name, balance),
                const SizedBox(height: 24),
                _buildPromotions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildModernHeader(BuildContext context, String name, int balance, AuthService authService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0079C1), Color(0xFF005596)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                   Icon(Icons.account_balance, color: Colors.white, size: 24),
                   SizedBox(width: 8),
                   Text(
                    'BCA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                   Text(
                    ' mobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => authService.signOut(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Selamat datang,',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    _formatCurrency(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildActionGrid(BuildContext context, String uid, DatabaseService dbService, String name, int balance) {
    final actions = [
      {'icon': Icons.info_outline, 'label': 'm-Info', 'color': Colors.blue},
      {'icon': Icons.swap_horiz, 'label': 'm-Transfer', 'color': Colors.blue},
      {'icon': Icons.payment, 'label': 'm-Payment', 'color': Colors.blue},
      {'icon': Icons.shopping_cart_outlined, 'label': 'm-Commerce', 'color': Colors.blue},
      {'icon': Icons.phone_android, 'label': 'Pulsa', 'color': Colors.orange},
      {'icon': Icons.data_usage, 'label': 'Paket Data', 'color': Colors.green},
      {'icon': Icons.flash_on, 'label': 'PLN', 'color': Colors.amber},
      {'icon': Icons.add_circle_outline, 'label': 'Top Up', 'color': Colors.green},
      {'icon': Icons.more_horiz, 'label': 'Lainnya', 'color': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return InkWell(
            onTap: () {
              if (action['label'] == 'Pulsa' || action['label'] == 'Paket Data' || action['label'] == 'PLN') {
                _showProductList(context, uid, dbService, action['label'] as String);
              } else if (action['label'] == 'm-Info') {
                _showAccountInfo(context, name, balance);
              } else if (action['label'] == 'Top Up') {
                _showTopUpDialog(context, uid, dbService);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur ${action['label']} akan segera hadir!')),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Promo Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAccountInfo(BuildContext context, String name, int balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF0079C1)),
            SizedBox(width: 10),
            Text('Info Saldo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nomor Rekening', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('1234567890', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Nama Pemilik', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Saldo Tersedia', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              _formatCurrency(balance),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0079C1)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProductList(BuildContext context, String uid, DatabaseService dbService, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Pilih $category', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: _buildProducts(context, uid, dbService, scrollController, category),
            ),
          ],
        ),
      ),
    );
  }


  void _handlePurchase(BuildContext context, String uid, DatabaseService dbService, int price, String productName) async {
    final targetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembelian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: $productName'),
            Text('Harga: ${_formatCurrency(price)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Tujuan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              String target = targetController.text.trim();
              if (target.isEmpty) return;
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              
              try {
                await dbService.purchaseProduct(
                  uid: uid,
                  productCode: productName,
                  target: target,
                  price: price,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembelian Berhasil!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Beli'),
          ),
        ],
      ),
    );
  }

  Widget _buildProducts(BuildContext context, String uid, DatabaseService dbService, ScrollController scrollController, String category) {
    List<Map<String, dynamic>> products = [];
    
    if (category == 'PLN') {
      products = [
        {'name': 'Token Listrik 20rb', 'price': 21500},
        {'name': 'Token Listrik 50rb', 'price': 51500},
        {'name': 'Token Listrik 100rb', 'price': 101500},
        {'name': 'Token Listrik 200rb', 'price': 201500},
      ];
    } else {
      products = [
        {'name': 'Pulsa Rp 5.000', 'price': 6500},
        {'name': 'Pulsa Rp 10.000', 'price': 11500},
        {'name': 'Pulsa Rp 20.000', 'price': 21500},
        {'name': 'Pulsa Rp 50.000', 'price': 51500},
        {'name': 'Pulsa Rp 100.000', 'price': 101500},
      ];
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: const Icon(Icons.flash_on, color: Colors.blue),
          title: Text(product['name']),
          subtitle: Text(_formatCurrency(product['price'])),
          trailing: ElevatedButton(
            onPressed: () => _handlePurchase(context, uid, dbService, product['price'], product['name']),
            child: const Text('Beli'),
          ),
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context, String uid, DatabaseService dbService) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Saldo'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah Top Up',
            hintText: 'Masukkan nominal (contoh: 50000)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _handleTopUp(context, uid, dbService, amountController.text),
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  void _handleTopUp(BuildContext context, String uid, DatabaseService dbService, String amountStr) async {
    int? amount = int.tryParse(amountStr.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    Navigator.pop(context); // Close dialog

    try {
      await dbService.topUpBalance(uid, amount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top Up ${_formatCurrency(amount)} Berhasil!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

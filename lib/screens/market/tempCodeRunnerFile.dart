import 'package:flutter/material.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';
import 'package:krishi_bondhu_app_bd/services/auth_service.dart';
import 'package:krishi_bondhu_app_bd/services/product_service.dart';
import 'package:krishi_bondhu_app_bd/utils/constants.dart';
import 'package:intl/intl.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  late Stream<List<Product>> _myProductsStream;
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndProducts();
  }

  void _loadUserAndProducts() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userId = user.id;
        _myProductsStream = _productService.getProductsForUser(_userId!);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteListing(Product product) async {
    final bool didConfirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('লিস্টিং ডিলিট করবেন?'),
            content: const Text(
                'আপনি কি নিশ্চিতভাবে এই পণ্যটি ডিলিট করতে চান? এটি ফেরত আনা যাবে না।'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('বাতিল করুন'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ডিলিট করুন'),
              ),
            ],
          ),
        ) ??
        false;

    if (didConfirm) {
      try {
        await _productService.deleteProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('লিস্টিং সফলভাবে ডিলিট করা হয়েছে'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার পণ্য তালিকা'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userId == null
              ? const Center(
                  child: Text('এটি দেখার জন্য আপনাকে লগইন করতে হবে।'))
              : StreamBuilder<List<Product>>(
                  stream: _myProductsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: ${snapshot.error}\n\nঅনুগ্রহ করে Firebase Console-এ গিয়ে একটি Index তৈরি করুন।',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'আপনি এখনো কোনো পণ্য লিস্ট করেননি।',
                          style: AppTextStyles.subtitle,
                        ),
                      );
                    }

                    final products = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildMyProductCard(product);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildMyProductCard(Product product) {
    final formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(product.createdAt.toDate());
    // --- ⚠️ সমাধান: `imageUrls[0]` ব্যবহার করুন ---
    final bool hasImages = product.imageUrls.isNotEmpty;
    final String thumbnailUrl = hasImages ? product.imageUrls[0] : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            thumbnailUrl, // <-- এখানে পরিবর্তন করা হয়েছে
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'মোট আছে: ${product.availableQuantity} ${product.unit}',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'পোস্ট করা হয়েছে: $formattedDate',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('এডিট'),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditListingScreen(product: product),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('ডিলিট'),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700),
                  onPressed: () {
                    _deleteListing(product);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

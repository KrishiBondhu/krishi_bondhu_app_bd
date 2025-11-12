import 'package:flutter/material.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';
import 'package:krishi_bondhu_app_bd/screens/market/create_listing_screen.dart';
import 'package:krishi_bondhu_app_bd/services/product_service.dart';
import 'package:krishi_bondhu_app_bd/utils/constants.dart';
import 'package:krishi_bondhu_app_bd/screens/market/product_detail_screen.dart';
import 'package:krishi_bondhu_app_bd/screens/market/my_listings_screen.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({super.key});

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'সব';

  final List<String> _categories = [
    'সব',
    'সবজি',
    'ফল',
    'শস্য',
    'বীজ',
    'সার',
    'কীটনাশক',
    'কৃষি সরঞ্জাম',
    'পশুখাদ্য',
    'অন্যান্য',
  ];

  // --- নতুন: ড্র্যাগ করার জন্য বাটনটির পজিশন ---
  Offset? _fabPosition;
  bool _hasBeenDragged = false;
  // --- শেষ ---

  @override
  Widget build(BuildContext context) {
    // --- নতুন: অ্যাপ বার এবং স্ক্রিনের মাপ ---
    final appBar = AppBar(
      title: const Text('কেনা-বেচা'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton.icon(
            icon: const Icon(Icons.storefront, color: Colors.white),
            label: const Text(
              'আমার পণ্য',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyListingsScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        )
      ],
    );

    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    // --- নতুন: বাটনটির প্রথম পজিশন সেট করা ---
    if (!_hasBeenDragged) {
      _fabPosition = Offset(
        size.width - 230, // বাটনটির আনুমানিক चौड़ाई + প্যাডিং
        size.height -
            appBar.preferredSize.height -
            topPadding -
            100, // নিচ থেকে ১০০ পিক্সেল উপরে
      );
    }
    // --- শেষ ---

    return Scaffold(
      appBar: appBar, // অ্যাপ বারটি এখানে ব্যবহার করুন

      // --- নতুন: Stack উইজেট ---
      // Stack ব্যবহার করা হয়েছে যাতে বাটনটি কন্টেন্টের উপরে ভাসতে পারে
      body: Stack(
        children: [
          // --- আপনার পুরনো কন্টেন্ট ---
          Column(
            children: [
              Container(
                height: 50,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.lightGreen,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _selectedCategory == 'সব'
                      ? _productService.getAllProducts()
                      : _productService
                          .getProductsByCategory(_selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: ${snapshot.error}\n\nঅনুগ্রহ করে Firebase Console-এ গিয়ে একটি Index তৈরি করুন (আগেরবার যেমন করেছিলেন)।',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'এই ক্যাটাগরিতে কোনো পণ্য পাওয়া যায়নি।',
                          style: AppTextStyles.subtitle,
                        ),
                      );
                    }
                    final products = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 100), // <-- বাটনের জন্য নিচে জায়গা
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // --- শেষ: পুরনো কন্টেন্ট ---

          // --- নতুন: ড্র্যাগ করা যায় এমন বাটন ---
          Positioned(
            left: _fabPosition!.dx,
            top: _fabPosition!.dy,
            child: Draggable(
              // ড্র্যাগ করার সময় বাটনটি কেমন দেখাবে
              feedback: FloatingActionButton.extended(
                onPressed: () {}, // feedback-এ onPressed লাগে না
                label: const Text('আপনার পণ্য বিক্রয় করুন'),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primaryGreen,
              ),
              // ড্র্যাগ করার সময় পুরনো জায়গায় কী দেখাবে (কিছুই না)
              childWhenDragging: Container(),
              // ড্র্যাগ করা শেষ হলে
              onDragEnd: (details) {
                setState(() {
                  _hasBeenDragged = true;
                  // নতুন পজিশন সেভ করুন (অ্যাপ বার এবং স্ট্যাটাস বারের উচ্চতা বাদ দিয়ে)
                  _fabPosition = Offset(
                    details.offset.dx,
                    details.offset.dy -
                        appBar.preferredSize.height -
                        topPadding,
                  );
                });
              },
              // আসল বাটনটি যা দেখা যাবে
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateListingScreen()),
                  );
                },
                label: const Text('আপনার পণ্য বিক্রয় করুন'),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
          ),
          // --- শেষ: নতুন বাটন ---
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    // --- ⚠️ সমাধান: `imageUrls[0]` ব্যবহার করুন ---
    final bool hasImages = product.imageUrls.isNotEmpty;
    final String thumbnailUrl = hasImages ? product.imageUrls[0] : '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: hasImages
                  ? Image.network(
                      thumbnailUrl, // <-- এখানে পরিবর্তন করা হয়েছে
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 50);
                      },
                    )
                  : Container(
                      // যদি কোনো ছবি না থাকে
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'মোট আছে: ${product.availableQuantity} ${product.unit}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

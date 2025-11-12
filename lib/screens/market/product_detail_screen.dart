import 'package:flutter/material.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';
import 'package:krishi_bondhu_app_bd/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gallery_view_screen.dart'; // <-- গ্যালারি পেজ ইম্পোর্ট

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final String? currentUserId; // <-- বর্তমান ইউজার আইডি এখানে আসবে

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.currentUserId, // <-- কনস্ট্রাক্টরে যোগ করুন
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ফোন কল করা সম্ভব হচ্ছে না।'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('কল করতে ব্যর্থ হয়েছে: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // --- গ্যালারি খোলার ফাংশন ---
  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryViewScreen(
          imageUrls: product.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String sellerAddress = 'ঠিকানা দেওয়া নেই';
    if (product.sellerUpazila != null && product.sellerDistrict != null) {
      sellerAddress = '${product.sellerUpazila}, ${product.sellerDistrict}';
    } else if (product.sellerDistrict != null) {
      sellerAddress = product.sellerDistrict!;
    }

    // --- ⚠️ সমাধান: `imageUrls[0]` ব্যবহার করুন ---
    final bool hasImages = product.imageUrls.isNotEmpty;
    final String mainImageUrl = hasImages ? product.imageUrls[0] : '';

    final bool isOwnProduct = product.sellerId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ⚠️ আপডেট করা ইমেজ সেকশন ---
            if (hasImages)
              InkWell(
                onTap: () =>
                    _openGallery(context, 0), // ট্যাপ করলে গ্যালারি খুলবে
                child: Hero(
                  tag: mainImageUrl,
                  child: Image.network(
                    mainImageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _imageErrorPlaceholder(),
                  ),
                ),
              )
            else
              _imageErrorPlaceholder(),

            // --- ⚠️ নতুন: থাম্বনেইল ছবির লিস্ট ---
            if (product.imageUrls.length > 1)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: product.imageUrls.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _openGallery(context, index),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // --- পণ্যের তথ্য ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '৳${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                    style: AppTextStyles.heading1
                        .copyWith(color: AppColors.primaryGreen, fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'মোট আছে: ${product.availableQuantity} ${product.unit}',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(product.category),
                    backgroundColor: AppColors.lightGreen,
                  ),
                  const Divider(height: 40),
                  Text(
                    'বিক্রেতার তথ্য',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(Icons.person, color: AppColors.white),
                    ),
                    title: Text(product.sellerName,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(sellerAddress),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(Icons.phone, color: AppColors.white),
                    ),
                    title: Text(product.sellerPhone ?? 'ফোন নম্বর দেওয়া নেই'),
                    subtitle: const Text('কল করতে নিচের বাটনে ট্যাপ করুন'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- কল বাটন (আপডেট করা) ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.call),
          label: Text(
              isOwnProduct ? 'এটি আপনার নিজের পণ্য' : 'বিক্রেতাকে কল করুন'),
          onPressed: (product.sellerPhone == null ||
                  product.sellerPhone!.isEmpty ||
                  isOwnProduct)
              ? null
              : () {
                  _makePhoneCall(context, product.sellerPhone!);
                },
        ),
      ),
    );
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child:
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 100),
    );
  }
}

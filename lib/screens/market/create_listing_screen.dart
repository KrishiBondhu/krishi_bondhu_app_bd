import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:krishi_bondhu_app_bd/models/user_model.dart' as app_user;
import 'package:krishi_bondhu_app_bd/services/auth_service.dart';
import 'package:krishi_bondhu_app_bd/services/product_service.dart';
import 'package:krishi_bondhu_app_bd/services/storage_service.dart';
import 'package:krishi_bondhu_app_bd/utils/constants.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ⚠️ StaggeredGridView ইম্পোর্ট করার দরকার নেই, আমরা GridView.builder ব্যবহার করবো

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  final StorageService _storageService = StorageService();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  String? _selectedCategory = 'সবজি';
  String? _selectedUnit = 'কেজি';
  final List<File> _images = [];
  bool _isLoading = false;

  final List<String> _categories = [
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
  final List<String> _units = [
    'কেজি',
    'পিস',
    'লিটার',
    'গ্রাম',
    'জোড়া',
    'মন',
    'বস্তা',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final List<XFile> pickedFiles =
          await picker.pickMultiImage(imageQuality: 70);
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    } else {
      final XFile? pickedFile =
          await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ফটো গ্যালারি (একাধিক ছবি)'),
                onTap: () {
                  _pickImages(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ক্যামেরা (একটি ছবি)'),
                onTap: () {
                  _pickImages(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('অনুগ্রহ করে কমপক্ষে একটি ছবি সিলেক্ট করুন'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      app_user.User? currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('বিক্রয় করার জন্য আপনাকে লগইন করতে হবে।');
      }

      List<String> imageUrls =
          await _storageService.uploadMultipleImages(_images);

      final newProduct = Product(
        productName: _nameController.text.trim(),
        category: _selectedCategory!,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0.0,
        unit: _selectedUnit!,
        availableQuantity: _quantityController.text.trim(),
        imageUrls: imageUrls,
        sellerId: currentUser.id,
        sellerName: currentUser.name,
        sellerPhone: currentUser.phone,
        sellerDistrict: currentUser.district,
        sellerUpazila: currentUser.upazila,
        createdAt: Timestamp.now(),
      );

      await _productService.createProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('আপনার পণ্যটি সফলভাবে লিস্ট করা হয়েছে!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('লিস্টিং ব্যর্থ হয়েছে: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আপনার পণ্য বিক্রয় করুন'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- ⚠️ সমাধান: GridView.builder ব্যবহার করুন ---
                    _buildImageGrid(),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'পণ্যের নাম (যেমন: ফজলি আম)'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'একটি নাম দিন'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'ক্যাটাগরি'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                                labelText: 'মূল্য (টাকা)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'মূল্য দিন';
                              }
                              if (double.tryParse(value) == null) {
                                return 'সঠিক সংখ্যা দিন';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(labelText: 'একক'),
                            items: _units.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedUnit = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                          labelText: 'মোট পরিমাণ (যেমন: ৫০)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'পরিমাণ লিখুন'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _submitListing,
                      child: const Text('লিস্টিং আপডেট করুন'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- ⚠️ সমাধান: GridView.builder দিয়ে নতুন UI ---
  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // প্রতি সারিতে ৩টি আইটেম
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: _images.length + 1, // +1 "Add" বাটনের জন্য
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == _images.length) {
          // এটি "Add" বাটন
          return InkWell(
            onTap: _showImagePickerOptions,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  Text('Add Photo', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }
        // এগুলো সিলেক্ট করা ছবি
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_images[index], fit: BoxFit.cover),
            ),
            // ছবি ডিলিট করার বাটন
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

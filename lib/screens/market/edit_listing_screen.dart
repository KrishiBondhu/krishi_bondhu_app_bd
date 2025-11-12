import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:krishi_bondhu_app_bd/services/product_service.dart';
import 'package:krishi_bondhu_app_bd/services/storage_service.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ⚠️ StaggeredGridView ইম্পোর্ট করার দরকার নেই

class EditListingScreen extends StatefulWidget {
  final Product product;

  const EditListingScreen({super.key, required this.product});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  final StorageService _storageService = StorageService();
  final ProductService _productService = ProductService();

  String? _selectedCategory;
  String? _selectedUnit;
  final List<File> _newImages = [];
  List<String> _existingImageUrls = [];
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _priceController = TextEditingController(
        text: widget.product.pricePerUnit.toStringAsFixed(0));
    _quantityController =
        TextEditingController(text: widget.product.availableQuantity);
    _selectedCategory = widget.product.category;
    _selectedUnit = widget.product.unit;
    _existingImageUrls = List<String>.from(widget.product.imageUrls);
  }

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
        _newImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    } else {
      final XFile? pickedFile =
          await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one image'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> finalImageUrls = List<String>.from(_existingImageUrls);

      if (_newImages.isNotEmpty) {
        List<String> newUrls =
            await _storageService.uploadMultipleImages(_newImages);
        finalImageUrls.addAll(newUrls);
      }

      Map<String, dynamic> updatedData = {
        'productName': _nameController.text.trim(),
        'category': _selectedCategory!,
        'pricePerUnit': double.tryParse(_priceController.text) ?? 0.0,
        'unit': _selectedUnit!,
        'availableQuantity': _quantityController.text.trim(),
        'imageUrls': finalImageUrls,
        'createdAt': Timestamp.now(),
      };

      await _productService.updateProduct(widget.product.id!, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('পণ্য সফলভাবে আপডেট করা হয়েছে!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('আপডেট ব্যর্থ হয়েছে: ${e.toString()}'),
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
        title: const Text('পণ্য এডিট করুন'),
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
                    const Center(
                        child: Text('ছবি পরিবর্তন বা যোগ করতে ট্যাপ করুন',
                            style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'পণ্যের নাম'),
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
                      decoration:
                          const InputDecoration(labelText: 'মোট পরিমাণ'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'পরিমাণ লিখুন'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _submitUpdate,
                      child: const Text('পরিবর্তন সেভ করুন'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- ⚠️ সমাধান: GridView.builder দিয়ে নতুন UI ---
  Widget _buildImageGrid() {
    int totalImages = _existingImageUrls.length + _newImages.length;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: totalImages + 1, // +1 for the "Add" button
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == totalImages) {
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

        // এটি একটি ছবি
        Widget imageWidget;
        bool isNewImage = index >= _existingImageUrls.length;

        if (isNewImage) {
          // এটি একটি নতুন File ছবি
          File imageFile = _newImages[index - _existingImageUrls.length];
          imageWidget = Image.file(imageFile, fit: BoxFit.cover);
        } else {
          // এটি একটি পুরনো Network ছবি
          String imageUrl = _existingImageUrls[index];
          imageWidget = Image.network(imageUrl, fit: BoxFit.cover);
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageWidget,
            ),
            // ছবি ডিলিট করার বাটন
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isNewImage) {
                      _newImages.removeAt(index - _existingImageUrls.length);
                    } else {
                      _existingImageUrls.removeAt(index);
                    }
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

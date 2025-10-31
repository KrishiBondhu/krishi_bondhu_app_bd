// lib/screens/settings/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:krishi_bondhu_app_bd/models/user_model.dart' as app_user;
import 'package:krishi_bondhu_app_bd/services/auth_service.dart';
import 'package:krishi_bondhu_app_bd/utils/bangladesh_data.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final AuthService _authService = AuthService();
  app_user.User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _selectedDistrict;
  String? _selectedUpazila;
  List<String> _upazilaList = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _phoneController.text = _currentUser!.phone ?? '';

        // === THIS IS THE FIX ===
        // Check if the saved district is valid before setting it
        if (_currentUser!.district != null &&
            BangladeshData.districtUpazilaMap
                .containsKey(_currentUser!.district)) {
          _selectedDistrict = _currentUser!.district; // Set the district
          _upazilaList =
              BangladeshData.districtUpazilaMap[_selectedDistrict!] ?? [];

          // Check if the saved upazila is valid before setting it
          if (_currentUser!.upazila != null &&
              _upazilaList.contains(_currentUser!.upazila)) {
            _selectedUpazila = _currentUser!.upazila; // Set the upazila
          } else {
            _selectedUpazila = null; // Saved upazila is invalid, so reset it
          }
        } else {
          _selectedDistrict = null; // Saved district is invalid, so reset it
          _upazilaList = [];
          _selectedUpazila = null;
        }
        // === END OF FIX ===
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading data: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    setState(() {
      _isSaving = true;
    });
    try {
      Map<String, dynamic> dataToUpdate = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'district': _selectedDistrict,
        'upazila': _selectedUpazila,
      };

      await _authService.updateUserProfileData(_currentUser!.id, dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // District Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    hint: const Text('Select District'),
                    isExpanded: true,
                    items:
                        BangladeshData.districtUpazilaMap.keys.map((district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                        _selectedUpazila = null; // Reset upazila
                        _upazilaList =
                            BangladeshData.districtUpazilaMap[newValue!] ?? [];
                      });
                    },
                    decoration:
                        const InputDecoration(prefixIcon: Icon(Icons.map)),
                  ),
                  const SizedBox(height: 16),

                  // Upazila Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUpazila,
                    hint: const Text('Select Upazila'),
                    isExpanded: true,
                    items: _upazilaList.map((upazila) {
                      return DropdownMenuItem<String>(
                        value: upazila,
                        child: Text(upazila),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedUpazila = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_city),
                      disabledBorder: _selectedDistrict == null
                          ? const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))
                          : null,
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  )
                ],
              ),
            ),
    );
  }
}

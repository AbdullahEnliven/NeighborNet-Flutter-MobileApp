import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbornet/features/chat/data/repositories/storageservice.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  File? _pickedImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _phoneController.text =
          data['phoneNumber'] ?? _auth.currentUser?.phoneNumber ?? '';
      setState(() {
        _profileImageUrl = data['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = _auth.currentUser!.uid;
      String? uploadedImageUrl = _profileImageUrl;

      // Upload new image if picked
      if (_pickedImage != null) {
        uploadedImageUrl = await _storageService.uploadimg(
          file: _pickedImage!,
          Chatid:
              'profile_pictures/$uid', // Use a separate folder or naming scheme
        );
      }

      await _firestore.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'photoUrl': uploadedImageUrl,
      }, SetOptions(merge: true));

      // Optionally update Firebase Auth displayName & photoURL
      await _auth.currentUser!.updateDisplayName(_nameController.text.trim());
      if (uploadedImageUrl != null) {
        await _auth.currentUser!.updatePhotoURL(uploadedImageUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null)
                                as ImageProvider<Object>?,
                      child: _pickedImage == null && _profileImageUrl == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                   TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,  // disable editing
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}

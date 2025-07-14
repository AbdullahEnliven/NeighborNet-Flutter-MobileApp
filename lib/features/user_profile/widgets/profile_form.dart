import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;
  String? _imageUrl;
  bool _isDataPrefilled = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Full name is required.")));
      return;
    }

    context.read<UserCubit>().saveProfile(
      name,
      _image,
      _addressController.text.trim(),
      _bioController.text.trim(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('fetch');
      Future.delayed(Duration(seconds: 5), () {
      context.read<UserCubit>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
 
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is SavedCompleted) {
          context.go('/');
        } else if (state is UserError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final isLoading = state is UserLoading;

          // Prefill user data once when UserLoaded state is emitted
          if (state is UserLoaded && !_isDataPrefilled) {
            final user = state.user;
            _nameController.text = user.name ?? '';
            _addressController.text = user.address ?? '';
            _bioController.text = user.bio ?? '';
            _imageUrl = user.photoUrl;
            _isDataPrefilled = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Avatar
                Stack(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                                  ? NetworkImage(_imageUrl!) as ImageProvider
                                  : null),
                        child:
                            (_image == null &&
                                (_imageUrl == null || _imageUrl!.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// Card Fields
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isDark ? Colors.grey[900] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildField(_nameController, "Full Name", Icons.person),
                        const SizedBox(height: 16),
                        _buildField(
                          _addressController,
                          "Home Address",
                          Icons.home,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          _bioController,
                          "Short Bio (Optional)",
                          Icons.info_outline,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _onSave,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(isLoading ? "Saving..." : "Save and Continue"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: isLoading
                          ? Colors.green[100]
                          : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

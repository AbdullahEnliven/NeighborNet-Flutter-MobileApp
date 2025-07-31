import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbornet/features/post/presentation/cubit/post_form_cubit.dart';
import 'package:neighbornet/features/user_profile/cubit/user_cubit.dart';
import 'package:neighbornet/features/user_profile/cubit/user_state.dart';

class PostFormPage extends StatefulWidget {
  final String title;
  final List<FormFieldData> fields;

  const PostFormPage({super.key, required this.title, required this.fields});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class FormFieldData {
  final String label;
  final String? hint;
  final TextInputType inputType;
  final bool isMultiline;
  final bool isRequired;
  final bool isImage;

  FormFieldData({
    required this.label,
    this.hint,
    this.inputType = TextInputType.text,
    this.isMultiline = false,
    this.isRequired = true,
    this.isImage = false,
  });
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  final Map<String, XFile?> _images = {};
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 1;
  bool _allowContact = true;
  bool _sendAnonymously = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var field in widget.fields)
        if (!field.isImage) field.label: TextEditingController(),
    };
    for (var field in widget.fields) {
      if (field.isImage) {
        _images[field.label] = null;
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(String label) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images[label] = image;
      });
    }
  }

  void _removeImage(String label) {
    setState(() {
      _images[label] = null;
    });
  }

  String get userName {
    final state = context.read<UserCubit>().state;
    return (state is UserLoaded) ? state.user.name : '';
  }

  String get userPhone {
    final state = context.read<UserCubit>().state;
    return (state is UserLoaded) ? state.user.phoneNumber : '';
  }

  void _submit(String content) {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info not loaded")));
      return;
    }

    final user = userState.user;
    final postId = FirebaseFirestore.instance.collection('posts').doc().id;

    context.read<PostFormCubit>().submitForm(
      postType: widget.title,
      textFields: {
        for (var entry in _controllers.entries)
          entry.key: entry.value.text.trim(),
      },
      imageFiles: _images,
      fcmToken: user.fcmToken,
      address: user.address,
      authorName: _sendAnonymously
          ? 'Anonymous'
          : (_allowContact ? user.name : ''),
      content: content,
      profileurl: _sendAnonymously ? '' : (_allowContact ? user.photoUrl : ''),
      postId: postId,
      phoneNumber: _sendAnonymously ? '' : user.phoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocListener<PostFormCubit, PostFormState>(
        listener: (context, state) {
          if (state is PostFormSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post submitted successfully!')),
            );
          } else if (state is PostFormError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentStep == 1) ...[
                    ...widget.fields.map((field) {
                      if (field.isImage) {
                        final pickedImage = _images[field.label];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.label + (field.isRequired ? ' *' : ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickImage(field.label),
                                child: pickedImage == null
                                    ? Container(
                                        height: 150,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).appBarTheme.backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .inputDecorationTheme
                                                .enabledBorder!
                                                .borderSide
                                                .color,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(pickedImage.path),
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.black54,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                onPressed: () =>
                                                    _removeImage(field.label),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _controllers[field.label],
                            keyboardType: field.inputType,
                            maxLines: field.isMultiline ? null : 1,
                            decoration: InputDecoration(
                              labelText:
                                  field.label + (field.isRequired ? ' *' : ''),
                              hintText: field.hint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (field.isRequired &&
                                  (value == null || value.trim().isEmpty)) {
                                return '${field.label} is required';
                              }
                              return null;
                            },
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final missingImages = widget.fields.where(
                            (field) =>
                                field.isImage &&
                                field.isRequired &&
                                (_images[field.label] == null),
                          );

                          final isFormValid =
                              _formKey.currentState?.validate() ?? false;

                          if (!isFormValid) return;

                          if (missingImages.isNotEmpty) {
                            final missingLabels = missingImages
                                .map((e) => e.label)
                                .join(', ');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please upload required image(s): $missingLabels',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; // Prevent moving to next step
                          }

                          // ✅ Everything is valid
                          setState(() {
                            _currentStep = 2;
                          });
                        },

                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Submit As",
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 16),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person_outline),
                            title: const Text("Allow personal contact"),
                            trailing: Switch(
                              value: _allowContact,
                              onChanged: (val) {
                                setState(() {
                                  _allowContact = val;
                                  if (!val && !_sendAnonymously) {
                                    // Optional logic
                                  }
                                });
                              },
                            ),
                          ),
                          const Divider(height: 0),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: const Text("Send anonymously"),
                            trailing: Switch(
                              value: _sendAnonymously,
                              onChanged: (val) {
                                setState(() {
                                  _sendAnonymously = val;
                                  if (val) _allowContact = false;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (!_sendAnonymously) ...[
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_circle_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text("Name: $userName"),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text("Phone: $userPhone"),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),

                    BlocBuilder<PostFormCubit, PostFormState>(
                      builder: (context, state) {
                        final isLoading = state is PostFormSubmitting;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _submit(widget.title),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading ? Colors.grey : null,
                            ),
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Submitting...'),
                                    ],
                                  )
                                : const Text('Submit'),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

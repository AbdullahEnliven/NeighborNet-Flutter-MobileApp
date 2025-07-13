import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighbornet/features/post/presentation/cubit/post_form_cubit.dart';
import 'package:neighbornet/features/post/presentation/widgets/post_image_picker.dart';
import 'package:neighbornet/features/post/presentation/widgets/post_submit_button.dart';
import 'package:neighbornet/features/post/presentation/widgets/post_text_field.dart';
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

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var field in widget.fields)
        if (!field.isImage) field.label: TextEditingController(),
    };
    for (var field in widget.fields) {
      if (field.isImage) _images[field.label] = null;
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
      setState(() => _images[label] = image);
    }
  }

  void _removeImage(String label) {
    setState(() => _images[label] = null);
  }

  void _submit(String content) {
    if (_formKey.currentState!.validate()) {
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
        authorName: user.name,
        content: content,
        profileurl: user.photoUrl,
        postId: postId,
        phoneNumber: user.phoneNumber ?? '',
      );
    }
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
                children: [
                  const SizedBox(height: 20),
                  ...widget.fields.map((field) {
                    return field.isImage
                        ? PostImagePicker(
                            label: field.label,
                            isRequired: field.isRequired,
                            image: _images[field.label],
                            onPick: () => _pickImage(field.label),
                            onRemove: () => _removeImage(field.label),
                          )
                        : PostTextField(
                            controller: _controllers[field.label]!,
                            field: field,
                          );
                  }),
                  const SizedBox(height: 20),
                  PostSubmitButton(
                    title: widget.title,
                    isLoading:
                        context.watch<PostFormCubit>().state
                            is PostFormSubmitting,
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

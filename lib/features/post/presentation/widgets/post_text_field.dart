import 'package:flutter/material.dart';
import 'package:neighbornet/features/post/presentation/pages/post_details.dart';



class PostTextField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldData field;

  const PostTextField({
    super.key,
    required this.controller,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: field.inputType,
        maxLines: field.isMultiline ? null : 1,
        decoration: InputDecoration(
          labelText: field.label + (field.isRequired ? ' *' : ''),
          hintText: field.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (field.isRequired && (value == null || value.trim().isEmpty)) {
            return '${field.label} is required';
          }
          return null;
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PostSubmitButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final void Function(String) onSubmit;

  const PostSubmitButton({
    super.key,
    required this.title,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => onSubmit(title),
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
  }
}

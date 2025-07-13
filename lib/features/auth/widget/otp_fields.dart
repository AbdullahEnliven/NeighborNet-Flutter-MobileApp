import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends StatefulWidget {
  final Function(String) onCompleted;

  const OtpField({super.key, required this.onCompleted});

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> with TickerProviderStateMixin {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  late List<AnimationController> _animations;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _animations = List.generate(
      6,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.8,
        upperBound: 1.0,
      ),
    );

    _scales = _animations.map((ctrl) => CurvedAnimation(parent: ctrl, curve: Curves.easeOut)).toList();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var animation in _animations) {
      animation.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Trigger animation
      _animations[index].forward(from: 0.8);

      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    // Move back on delete
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all filled
    String code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return ScaleTransition(
          scale: _scales[index],
          child: SizedBox(
            width: 45,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
               // fillColor: Colors.grey.shade200,
                //border: OutlineInputBorder(
                //  borderRadius: BorderRadius.circular(8),
               // ),
              ),
              onChanged: (value) => _onOtpChanged(index, value),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        );
      }),
    );
  }
}

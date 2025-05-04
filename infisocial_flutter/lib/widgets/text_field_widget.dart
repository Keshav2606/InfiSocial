import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        label: Text(widget.labelText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

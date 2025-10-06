import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  
  const MyTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      // enableInteractiveSelection: true, // Ensure this is true
      obscureText: obscureText,
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText?.isEmpty == true ? hintText : labelText,
        suffixIcon: suffixIcon,
        // labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}

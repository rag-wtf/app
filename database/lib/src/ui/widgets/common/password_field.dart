import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    super.key,
    this.labelText,
    this.errorText,
    this.hintText = '',
    this.prefixIcon,
    this.isDense,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? errorText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool? isDense;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        isDense: widget.isDense,
        label: widget.labelText != null
            ? Text(
                widget.labelText!,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
        prefixIcon: widget.prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
      obscureText: _obscureText,
    );
  }
}

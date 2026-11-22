import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

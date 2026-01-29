import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNumberField extends StatelessWidget {
  final String label;
  final String? suffix;
  final int? initialValue;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final IconData? icon;
  final bool readOnly;
  final bool isRequired;
  
  const CustomNumberField({
    super.key,
    required this.label,
    this.suffix,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.controller,
    this.icon,
    this.readOnly = false,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        initialValue: controller == null ? initialValue?.toString() : null,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          suffixText: suffix,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade200 : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

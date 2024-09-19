import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({super.key, 
    required this.controller,
    required this.labelText,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.characters,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}

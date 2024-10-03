import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final DateTime firstDate;
  final DateTime lastDate;

  DatePickerWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    DateTime? firstDate,
    DateTime? lastDate,
  })  : firstDate = firstDate ?? DateTime(2020),
        lastDate = lastDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: validator,
      readOnly: true,
      onTap: () async {
        // Remove focus from the text field
        FocusScope.of(context).requestFocus(FocusNode());

        // Parse the initial date from the controller or use DateTime.now()
        DateTime initialDate = DateTime.now();
        if (controller.text.isNotEmpty) {
          try {
            initialDate = DateFormat('dd.MM.yyyy').parse(controller.text);
          } catch (e) {
            // If parsing fails, default to DateTime.now()
          }
        }

        // Show the date picker
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: Localizations.localeOf(context),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
          controller.text = formattedDate;
        }
      },
    );
  }
}

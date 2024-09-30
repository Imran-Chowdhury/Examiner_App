import 'package:flutter/material.dart';

Widget customDropDown({
  required List<String> itemList,
  required String hintText,
  required String? value,
  required  String? Function(String?) validator,
  required void Function(String?)? onChanged,
  required double height,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    icon: const Icon(Icons.arrow_drop_down),
    decoration: InputDecoration(
      // labelText: labelText,
      hintText: hintText,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFF0cdec1),
          // Colors.blue,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(height * 0.023),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(height * 0.023),
      ),
    ),

    items: itemList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: onChanged,
    validator: validator,
        // (value) => value == null ? 'Please select your $hintText' : null,
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Widget customTextFormField({
  required String hintText,
  required void Function(String) onChanged,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
  TextEditingController? controller,
  bool enabled = true,
  required double height,
  Icon? filterIcon, // Optional arrow icon
  VoidCallback? onArrowPressed, // Optional function to execute on pressing the arrow

}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    decoration: InputDecoration(
      hintText: hintText,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFF0cdec1),
          width: 2.0,
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
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(height * 0.023),
      ),
      suffixIcon: filterIcon != null
          ? IconButton(
        enableFeedback: true,
        icon: filterIcon,
        onPressed: (){
          // FocusScope.of(context!).unfocus();

          onArrowPressed;
        },
      )
          : null, // Show arrow icon only if provided
    ),
    keyboardType: keyboardType,
    onChanged: onChanged,
    validator: validator,
  );
}

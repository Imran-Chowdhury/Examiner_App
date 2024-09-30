


import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.screenHeight,
    required this.buttonName,
    // required this.color,
    required this.onpressed,
    required this.icon,
  });

  final double screenHeight;
  final String buttonName;
  // final Color color;
  Icon icon;
  final void Function()?  onpressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Matches the width of the TextFormField
      height: screenHeight * 0.07, // Match this value with the TextFormField's height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // backgroundColor: const Color(0XFFfc85ae),
          backgroundColor: const Color(0xFFB37BA4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.023), // Same as TextFormField
          ),
        ),
        onPressed: onpressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            icon,
            SizedBox(width: screenHeight*0.01,),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                buttonName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );

  }
}

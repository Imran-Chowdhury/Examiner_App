import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  CustomFab({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  VoidCallback onPressed;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, bottom: 50),
      child: SizedBox(
        width: 80.0,
        height: 80.0,
        child: FloatingActionButton(
          onPressed: onPressed,
          elevation: 10.0,
          backgroundColor: const Color(0xFFB37BA4),
          shape: const CircleBorder(),
          child:   Icon(icon, size: 40.0,color: Colors.white,),
        ),
      ),
    );
  }
}
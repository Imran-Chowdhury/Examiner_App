
import 'package:flutter/material.dart';

Widget studentCard(String name, String roll, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20), // Padding on the sides only
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFB37BA4), size: 40), // Icon for present student
            const SizedBox(width: 16), // Space between icon and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  roll,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Spacer(), // Pushes the more_vert icon to the right
            GestureDetector(
              onTap: onPressed,
                child: const Icon(Icons.more_vert, color: Colors.black)), // Icon on the right-hand side
          ],
        ),
        const SizedBox(height: 8), // Space between the roll and divider
        const Divider(
          color: Colors.black, // Black line as a divider
          thickness: 1, // Line thickness
        ),
      ],
    ),
  );
}

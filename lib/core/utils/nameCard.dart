import 'package:flutter/material.dart';



class NameCard extends StatelessWidget {
  final String name;
  final String? details;
  final color;
  IconData icon;

 NameCard({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Padding on the sides only
      child: Column(
        children: [
          Row(
            children: [
             Icon(icon, color:color, size: 40), // Icon for present student
              const SizedBox(width: 16), // Space between icon and text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if(details!=null)
                    Text(
                      details!,
                      style: const TextStyle(fontSize: 14),
                    ),

                ],
              ),
              const Spacer(), // Pushes the more_vert icon to the right
              const Icon(
                Icons.arrow_forward_ios, // Arrow icon
                size: 24.0, // Size of the icon
                color: Colors.black, // Color of the icon
              ),
              // GestureDetector(
              //     onTap: onPressed,
              //     child: const Icon(Icons.more_vert, color: Colors.black)), // Icon on the right-hand side
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



    //   SizedBox(
    //   width: double.infinity, // Full width
    //   height: 120.0, // Fixed height
    //   child: Card(
    //     color: color,
    //     elevation: 6.0, // Adds shadow to the card
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(12.0), // Rounded corners
    //     ),
    //     margin: const EdgeInsets.all(16.0),
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding inside the card
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between name and arrow
    //         crossAxisAlignment: CrossAxisAlignment.center, // Vertically align the content
    //         children: [
    //           // Name text on the left
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 name,
    //                 style: const TextStyle(
    //                   fontSize: 26, // Larger font size for the name
    //                   fontWeight: FontWeight.bold, // Bold for emphasis
    //                 ),
    //               ),
    //               if(room!=null)
    //                 Text(
    //                   room!,
    //                   style: const TextStyle(
    //                     color: Colors.black,
    //                     fontSize: 15, // Larger font size for the name
    //                     fontWeight: FontWeight.bold, // Bold for emphasis
    //                   ),
    //                 ),
    //             ],
    //           ),
    //
    //           // Forward arrow on the right
    //           const Icon(
    //             Icons.arrow_forward_ios, // Arrow icon
    //             size: 24.0, // Size of the icon
    //             color: Colors.black, // Color of the icon
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

Widget customCard(String name, String roll, VoidCallback onPressed) {
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


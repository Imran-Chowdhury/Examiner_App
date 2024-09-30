
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class SemesterButton extends StatelessWidget {
  final String semesterName;
  // final Icon icon;
  final color;
  final VoidCallback goToCourse;

  const SemesterButton(
      {super.key,
      required this.semesterName,
        // required this.icon,
        required this.color,
      required this.goToCourse});

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: goToCourse,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        elevation: 8,
        color: color,
        child: Container(
          width: (0.45 * screenWidth),
          height: (0.18 * screenHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: color,
          ),
          child: Center(
            // Centers the column horizontally and vertically
            child: Column(
              mainAxisSize: MainAxisSize.min, // Centers vertically within the Column
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth*0.01),
                  child: const Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8), // Add space between icon and text
                Text(
                  semesterName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// class CustomButton extends StatelessWidget {
//   CustomButton({
//     super.key,
//     required this.screenHeight,
//     required this.buttonName,
//     // required this.color,
//     required this.onpressed,
//     required this.icon,
//   });
//
//   final double screenHeight;
//   final String buttonName;
//   // final Color color;
//   Icon icon;
//   final void Function()?  onpressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity, // Matches the width of the TextFormField
//       height: screenHeight * 0.07, // Match this value with the TextFormField's height
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           // backgroundColor: const Color(0XFFfc85ae),
//           backgroundColor: const Color(0xFFB37BA4),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(screenHeight * 0.023), // Same as TextFormField
//           ),
//         ),
//         onPressed: onpressed,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             icon,
//             SizedBox(width: screenHeight*0.01,),
//             Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: Text(
//                 buttonName,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//
//
//   }
// }
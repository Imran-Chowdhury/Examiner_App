import 'package:flutter/material.dart';

import '../constants/constants.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1e2a78),
        // gradient: LinearGradient(colors: [
        //   ColorConst.backgroundColor,
        //   Color.fromARGB(92, 95, 167, 231),
        // ]),
      ),
    );
  }
}

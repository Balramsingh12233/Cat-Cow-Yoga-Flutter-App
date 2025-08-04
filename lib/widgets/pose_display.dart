import 'package:flutter/material.dart';

class PoseDisplay extends StatelessWidget {
  final String imageName;
  final String text;

  const PoseDisplay({required this.imageName, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/$imageName'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

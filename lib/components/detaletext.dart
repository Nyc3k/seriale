import 'package:flutter/material.dart';

class DetaleText extends StatelessWidget {
  final String widgetText;
  final double? size;
  const DetaleText({super.key, this.size , required this.widgetText});

  @override
  Widget build(BuildContext context) {
    return Text(widgetText, style: TextStyle( fontSize: size, color: const Color.fromARGB(255, 158, 158, 184)));
  }
}
import 'package:flutter/material.dart';

class TableText extends StatelessWidget {
  final String textWTabeli ;
  const TableText({super.key, required this.textWTabeli});

  @override
  Widget build(BuildContext context) {
    return Text(textWTabeli, style: const TextStyle(
      color: Colors.white,
      fontSize: 15
    ),);
  }
}
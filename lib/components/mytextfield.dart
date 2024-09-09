import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  final String label;
  final TextEditingController  controller;
  final TextInputType type;
  const Mytextfield({super.key, required this.controller, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        style: const TextStyle(
          color: Colors.white
        ),
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(
          color: Colors.white
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 41, 41, 56),
        border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(30.0)
        )),
      ),
    );
  }
}
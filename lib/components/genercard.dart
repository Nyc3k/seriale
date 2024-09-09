import 'package:flutter/material.dart';

class GenerCard extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  const GenerCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.only( top: 8.0, bottom: 8.0, left: 12.0, right: 12.0,),
        decoration: BoxDecoration(
          
          borderRadius: BorderRadiusDirectional.circular(30),
          color: Theme.of(context).primaryColor.withOpacity(0.35),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        
      ),
      
    );
  }
}
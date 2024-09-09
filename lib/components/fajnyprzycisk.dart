import 'package:flutter/material.dart';

class ButtonMy extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  //GlobalKey<FormState> _formKey

  const ButtonMy({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return 
    SizedBox(
      width: screenWidth*0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.45),
          //color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          // border: Border.all(
          //   color: Theme.of(context).primaryColor,
          //   width: 2,
          // ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            overlayColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Text(text, style: const TextStyle( color: Colors.white),),
        ),
      ),
    );



  }
}

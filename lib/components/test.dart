import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/serial.dart';

class testowy extends StatelessWidget {

  const testowy({super.key, required this.lista});

  final  List<Serial> lista; 

  
  @override
  Widget build(BuildContext context) {
    

    return Container(
      child: ButtonMy(text: 'KLIKAJ', onPressed: (){
        for (var element in lista) {
          print('${element.firebaseId}');
          if (element.wachedNewSessonAt != null) {
            print('Tu coś nie tak ${element.firebaseId}');
          } else {
            FirebaseFirestore.instance.collection('seriale').doc(element.firebaseId).update({
              'wachedAt' : [Timestamp.now()],
              'updatedAt' : Timestamp.now(),
          });

          }
          
        }
      }),
    );
  }
}
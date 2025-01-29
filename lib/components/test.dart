import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/serial.dart';

class testowy extends StatelessWidget {

  const testowy({super.key,});


  
  @override
  Widget build(BuildContext context) {
    List<String> emotes = ['dislike', 'yyyh', 'likeminus', 'like', 'likeplus', 'heartminus', 'heart'];

    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          IconButton(
            icon: Image.asset('assets/emote/${emotes[index]}.png',
              height: 40,
              width: 40,),
            onPressed: () {
              print(emotes[index]);
            },
          );
        }
      ),
    );
  }
}
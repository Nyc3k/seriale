import 'package:flutter/material.dart';

class Globals {
  static ValueNotifier<int> mode = ValueNotifier<int>(0);

  static void changeMode (){
    if (mode.value == 0 ) {
      mode.value++;
    }else if(mode.value == 1){
      mode.value = 0;
    }
  }
}


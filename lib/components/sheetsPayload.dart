import 'dart:ffi';

import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/serial_provider.dart';

class SheetsPayload {
  final String sheetName;
  final List<Serial> dataList;

  SheetsPayload({required this.sheetName, required this.dataList});

  // Metoda toJson dla całego pakietu danych
  Map<String, dynamic> toJson(SerialProvider serial_provider) {
    return {
      // 1. Nazwa arkusza (string)
      'sheetName': sheetName,
      // 2. Lista danych (lista map)
      'dataList': dataList.map((item) => item.toJson(int.parse(sheetName), serial_provider )).toList(), 
    };
  }
}
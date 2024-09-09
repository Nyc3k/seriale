import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/serial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart';

class RaportMaker extends StatefulWidget {
  final List<Serial> series;
  const RaportMaker({super.key, required this.series});

  @override
  State<RaportMaker> createState() => _RaportMakerState();
}



class _RaportMakerState extends State<RaportMaker> {

  int? _selectedOption;

  Future<void> createExcel(int rok) async {
    // Sprawdzanie i proszenie o uprawnienia do zapisu na urządzeniu
    if (await Permission.storage.request().isGranted) {

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Arkusz1'];
      List<Serial> filteredList = widget.series.where((obj) {
          return obj.wachedAt != null && obj.wachedAt!.any((timestamp) {
            return timestamp.toDate().year == rok;
           });
        }).toList();
      sheetObject.appendRow(["Title", 'Platforms', 'Emote', 'Genre', 'Rating', 'WachedAt' ,'FirebaseId']);
      // Dodawanie danych do arkusza
      for (var element in filteredList) {
        sheetObject.appendRow([element.title, element.platforms,
          element.emote,
          element.apiGenre,
          element.rating,
          for(var timestamp in element.wachedAt!) DateFormat('dd MMMM yyyy').format(timestamp.toDate()).toString(),
          element.firebaseId]);
  
      }
      // Pobranie lokalizacji do zapisania pliku
      final directory = await getStoragePath();
      final path = '${directory!}/raport$rok.xlsx';

      // Zapisanie pliku Excel
      final fileBytes = excel.save();
      final file = File(path);
      await file.writeAsBytes(fileBytes!);

      print("Plik Excel zapisany: $path");
    }
  }

  Future<String?> getStoragePath() async {
  if (Platform.isAndroid) {
    // Android: używamy zewnętrznego magazynu
    return (await getExternalStorageDirectory())?.path;
  } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    // iOS, MacOS, Windows, Linux: używamy wewnętrznego katalogu dokumentów
    return (await getApplicationDocumentsDirectory()).path;
  } else {
    return null; // Dla innych platform, nie obsługujemy
  }
}

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // Pobiera bieżącą datę i czas
    int numberOfOpctions = now.year - 2023; // Pobiera bieżący rok

    List<DropdownMenuItem<int>> options = [];
    for (var i = 0; i < numberOfOpctions; i++) {
      options.add(DropdownMenuItem<int>(
        value: 2024+i,
        child: Text('${2024+i}'),
      )); 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stwórz Raport'),
        ),
        body: Container(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          
          children: [
            Container(
              height: 100,
              child: DropdownButtonFormField<int>(
                items: options,
                onChanged: (value) => setState(() {
                            _selectedOption = value!;
                          }),
              ),
            ),
            ButtonMy(
              text: 'Utwórz Raport',
              onPressed: () => createExcel(_selectedOption!),
            )
          ],
        ),
        ),
    ),
    );
    
  }
}
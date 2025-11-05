
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kajecik/apikey.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/serial_provider.dart';
import 'package:kajecik/components/sheetsPayload.dart';
import 'package:provider/provider.dart';

class RaportMaker extends StatefulWidget {
  final List<Serial> series;
  const RaportMaker({super.key, required this.series});
  

  @override
  State<RaportMaker> createState() => _RaportMakerState();
}



class _RaportMakerState extends State<RaportMaker> {
  
  int _selectedOption = DateTime.now().year;

  Future<void> wyslijDoGoogleSheets(int nazwaArkusza, List<Serial> listaStruktur, SerialProvider serial_provider) async {
  final String urlSkryptu = ApiKey().GSlink;
  List<Serial> seriesToSend = listaStruktur.where((el) {
    return el.wachedAt!.any((date){
      return date.toDate().year == nazwaArkusza;
    });
  }).toList();
  print(nazwaArkusza.toString());
  print(seriesToSend);
  // Stwórz obiekt payload
  final payload = SheetsPayload(
    sheetName: nazwaArkusza.toString(),
    dataList: seriesToSend,
  );
  
  try {
    String jsonBody = jsonEncode(payload.toJson(serial_provider)); // Enkodowanie obiektu SheetsPayload

// print(jsonBody);
    final response = await http.post(
      Uri.parse(urlSkryptu),
      headers: {"Content-Type": "application/json"},
      body: jsonBody,
    );
    print(response.statusCode);
    // var responseBody = jsonDecode(response.body);
    // print(responseBody);
    if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          print("Sukces! Dane wysłane do arkusza: ${nazwaArkusza}");
          
        }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukces'),
          content: const Text('Udało się dodać do Google Sheets'),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    
  } catch (e) {
    print("Wystąpił wyjątek: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    
    DateTime now = DateTime.now(); // Pobiera bieżącą datę i czas
    int numberOfOpctions = now.year - 2023; // Pobiera bieżący rok
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);

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
              onPressed: () => wyslijDoGoogleSheets(_selectedOption!, serialProvider.serialList, serialProvider),
            )
          ],
        ),
        ),
    ),
    );
    
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/serial.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../components/serial_provider.dart';

class RankingUpdate extends StatefulWidget {
  final Serial serial;
  final List<Serial> series;
  final List<String> allTags;

  const RankingUpdate({ 
    required this.serial,
    required this.allTags,
    required this.series,
    super.key});

  @override
  State<RankingUpdate> createState() => _RankingUpdateState();
}

class _RankingUpdateState extends State<RankingUpdate> {
  double rating = 0.0;
  String emote = '';
  double backupRating = 0.0;
  String backupEmote = '';
  late List filterTags = widget.serial.apiGenre!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late List<Serial> filteredList = widget.series;
  List<String> emotes = ['dislike', 'yyyh', 'likeminus', 'like', 'likeplus', 'heartminus', 'heart'];


  @override
  void initState() {
    super.initState();
    rating = widget.serial.rating!;
    emote = widget.serial.emote!;
    backupRating = widget.serial.rating!;
    backupEmote = widget.serial.emote!;
  }

  void refresRating(){
    setState(() {
      widget.serial.rating = rating;
      widget.serial.emote = emote;
      filteredList.sort((a,b) => b.rating!.compareTo(a.rating!));

    });
  }

  void restartAndGoBack() {
    widget.serial.rating = backupRating;
    widget.serial.emote = backupEmote;
    filteredList.sort((a,b) => b.rating!.compareTo(a.rating!));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    List<Serial> filteredList = filterTags.isEmpty
        ? widget.series
        : widget.series.where((series) => series.apiGenre!.any((tag) => filterTags.contains(tag))).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: restartAndGoBack,
        ),
        title: const Text('Zaktualizuj Ocena Serialu', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        )),
        backgroundColor: const Color.fromARGB(255, 18, 18, 23),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 30.0, right: 30.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5.0),
              Text( widget.serial.title , style: const TextStyle(fontSize: 25)),
              const SizedBox(height: 16.0),             
              Form(
                child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 6,
                              child: SizedBox(
                                width: (MediaQuery.of(context).size.width)*0.7,
                                child: TextFormField(
                                  onChanged: (value) {
                                    rating = double.parse(value);
                                    setState(() {
                                      try {
                                        rating = double.parse(value);                                        
                                      } catch (e) {
                                        emote = 'Błędna wartość';
                                      }
                                      });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Ocena od 1 do 10', 
                                    labelStyle: const TextStyle(
                                      color: Colors.white
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 41, 41, 56),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0)
                                  )),
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                                initialValue: rating.toString(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Expanded(
                              flex: 3,
                              child: emote.isNotEmpty 
                                ? Image.asset('assets/emote/$emote.png',
                                  height: 50,
                                  width: 50,
                                  //scale: 10,
                                ) : const Text('')
                            ),
                            
                          ],
                        ),
                        
                      ),
                      
                      const Text('Wybierz emotkę określającą ten serial:'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                        itemCount: emotes.length,
                        itemBuilder: (context, index) {
                          return IconButton(
                            iconSize: 50, // Ustaw rozmiar ikony
                            padding: EdgeInsets.all(8),
                            icon: Image.asset(
                              'assets/emote/${emotes[index]}.png',
                              height: 40,
                              width: 40,
                            ),
                            onPressed: () {
                              setState(() {
                                emote = emotes[index];
                              });
                            },
                          );
                        },
                      ),
               const SizedBox( height: 16,),
               ButtonMy(text: "Aktualizuj", onPressed: () async {
                firestore.collection('seriale').doc(widget.serial.firebaseId).update({
                  'emote' : emote,
                  'rating' : rating,
                  'updatedAt' : Timestamp.now(),
                });
                Navigator.of(context).pop();
    
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sukces'),
                      content: const Text('Serial został zaktalizowany'),
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
              }),
            ]
          ),
        ),
      ]),)
    ));
  }
}
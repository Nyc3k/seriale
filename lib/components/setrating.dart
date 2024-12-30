import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/multichooser.dart';
import 'package:provider/provider.dart';
import '../components/serial.dart';
import '../components/serial_provider.dart';
import '../components/tableText.dart';

class SetRanking extends StatefulWidget {
  final FirebaseFirestore firestore;
  final bool isWatched;
  final bool isNew;
  final bool newSesson;
  final Serial newSerial;
  final List<Serial> series;
  final List<String> allTags;
  final bool addSesson;

  const SetRanking({ 
    required this.newSerial,
    required this.isWatched,
    // required this.title,
     required this.allTags,
    // required this.platforms,
    required this.series,
    required this.firestore,
    required this.isNew,
    required this.newSesson,
    required this.addSesson,
    // this.sesons,
    // this.notes,
    super.key});

  @override
  State<SetRanking> createState() => _addAPIandRankingState();
}

class _addAPIandRankingState extends State<SetRanking> {
  double rating = 0.0;
  String emote = '';
  late List filterTags = widget.newSerial.apiGenre!;
  bool _isLoading = false;
  double _sliderValue = 1.0;
  double sliderMax = 1;
  int selectedIndex = 0;
  List<String> emotes = ['dislike', 'yyyh', 'likeminus', 'like', 'likeplus', 'heartminus', 'heart'];


  @override
  void initState() {
    super.initState();
    if (widget.addSesson) {
      sliderMax = widget.newSerial.sesons! + 1;
    } else {
      sliderMax = widget.newSerial.sesons!.toDouble();
    }
    if (widget.newSesson && widget.isWatched) {
      rating = widget.newSerial.rating!;
      emote = widget.newSerial.emote!;
      _sliderValue = widget.newSerial.watchedSessons!.toDouble();
    } else{
      _sliderValue = 1.0;
    }
    
  }

  void buttonAction(SerialProvider serialProvider) async {
    
    setState(() {
      _isLoading = true;
    });
    String dialogText;
    bool sessontowatch;
    _sliderValue == widget.newSerial.sesons ? sessontowatch = false: sessontowatch = true;
    if (widget.isNew) {
      dialogText = 'Serial został dodany';
      widget.firestore.collection('seriale').add({
              'isWatched' : widget.isWatched,
              'apiId' : widget.newSerial.apiId,
              'title' : widget.newSerial.title,
              'tags' : widget.newSerial.tags,
              'platforms' : widget.newSerial.platforms,
              'emote' : emote,
              'imageUrl' : widget.newSerial.imageUrl,
              'imageUrl2' : widget.newSerial.imageUrl2,
              'rating' : rating,
              'sesons' : widget.newSerial.sesons,
              'notes' : widget.newSerial.notes,
              'trailerUrl' : widget.newSerial.trailerUrl,
              'wachedAt' : [Timestamp.now()],
              'createdAt' : Timestamp.now(),
              'updatedAt' : Timestamp.now(),
              'releaseYear' : widget.newSerial.releaseYear,
              'endYear' : widget.newSerial.endYear,
              'plotOverview' : widget.newSerial.plotOverview,
              'imdbId' : widget.newSerial.imdbId,
              'userRating' : widget.newSerial.userRating,
              'criticScore' : widget.newSerial.criticScore,
              'apiGenre' : widget.newSerial.apiGenre,
              'watchedSessons' : _sliderValue,
              'newSesson' : sessontowatch,
              'prority': 2
            }).then((value) {
              serialProvider.orderList.insert( selectedIndex ,value.id);
              widget.firestore.collection('kolejnosc').doc('serialeObejrzane').update({
                'documentIds' : serialProvider.orderList,
              }).then( (_) async =>
              await serialProvider.fetchSerials()
            );
            });
    }else{
      dialogText = 'Serial został zaktalizowany';
      if (widget.newSerial.wachedAt == null) {
        widget.newSerial.wachedAt = [Timestamp.now()];
      } else {
        widget.newSerial.wachedAt!.add(Timestamp.now());
      }
      
      if (!widget.newSesson) {
        widget.firestore.collection('seriale').doc(widget.newSerial.firebaseId).update({
          'newSesson' : sessontowatch,
          'isWatched' : true,
          'watchedSessons' : _sliderValue,
          'emote' : emote,
          'rating' : rating,
          'wachedAt' : widget.newSerial.wachedAt,
          'updatedAt' : Timestamp.now(),
      }).then( (_) async =>
        await serialProvider.fetchSerials()
      );
      }  else {
        widget.firestore.collection('seriale').doc(widget.newSerial.firebaseId).update({
        'newSesson' : false,
        'sesons': sliderMax,
        'watchedSessons' : _sliderValue,
        'emote' : emote,
        'rating' : rating,
        'wachedNewSessonAt' : widget.newSerial.wachedAt,
        'updatedAt' : Timestamp.now(),
      }).then( (_) async =>
        await serialProvider.fetchSerials()
      );
      }
    }
    Navigator.popUntil(context, (route) {
      if (route.isFirst) {
        return true;
      }
      return false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukces'),
          content: Text(dialogText),
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {


    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    List<Serial> filteredList = filterTags.isEmpty
        ? serialProvider.watchedSeries
        : serialProvider.watchedSeries.where((series) => series.apiGenre!.any((tag) => filterTags.contains(tag))).toList();


        print(filteredList);
    return _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 25, 145, 14)))
          : Scaffold(
      appBar: AppBar(
        title: const Text('Ustaw Ocena Serialu', style: TextStyle(
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
              //const SizedBox(height: 25.0),
              Text( widget.newSerial.title , style: const TextStyle(fontSize: 25),),
              const SizedBox(height: 8.0),
              Text('Wybierz emotkę określającą ten serial:'),
              Form(
                child: Column(
                    children: [
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
                      Column(
                        children: [
                          TableText( textWTabeli: 'Liczba obejrzanych sezonów: ${_sliderValue.toInt()}'),
                          widget.newSerial.sesons! > 1 ? 
                          Slider(
                            activeColor: Theme.of(context).primaryColor,
                            value: _sliderValue,
                            min: 1,
                            max: sliderMax,
                            divisions: widget.newSerial.sesons,
                            label: _sliderValue.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                            },
                          ) : const Text(''),
                        ]
                      ),
                      if (widget.newSesson) const Text('Czy chcesz zmienić ocenę?'),

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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MultiChooser(
                          allTags: widget.allTags, 
                          title: 'Wybierz tagi',
                          initvalues: widget.newSerial.apiGenre!,
                          myChipDisplay: false,
                          onConfirm: (results) {
                            setState(() {
                              filterTags = results.cast<String>();
                            });
                          },)
                      ),
                      SizedBox(
                        height: 250,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: TableText(textWTabeli: 'Tytuł')),
                                DataColumn(label: TableText(textWTabeli: 'Ocena')),
                                DataColumn(label: TableText(textWTabeli: 'Tagi')),
                                DataColumn(label: TableText(textWTabeli: 'Emote')),
                              ],
                              rows: filteredList.map((item) {
                                return DataRow(
                                  //selected: selectedIndex == item.id,
                                  onSelectChanged: (isSelected) {
                                    setState(() {
                                      selectedIndex = serialProvider.orderList.indexOf(item.firebaseId!);
                                      print('Selected ID: $selectedIndex');
                                    });
                                  },
                                  cells: [
                                  DataCell(TableText(textWTabeli: item.title )),
                                  DataCell(TableText(textWTabeli: item.rating.toString())),
                                  DataCell(TableText(textWTabeli: item.apiGenre!.join(', '))),
                                  DataCell(TableText(textWTabeli: item.emote as String)),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
               const SizedBox( height: 16,),
               ButtonMy(text: "Dodaj", onPressed: () => buttonAction(serialProvider)),
            ]
          ),
        ),
      ]),)
    ));
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/multichooser.dart';
import 'package:kajecik/components/mytextfield.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/tableText.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../components/serial_provider.dart';

class EditSeries extends StatefulWidget {
  final List<Serial> watchedSeries;
  final List<String>? tags;
  final Serial serial;
  const EditSeries({super.key, required this.serial, required this.watchedSeries, this.tags});

  @override
  State<EditSeries> createState() => _EditSeriesState();
}

class _EditSeriesState extends State<EditSeries> {
  final TextEditingController _newOptionController = TextEditingController();
  final TextEditingController _apiIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlPosterController = TextEditingController();
  final TextEditingController _imageUrlDwaController = TextEditingController();
  final TextEditingController _sessonsController = TextEditingController();
  final TextEditingController _trailerController = TextEditingController();
  final TextEditingController _releseYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _plotOverviewController = TextEditingController();
  final TextEditingController _imdbIdController = TextEditingController();
  final TextEditingController _userRatingController = TextEditingController();
  final TextEditingController _criticScoreController = TextEditingController();
  final TextEditingController _watchedSessonsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<String> _multiSelectPlatform = ['Netflix', 'Apple_TV', 'Canal_Plus', 'Disney_Plus','HBO_MAX','TVN_Player','Prime_Video','ShyShowTime','Nie_Wiem',];

  final _firestore = FirebaseFirestore.instance;
  late double rating;  
  String emote = '';
  int sessons = 0;
  late List filterTags = widget.serial.apiGenre!;
  late List seriesTags = widget.serial.apiGenre!;
  late List<String> _selectedPlatforms = widget.serial.platforms;
  late double _sliderValuePrority = 1.0;
  late var serialProvider;

  void _addNewOption() {
    final newOption = _newOptionController.text;
    if (newOption.isNotEmpty) {
      String tagCapitalizeFirstLetter = newOption[0].toUpperCase() + newOption.substring(1);
      
      setState(() {
        widget.serial.apiGenre?.add(tagCapitalizeFirstLetter);
      
        _firestore.collection('seriale').doc(widget.serial.firebaseId).update({
          'apiGenre': widget.serial.apiGenre
        }).then(
            serialProvider.fetchSerials() as FutureOr Function(void value)
          );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _apiIdController.text = widget.serial.apiId?.isEmpty ?? true ? '' : widget.serial.apiId!;
    _titleController.text = widget.serial.title.isEmpty ? '' : widget.serial.title;
    emote = (widget.serial.emote?.isEmpty ?? true ? '' : widget.serial.emote)!;
    _imageUrlPosterController.text = widget.serial.imageUrl?.isEmpty ?? true ? '' : widget.serial.imageUrl!;
    _imageUrlDwaController.text = widget.serial.imageUrl2?.isEmpty ?? true ? '' : widget.serial.imageUrl2!;
    _sessonsController.text = widget.serial.sesons?.toString().isEmpty ?? true ? '' : widget.serial.sesons!.toString();
    _watchedSessonsController.text = widget.serial.watchedSessons?.toString().isEmpty ?? true ? '' : widget.serial.watchedSessons!.toString();
    _notesController.text = widget.serial.notes?.isEmpty ?? true ? '' : widget.serial.notes!;
    _trailerController.text = widget.serial.trailerUrl?.isEmpty ?? true ? '' : widget.serial.trailerUrl!;
    _releseYearController.text = widget.serial.releaseYear?.toString().isEmpty ?? true ? '' : widget.serial.releaseYear!.toString();
    _endYearController.text = widget.serial.endYear?.toString().isEmpty ?? true ? '' : widget.serial.endYear!.toString();
    _plotOverviewController.text = widget.serial.plotOverview?.isEmpty ?? true ? '' : widget.serial.plotOverview!;
    _imdbIdController.text = widget.serial.imdbId?.isEmpty ?? true ? '' : widget.serial.imdbId!;
    _userRatingController.text = widget.serial.userRating?.toString().isEmpty ?? true ? '' : widget.serial.userRating!.toString();
    _criticScoreController.text = widget.serial.criticScore?.toString().isEmpty ?? true ? '' : widget.serial.criticScore!.toString();
    _sliderValuePrority = widget.serial.prority?.toString().isEmpty ?? true ? 0.0 : widget.serial.prority!.toDouble();
    rating = widget.serial.rating!;

  }

  @override
  Widget build(BuildContext context) {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    
    List<Serial> filteredList = filterTags.isEmpty
        ? serialProvider.watchedSeries
        : serialProvider.watchedSeries.where((series) => series.apiGenre!.any((tag) => filterTags.contains(tag))).toList();

    //print ('firebaseId; ${widget.serial.firebaseId} \napiId; ${widget.serial.apiId} \nisWatched; ${widget.serial.isWatched} \ntitle; ${widget.serial.title} \nplatforms; ${widget.serial.platforms} \nemote; ${widget.serial.emote} \nimageUrl; ${widget.serial.imageUrl} \nimageUrl2; ${widget.serial.imageUrl2} \nrating; ${widget.serial.rating} \nsesons; ${widget.serial.sesons} \nnotes; ${widget.serial.notes} \ntrailerUrl; ${widget.serial.trailerUrl} \ncreatedAt; updatedAt; \nreleaseYear; ${widget.serial.releaseYear} \nendYear; ${widget.serial.endYear} \nplotOverview; ${widget.serial.plotOverview} \nimdbId; ${widget.serial.imdbId} \nuserRating; ${widget.serial.userRating} \ncriticScore; ${widget.serial.criticScore} \napiGenre; ${widget.serial.apiGenre} \nwatchedSessons; ${widget.serial.watchedSessons} \nnewSesson; ${widget.serial.newSesson} \nprority; ${widget.serial.prority} ');

    return Scaffold(
      appBar: AppBar( 
        title: Text(widget.serial.title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                Text('Edycja serialu o Id: ${widget.serial.firebaseId}'),
                //Text('Detale ${widget.serial.apiGenre}'),
                Mytextfield(controller: _titleController, label: 'Tytuł', type: TextInputType.name,),                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: MultiChooser(
                          allTags: widget.tags!, 
                          title: 'Tagi',
                          initvalues: widget.serial.apiGenre!,
                          myChipDisplay: false,
                          onConfirm: (results) {
                            setState(() {
                              seriesTags = results.cast<String>();
                            });
                          }),
                      ),
                      const Expanded( flex: 1, child: SizedBox()),
                      Expanded(
                        flex: 3,
                        child: MultiChooser(
                          initvalues: _selectedPlatforms,
                          allTags: _multiSelectPlatform, 
                          onConfirm: (selectedList) {
                            setState(() {
                              _selectedPlatforms = selectedList.cast<String>();
                            });
                          }, 
                          title: "Platforma", 
                          myChipDisplay: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white
                          ),
                          controller: _newOptionController,
                          decoration: InputDecoration(
                          labelText: 'Dodaj nowy tag', 
                          labelStyle: const TextStyle(
                            color: Colors.white
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 41, 41, 56),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0)
                          )),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white,),
                        onPressed: _addNewOption,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                  if (rating < 4) {
                                    emote = 'dislike';
                                  }  else if (rating >= 4 && rating < 5) {
                                    emote = 'yyyh';
                                  } else if (rating >= 5 && rating < 5.5) {
                                    emote = 'likeminus';
                                  } else if (rating >= 5.5 && rating < 7) {
                                    emote = 'like';
                                  } else if (rating >= 7 && rating < 8.5) {
                                    emote = 'likeplus';
                                  } else if (rating >= 8.5 && rating < 9) {
                                    emote = 'heartminus';
                                  } else if (rating >= 9) {
                                    emote = 'heart';
                                  }
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
                          ) : const Text('')
                      ),
                      
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MultiChooser(
                    allTags: widget.tags!, 
                    title: 'Wybierz tagi do wyświetlenia w tabeli',
                    initvalues: widget.serial.apiGenre!,
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
                          return DataRow(cells: [
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
                Mytextfield(controller: _sessonsController, label: 'Ilość sezonów', type: TextInputType.number,),
                Mytextfield(controller: _watchedSessonsController, label: 'Ilość obejrzanych sezonów', type: TextInputType.number,),
                Mytextfield(controller: _releseYearController, label: 'Rok wydania', type: TextInputType.number,),
                Mytextfield(controller: _endYearController, label: 'Rok zakończenia', type: TextInputType.number,),
                Mytextfield(controller: _imdbIdController, label: 'Imdb ID', type: TextInputType.name,),
                Mytextfield(controller: _apiIdController, label: 'API ID', type: TextInputType.name,),
                Column(
                  children: [
                    const Text("Ustaw pritytet"),
                    Slider(
                      activeColor: Theme.of(context).primaryColor,
                      value: _sliderValuePrority,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      label: _sliderValuePrority.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _sliderValuePrority = value;
                        });
                      },
                    ),
                  ],
                ),
                Mytextfield(controller: _imageUrlPosterController, label: 'Plakat', type: TextInputType.name,),
                Mytextfield(controller: _imageUrlDwaController, label: 'Drugi obraz', type: TextInputType.name,),
                Mytextfield(controller: _trailerController, label: 'Trailer url', type: TextInputType.name,),
                Mytextfield(controller: _plotOverviewController, label: 'Zarys fabuły', type: TextInputType.name,),
                Mytextfield(controller: _userRatingController, label: 'Ocena użytkowników', type: TextInputType.number,),
                Mytextfield(controller: _criticScoreController, label: 'Ocena krytyków', type: TextInputType.number,),
                Mytextfield(controller: _notesController, label: 'Notatki', type: TextInputType.name,),
              ],
            ),
          ),
        ),
        Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                  bool tempNewSesson = int.parse(_watchedSessonsController.text) < int.parse(_sessonsController.text);
                  double? tempCriticScore = _criticScoreController.text.isNotEmpty ? double.parse(_criticScoreController.text): null;
                  int? tempEndYear = _endYearController.text.isNotEmpty ? int.parse(_endYearController.text): null;
                  int? tempReleaseYear = _releseYearController.text.isNotEmpty ? int.parse(_releseYearController.text): null;
                  double? tempUserRating = _userRatingController.text.isNotEmpty ? double.parse(_userRatingController.text): null;
                  
                  _firestore.collection('seriale').doc(widget.serial.firebaseId).update({

                    'apiGenre': seriesTags,
                    'apiId': _apiIdController.text,
                    'criticScore': tempCriticScore,
                    'emote': emote,
                    'endYear': tempEndYear,
                    'imageUrl': _imageUrlPosterController.text,
                    'imageUrl2': _imageUrlDwaController.text,
                    'imdbId': _imdbIdController.text,
                    'newSesson': tempNewSesson,
                    'notes': _notesController.text,
                    'platforms': _selectedPlatforms,
                    'plotOverview': _plotOverviewController.text,
                    'prority': _sliderValuePrority,
                    'rating': rating,
                    'releaseYear': tempReleaseYear,
                    'sesons': int.parse(_sessonsController.text),
                    'title': _titleController.text,
                    'trailerUrl': _trailerController.text,
                    'updatedAt': Timestamp.now(),
                    'userRating': tempUserRating,
                    'watchedSessons': int.parse(_watchedSessonsController.text),
                  }).then(
                    serialProvider.fetchSerials() as FutureOr Function(void value)
                  );

                },
                child: const Icon(Icons.upgrade),
              ))
        ]
      ),
    );
    
  }
}
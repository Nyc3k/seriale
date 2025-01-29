import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kajecik/components/api_response.dart';
import 'package:kajecik/components/api_service.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/setrating.dart';
import 'package:provider/provider.dart';
import '../components/serial_provider.dart';
import '../components/serial.dart';
import '../components/tableText.dart';

class AddAPIandRanking extends StatefulWidget {
  final FirebaseFirestore firestore;
  final bool isWatched;
  final bool isNew;
  final bool newSesson;
  final Serial newSerial;
  final List<Serial> series;
  final Function() formClick;
  final List<String> allTags;

  const AddAPIandRanking({ 
    required this.newSerial,
    required this.isWatched,
     required this.allTags,
    required this.series,
    required this.firestore,
    required this.formClick,
    required this.isNew,
    required this.newSesson,
    super.key});

  @override
  State<AddAPIandRanking> createState() => _addAPIandRankingState();
}

class _addAPIandRankingState extends State<AddAPIandRanking> {
  
  final TextEditingController imdbIdController = TextEditingController();
  ApiResponse? _selectedOption;
  final ApiService apiService = ApiService();
  List<ApiResponse> _apiResults = [];
  bool _isLoading = false;
  double _sliderValuePrority = 1.0;
  
  void _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.fetchSearch(widget.newSerial.title);
      setState(() {
        _apiResults = result;
        if (_apiResults.isNotEmpty) {
          _selectedOption = _apiResults[0];
        }
        
      });
    } catch (e) {
      print('_fetchMovies SIĘ WYWALIŁO $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      _fetchMovies();
    }   
  }

  @override
  Widget build(BuildContext context) {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    
    return _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 25, 145, 14)))
          :Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowy serial', style: TextStyle(
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
              const SizedBox(height: 25.0),
              Text( widget.newSerial.title , style: const TextStyle(fontSize: 25),),
              Text('dostępny w ${widget.newSerial.platforms} \n tagi: ${widget.newSerial.apiGenre} ilość sezonów ${widget.newSerial.sesons}'),
              const SizedBox(height: 16.0),
              widget.isNew ? _apiResults.isNotEmpty ? Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TableText(textWTabeli: "Odpowiadający tytuł z API",)
                  ),
                  Padding(
                 padding: const EdgeInsets.all(15.0),
                 child: DropdownButtonFormField<ApiResponse>(
                   isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Wybierz jedną z opcji',
                  ),
                  value: _selectedOption,
                  onChanged: (ApiResponse? newValue) {
                    setState(() {
                      _selectedOption = newValue!;
                    });
                  },
                  items: _apiResults.map<DropdownMenuItem<ApiResponse>>((ApiResponse value) {
                    return DropdownMenuItem<ApiResponse>(
                      value: value,
                      child: Text('${value.title} ${value.year}'),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Please select an option' : null,
                  ),         
               ),

                ],
              ): Column(
                children: [
                  const Text('Niestety APi się wywaliło i musisz podać imdbid powodzenia w znalezieniu go :('),
                  TextFormField(
                    controller: imdbIdController,
                    decoration: InputDecoration(
                      labelText: 'imdb ID', 
                      labelStyle: const TextStyle(
                        color: Colors.white
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 41, 41, 56),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)
                      )),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nie no coś wpisać trzeba';
                      }
                      return null;
                    },
                  ),
                ],
              ) : const SizedBox(),
               !widget.isWatched ? Column(
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
               ): const SizedBox(),
               const SizedBox( height: 16,),
               ButtonMy(text: "Dalej", onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                // if !_apiResults.isNotEmpty do strony do wpisania imdb id 
                if (_apiResults.isEmpty) {
                  
                  Map<String,dynamic> detalisInfo = await apiService.fetchImdbApi(imdbIdController.text,  GraphQLProvider.of(context).value);
                  // print('object: {\napiId: nie ma,\nimageUrl: ${detalisInfo['posters'][0]['url']}, \nimageUrl2: null, \ntrailerUrl: ${detalisInfo['trailer']}, \nreleaseYear: ${detalisInfo['start_year']?.toInt()},\nendYear : ${detalisInfo['end_year']?.toInt()},\nplotOverview : ${detalisInfo['plot']},\nimdbId : ${detalisInfo['id']},\nuserRating : ${detalisInfo['rating']['aggregate_rating']?.toDouble()},\ncriticScore : ${detalisInfo['critic_review']?['score']?.toInt()},\napiGenre : ${detalisInfo['genres']?.cast<String>().toList()},}');
                  widget.newSerial.addApiResult(
                    apiId: 'nie ma',
                    imageUrl: detalisInfo['posters'][0]['url'],
                    imageUrl2: null,
                    trailerUrl: detalisInfo['trailer'],
                    releaseYear: detalisInfo['start_year']?.toInt(),
                    endYear : detalisInfo['end_year']?.toInt(),
                    plotOverview : detalisInfo['plot'],
                    imdbId : detalisInfo['id'],
                    userRating : detalisInfo['rating']['aggregate_rating']?.toDouble(),
                    criticScore : detalisInfo['critic_review']?['score']?.toInt(),
                    apiGenre : detalisInfo['genres']?.cast<String>().toList(),
                  );
                  
                }else {
                  Map<String,dynamic> detalisInfo = await apiService.fetchDetails(_selectedOption?.id.toString());
                  
                  widget.newSerial.addApiResult(
                    apiId: detalisInfo['id'].toString(),
                    imageUrl: detalisInfo['poster'],
                    imageUrl2: detalisInfo['backdrop'],
                    trailerUrl: detalisInfo['trailer'],
                    releaseYear: detalisInfo['year']?.toInt(),
                    endYear : detalisInfo['end_year']?.toInt(),
                    plotOverview : detalisInfo['plot_overview'],
                    imdbId : detalisInfo['imdb_id'],
                    userRating : detalisInfo['user_rating']?.toDouble(),
                    criticScore : detalisInfo['critic_score']?.toInt(),
                    apiGenre : detalisInfo['genre_names']?.cast<String>().toList(),
                  );
                }
  if (widget.isWatched) {
  
    Navigator.push(context, MaterialPageRoute(builder: (context) => SetRanking(
      newSerial: widget.newSerial,
      allTags: widget.allTags,
      isWatched: widget.isWatched,
      isNew: widget.isNew,
      series: widget.series,
      newSesson: false,
      firestore: widget.firestore,
      addSesson: false,
    )));
    
    widget.formClick();
  } else {
    widget.firestore.collection('seriale').add({
            'isWatched' : widget.isWatched,
            'apiId' : widget.newSerial.apiId,
            'title' : widget.newSerial.title,
            'platforms' : widget.newSerial.platforms,
            'emote' : "",
            'imageUrl' : widget.newSerial.imageUrl,
            'imageUrl2' : widget.newSerial.imageUrl2,
            'rating' : 0,
            'sesons' : widget.newSerial.sesons,
            'notes' : widget.newSerial.notes,
            'trailerUrl' : widget.newSerial.trailerUrl,
            'createdAt' : Timestamp.now(),
            'updatedAt' : Timestamp.now(),
            'releaseYear' : widget.newSerial.releaseYear,
            'endYear' : widget.newSerial.endYear,
            'plotOverview' : widget.newSerial.plotOverview,
            'imdbId' : widget.newSerial.imdbId,
            'userRating' : widget.newSerial.userRating,
            'criticScore' : widget.newSerial.criticScore,
            'apiGenre' : widget.newSerial.apiGenre,
            'watchedSessons' : 0,
            'newSesson' : false,
            'prority' : _sliderValuePrority,
            'wachedAt': []
          }).then((_) async {
            await serialProvider.fetchSerials();
          });
          widget.formClick();
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
                content: const Text('Serial został dodany'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          }
                
                setState(() {
                  _isLoading = false;
                });
              }),
            ]
          ),
        ),
      ),
    );
  }
}
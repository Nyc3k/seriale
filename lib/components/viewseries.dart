import 'package:flutter/material.dart';
import 'package:kajecik/components/multichooser.dart';
import 'package:kajecik/components/raport.dart';
import 'package:kajecik/components/serieslist.dart';
import 'package:kajecik/components/filtrcard.dart';
import 'package:kajecik/globals.dart';
import 'serial.dart';

class ViewSeries extends StatefulWidget {
  final List<Serial> series;
  final String appBarTitle;
  final List<String> tags;
  final List<Serial> watchedSeries;
  final bool withNewSessons;


  const ViewSeries({required this.series, super.key, required this.appBarTitle, required this.tags, required this.watchedSeries, required this.withNewSessons});

  @override
  State<ViewSeries> createState() => _ViewSeriesState();
}

class _ViewSeriesState extends State<ViewSeries> {


  late List<Serial> filteredItems;
  late int opcja;
  late String barTitle;
  List<String> choosenFilters = [];
  final List<String> _multiSelectPlatform = ['Netflix', 'Apple_TV', 'Canal_Plus', 'Disney_Plus','HBO_MAX','TVN_Player','Prime_Video','ShyShowTime','Nie_Wiem',];
  String _sortField = 'ranking';

  List<String> choosenTags = [];
  List<String> choosenPlatforms = [];
  String queryTitle = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    opcja = 2;
    barTitle = widget.appBarTitle; 
    filteredItems = widget.series;
  }

void filterItems() {
    setState(() {
      filteredItems = widget.series.where((item) {
        final titleMatch = item.title.toLowerCase().contains(queryTitle.toLowerCase());
        final tagsMatch = choosenTags.isEmpty || item.apiGenre!.any((tag) => choosenTags.contains(tag));
        final platformsMatch = choosenPlatforms.isEmpty || item.platforms.any((platform) => choosenPlatforms.contains(platform));
        return titleMatch && tagsMatch && platformsMatch;
      }).toList();
    });
  }

  void filterItemsTitle(String query) {
    setState(() {
      queryTitle = query;
      filterItems();
    });
  }

  void filterItemsTags(List<dynamic> query) {
    setState(() {
      choosenTags = query.cast<String>();
      filterItems();
    });
  }

  void filterItemsPlatforms(List<dynamic> query) {
    setState(() {
      choosenPlatforms = query.cast<String>();
      filterItems();
    });
  }

  void removeFilterTag(String query) {
    setState(() {
      choosenTags.remove(query);
      filterItems();
    });
  }

  void removeFilterPlatform(String query) {
    setState(() {
      choosenPlatforms.remove(query);
      filterItems();
    });
  }
  void changeOfLook(){
    setState(() {
      Globals.changeMode();
    });
  }
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      filterItemsTitle('');
    });
  }
  void _sortSeries(String query, String type) {
  
    setState(() {
      
      filteredItems.sort((a, b) {
        if (type == 'desc'){
          var temp = a;
          a = b;
          b = temp; 
        }
        if (query == 'rating') {
          if (a.rating == null && b.rating == null) return 0;
          if (a.rating == null) return -1;
          if (b.rating == null) return 1;
          return a.rating!.compareTo(b.rating!);
        } else if (query == 'platform') {
          return a.platforms[0].compareTo(b.platforms[0]);
        } else if (query ==  'title') {
          return a.title.compareTo(b.title);
        } else if (query ==  'critics') {
          if (a.criticScore == null && b.criticScore == null) return 0;
          if (a.criticScore == null) return -1;
          if (b.criticScore == null) return 1;
          return a.criticScore!.compareTo(b.criticScore!);
        } else if (query ==  'users') {
          if (a.userRating == null && b.userRating == null) return 0;
          if (a.userRating == null) return -1;
          if (b.userRating == null) return 1;
          return a.userRating!.compareTo(b.userRating!);
        } else if (query ==  'release') {
          if (a.releaseYear == null && b.releaseYear == null) return 0;
          if (a.releaseYear == null) return -1;
          if (b.releaseYear == null) return 1;
          return a.releaseYear!.compareTo(b.releaseYear!);
        } else if (query ==  'priority') {
          if (a.prority == null && b.prority == null) return 0;
          if (a.prority == null) return -1;
          if (b.prority == null) return 1;
          return a.prority!.compareTo(b.prority!);
        } else {
          return a.title.compareTo(b.title);
        }
      });
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sortuj'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Pole'),
                items: const [
                  DropdownMenuItem(value: 'rating', child: Text('Moja ocena')),
                  DropdownMenuItem(value: 'title', child: Text('Tytuł')),
                  DropdownMenuItem(value: 'platform', child: Text('Platforma')),
                  DropdownMenuItem(value: 'critics', child: Text('Ocena Krytyków')),
                  DropdownMenuItem(value: 'users', child: Text('Ocena Innych')),
                  DropdownMenuItem(value: 'release', child: Text('Rok wydania')),
                  DropdownMenuItem(value: 'priority', child: Text('Piorytet')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortField = value!;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _sortSeries(_sortField, 'asc');
                        Navigator.of(context).pop();
                      },
                      child: const Text('Rosnąco'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _sortSeries(_sortField, 'desc');
                        Navigator.of(context).pop();
                      },
                      child: const Text('Malejąco'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextFormField(
                    cursorColor: Colors.white,
                    onChanged: filterItemsTitle,
                    decoration: const InputDecoration(
                      labelText: 'Wpisz tytuł', 
                      ),
                  )
          : GestureDetector(
            child: Text(
              Globals.mode.toString(),
              //barTitle, 
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )),
            onTap: () => changeOfLook(),
            onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RaportMaker(
              series: widget.watchedSeries,
            ))),
          ),
        actions: _isSearching 
          ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _stopSearch,
                )
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              ],
        backgroundColor: const Color.fromARGB(255, 18, 18, 23),
      ),
      backgroundColor: const Color.fromARGB(255, 18, 18, 23),
      body: Column(
      children: [
        
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( flex: 3, child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: MultiChooser(
                  initvalues: const [],
                  allTags: _multiSelectPlatform,
                  title: 'Platforma',
                  myChipDisplay: false,
                  onConfirm: filterItemsPlatforms ,
                  ),
              )),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.45),
                ),
                onPressed: _showSortDialog,
                child: const Text('Sortuj', style: TextStyle(color: Colors.white),),
              ),
              Expanded( flex: 3, child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: MultiChooser(
                  initvalues: choosenTags,
                  allTags: widget.tags,
                  title: 'Filtry',
                  myChipDisplay: false,
                  onConfirm: filterItemsTags ,
                  ),
              )),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Row(
                  children: choosenTags.map((item) => FiltrCard(title: item, onTap: () => removeFilterTag(item)
                  )).toList(),
                ),
                Row(
                  children: choosenPlatforms.map((item) => FiltrCard(title: item, onTap: () => removeFilterPlatform(item)
                  )).toList(),
                ),
              ],
            ),
          ),
        ),          
        Expanded(  child: Serieslist(serials: filteredItems, watchedSeries: widget.watchedSeries, opcja: opcja, withNewSessons: widget.withNewSessons, tags: widget.tags))
      ],
    ),
    );
  }
}
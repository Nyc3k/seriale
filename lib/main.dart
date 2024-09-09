import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/viewseries.dart';
import 'package:kajecik/pages/addnewseries.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink('https://graph.imdbapi.dev/v1');

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    ),
  );


  runApp(GraphQLProvider(
    client: client,
    child: MaterialApp(
      theme: 
      ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
    
        //primaryColor: Color.fromARGB(255, 151, 211, 13), 
        primaryColor: const Color.fromARGB(255, 25, 145, 14), 
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 41, 41, 56),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide( color: Color.fromARGB(255, 25, 145, 14)) // nie działa
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide( color: Color.fromARGB(255, 25, 145, 14))
          )
        )
      ),
      home: const HomeScreen(),
    ),
  ));
}


class HomeScreen extends StatefulWidget {


  const HomeScreen({super.key,});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Serial> series = [];
  List<Serial> watchedSeries = [];
  List<Serial> seriesToWatch = [];
  List<Serial> newSessonsToWatch = [];
  List<String> _fetchedTags = [];
  List<Widget> _widgetOptions = [
    const CircularProgressIndicator( color: Color.fromARGB(255, 25, 145, 14)),
    const CircularProgressIndicator( color: Color.fromARGB(255, 25, 145, 14)),
    const CircularProgressIndicator( color: Color.fromARGB(255, 25, 145, 14)),
  ];

  @override
  void initState() {
    super.initState();
  }

double? convertToDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value == null) {
    return null;
  } else {
    throw ArgumentError("Invalid type: ${value.runtimeType}");
  }
}

int? convertToInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is double) {
    return value.toInt();
  } else if (value == null) {
    return null;
  } else {
    throw ArgumentError("Invalid type: ${value.runtimeType}");
  }
}


  @override
  Widget build(BuildContext context)  {
    

    return Scaffold(
      body: DefaultTabController(
        length: _widgetOptions.length,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('seriale').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
    
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
    
                  if (snapshot.hasData) {
                    series = snapshot.data!.docs.map((doc) {
                      var data = doc.data();
                      //print('${doc.id} wachedAt: ${data['wachedAt']}}');
                      return Serial(
                        firebaseId: doc.id,
                        isWatched: data['isWatched'],
                        title: data['title'],
                        apiId: data['apiId'],
                        platforms: List<String>.from(data['platforms']),
                        emote: data['emote'],
                        imageUrl: data['imageUrl'],
                        imageUrl2: data['imageUrl2'],
                        rating: convertToDouble(data['rating']),
                        sesons: convertToInt(data['sesons']),
                        notes: data['notes'],
                        trailerUrl: data['trailerUrl'],
                        createdAt: data['createdAt'],
                        updatedAt: data['updatedAt'],
                        releaseYear: convertToInt(data['releaseYear']),
                        endYear: convertToInt(data['endYear']),
                        plotOverview: data['plotOverview'],
                        imdbId: data['imdbId'],
                        userRating: convertToDouble(data['userRating']),
                        criticScore: convertToInt(data['criticScore']),
                        apiGenre: List<String>.from(data['apiGenre']),
                        watchedSessons: data['watchedSessons'].toInt(),
                        newSesson: data['newSesson'],
                        prority: data['prority']?.toInt(),
                        wachedAt: (data['wachedAt'] as List)
                          .map((item) => item as Timestamp)
                          .toList(),
                        //wachedNewSessonAt: data['wachedNewSessonAt']
    
                      );
                    }).toList();
                    watchedSeries = series.where((serie) => serie.isWatched == true).toList();
                    watchedSeries.sort((a,b) => b.rating!.compareTo(a.rating!));
                    seriesToWatch = series.where((serie) => serie.isWatched == false).toList();
                    newSessonsToWatch = watchedSeries.where((serie) => serie.newSesson == true).toList();
                    seriesToWatch = seriesToWatch + newSessonsToWatch;
                    seriesToWatch.sort((a,b) => b.prority!.compareTo(a.prority!));
    
                    _fetchedTags = series.expand((series) => series.apiGenre!).toSet().toList().cast();
    
                    _widgetOptions = <Widget>[
                      ViewSeries(series: watchedSeries, appBarTitle: 'Obejrzane', tags: _fetchedTags, watchedSeries: watchedSeries, withNewSessons: false,),
                      AddNewSeries(multiSelectTags: _fetchedTags, series: watchedSeries),
                      ViewSeries(series: seriesToWatch, appBarTitle: 'Do Obejrzenia', tags: _fetchedTags, watchedSeries: watchedSeries, withNewSessons: true,),
                    ];
    
                    return TabBarView(
                      children: _widgetOptions,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 25, 145, 14)));
                  }
                },
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 41, 41, 56),              
              child: TabBar(
                indicatorColor: Theme.of(context).primaryColor, // Kolor podkreślenia aktywnej zakładki
                labelColor: Theme.of(context).primaryColor, // Kolor aktywnej zakładki
                unselectedLabelColor: Colors.white70, 
                dividerColor: const Color.fromARGB(255, 41, 41, 56),
                tabs: const [
                  Tab(text: 'Obejrzane', icon: Icon(Icons.check_circle_outlined),),
                  Tab(text: 'Dodaj Nowy', icon: Icon(Icons.add_circle_outline_outlined),),
                  Tab(text: 'Do Obejrzenia', icon: Icon(Icons.arrow_circle_right_outlined),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


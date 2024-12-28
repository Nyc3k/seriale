import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/viewseries.dart';
import 'package:kajecik/pages/addnewseries.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kajecik/components/serial_provider.dart';

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


  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SerialProvider()),
    ],
    child: GraphQLProvider(
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
  ),
  )
  );
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

void sortSerialList(List<Serial> serialList, List<String> orderList) {
  // Tworzymy mapę indeksów dla orderList
  final orderMap = {for (var i = 0; i < orderList.length; i++) orderList[i]: i};

  serialList.sort((a, b) {
    int indexA = orderMap[a.firebaseId] ?? -1;
    int indexB = orderMap[b.firebaseId] ?? -1;
    return indexA.compareTo(indexB);
  });
}

  @override
  Widget build(BuildContext context)  {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      serialProvider.fetchSerials();
    });

    return Scaffold(
      body: DefaultTabController(
        length: _widgetOptions.length,
        child: Column(
          children: [
            Expanded(child: Consumer<SerialProvider>(
              builder: (context, serialProvider, child) {
                if (serialProvider.serialList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                _widgetOptions = <Widget>[
                  ViewSeries(series: serialProvider.watchedSeries, appBarTitle: 'Obejrzane', tags: serialProvider.fetchedTags, watchedSeries: watchedSeries, withNewSessons: false,),
                  AddNewSeries(multiSelectTags: _fetchedTags, series: watchedSeries),
                  ViewSeries(series: serialProvider.seriesToWatch, appBarTitle: 'Do Obejrzenia', tags: serialProvider.fetchedTags, watchedSeries: watchedSeries, withNewSessons: true,),
                ];

                return TabBarView(
                  children: _widgetOptions,
                );
              },
            )),

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


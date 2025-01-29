import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajecik/components/serial.dart';

class SerialProvider extends ChangeNotifier {
  List<Serial> serialList = [];
  List<Serial> watchedSeries = [];
  List<Serial> seriesToWatch = [];
  List<Serial> newSessonsToWatch = [];
  List<String> fetchedTags = [];
  List<String> orderList = [];

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

  Future<void> fetchSerials() async {
    try {
      // Pobierz dane z kolekcji 'seriale'
      final serialsQuery = await FirebaseFirestore.instance
          .collection('seriale')
          .get();
      
      final orderQuery = await FirebaseFirestore.instance
          .collection('kolejnosc')
          .doc('serialeObejrzane')
          .get();

      // Mapuj dokumenty do listy Serial
      serialList = serialsQuery.docs.map((doc) {
        final data = doc.data();
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
        );
      }).toList();

      orderList = List<String>.from(orderQuery.data()!['documentIds']);

      watchedSeries = serialList.where((serie) => serie.isWatched == true).toList();
      //watchedSeries.sort((a,b) => b.rating!.compareTo(a.rating!));
      for (var i = orderList.length-1; i >= 0; i--) {
        final serial = watchedSeries.firstWhere((element) => element.firebaseId == orderList[i]);
        watchedSeries.remove(serial);
        watchedSeries.insert(0, serial);
      }

      seriesToWatch = serialList.where((serie) => serie.isWatched == false).toList();
      newSessonsToWatch = watchedSeries.where((serie) => serie.newSesson == true).toList();
      seriesToWatch = seriesToWatch + newSessonsToWatch;
      seriesToWatch.sort((a,b) => b.prority!.compareTo(a.prority!));

      fetchedTags = serialList.expand((series) => series.apiGenre!).toSet().toList().cast();

      // Powiadom widżety o zmianie stanu
      notifyListeners();
    } catch (e) {
      print('Błąd podczas pobierania danych: $e');
    }
  }
}

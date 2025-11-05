import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajecik/components/serial_provider.dart';
import 'package:provider/provider.dart';

class Serial {
  String? firebaseId;
  String? apiId;
  bool isWatched;
  String title;
  List<String>? tags;
  List<String> platforms;
  String? emote;
  String? imageUrl;
  String? imageUrl2;
  double? rating;
  int? sesons;
  String? notes;
  String? trailerUrl;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  int? releaseYear;
  int? endYear;
  String? plotOverview;
  String? imdbId;
  double? userRating;
  int? criticScore;
  List<String>? apiGenre; 
  int? watchedSessons;
  bool? newSesson;
  int? prority;
  // Timestamp? wachedAt;
  List<Timestamp>? wachedAt;
  Timestamp? wachedNewSessonAt;


  Serial({
    this.firebaseId,
    this.apiId,
    required this.isWatched,
    required this.title,
    this.tags,
    required this.platforms,
    this.emote,
    this.imageUrl,
    this.imageUrl2,
    this.rating,
    this.sesons,
    this.notes,
    this.trailerUrl,
    this.createdAt,
    this.updatedAt,
    this.releaseYear,
    this.endYear,
    this.plotOverview,
    this.imdbId,
    this.userRating,
    this.criticScore,
    this.apiGenre,
    this.watchedSessons,
    this.newSesson,
    this.prority,
    this.wachedAt,
    this.wachedNewSessonAt
  });

  factory Serial.fromJson(Map<String, dynamic> json) {
    return Serial(
      isWatched: true,
      apiId: json['APIid'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      platforms: json['platform'],
      emote: json['emote'],
      imageUrl: json['imageUrl'],
      imageUrl2: json['imageUrl2'],
      rating: json['ranking'],
      sesons: json['sesons'],
      notes: json['notes'],
      trailerUrl: json['trailerUrl'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      releaseYear: json['ReleseYear'],
    );
  }
  addValues(
    String? newApiId, 
    String? newEmote, 
    String? newImageUrl,
    String? newImageUrl2,
    double? newRating,
    String? newTrailerUrl,
    Timestamp? newCreatedAt,
    Timestamp? newUpdatedAt,
    int? newReleaseYear,
    int? newEndYear,
    String? newPlotOverview,
    String? newImdbId,
    double? newUserRating,
    int? newCriticScore,
    List<String>? newApiGenre
    ) {
      apiId = newApiId;
      emote = newEmote;
      imageUrl = newImageUrl;
      imageUrl2 = newImageUrl2;
      rating = newRating;
      trailerUrl = newTrailerUrl;
      createdAt = newCreatedAt;
      updatedAt = newUpdatedAt;
      releaseYear = newReleaseYear;
      endYear = newEndYear;
      plotOverview = newPlotOverview;
      imdbId = newImdbId;
      userRating = newUserRating;
      criticScore = newCriticScore;
      apiGenre = newApiGenre;
  }
  addApiResult({
    required String apiId,
    String? imageUrl,
    String? imageUrl2,
    String? trailerUrl,
    int? releaseYear,
    int? endYear,
    String? plotOverview,
    String? imdbId,
    double? userRating,
    int? criticScore,
    List<String>? apiGenre,
    int? watchedSessons,
    bool? newSesson,
  }
  ){
    this.apiId = apiId;
    this.imageUrl = imageUrl;
    this.imageUrl2 = imageUrl;
    this.trailerUrl = trailerUrl;
    this.releaseYear = releaseYear;
    this.endYear = endYear;
    this.plotOverview = plotOverview;
    this.imdbId = imdbId;
    this.criticScore = criticScore;
    this.apiGenre = apiGenre;
    this.watchedSessons = watchedSessons;
    this.newSesson = newSesson;
    this.userRating = userRating;
  }

  Map<String, dynamic> toJson(int rok, SerialProvider serialProvider) {
    List<Timestamp> temp = wachedAt!.where((el) => el.toDate().year == rok ).toList();
    List<String> sformatowanaData = temp.map((Element) => DateFormat('dd.MM.yyyy').format(Element.toDate())).toList();
    print(serialProvider.orderList);
    print(this.firebaseId);
    int poz = serialProvider.orderList.indexOf(this.firebaseId!);
    print(poz);
    
    return{
      'poz': poz,
      'id_firebase':  this.firebaseId,
      'id_api': this.apiId,
      'wached': this.isWatched,
      'title': this.title,
      'tags': this.tags,
      'platforms': this.platforms[0],
      'emote': this.emote,
      'imageUrl': this.imageUrl,
      'imageUrl2': this.imageUrl2,
      'rating': this.rating,
      'sesons': this.sesons,
      'notes': this.notes,
      'trailerUrl': this.trailerUrl,
      'createdAt': this.createdAt?.toDate().toString(),
      'updatedAt': this.updatedAt?.toDate().toString(),
      'releaseYear': this.releaseYear,
      'endYear': this.endYear,
      'plotOverview': this.plotOverview,
      'imdbId': this.imdbId,
      'userRating': this.userRating,
      'criticScore': this.criticScore,
      'apiGenre': this.apiGenre,
      'watchedSessons': this.watchedSessons,
      'newSesson': this.newSesson,
      'prority': this.prority,
      'wachedAt': sformatowanaData
    };
  }
}

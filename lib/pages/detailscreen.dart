
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/blureimage.dart';
import 'package:kajecik/components/buutonurl.dart';
import 'package:kajecik/components/detaletext.dart';
import 'package:kajecik/components/genercard.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/setrating.dart';
import 'package:kajecik/pages/editseries.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/serial_provider.dart';

class DetailScreen extends StatelessWidget {
  final Serial serial;
  //final List<Serial> watchedSeries;
  //final List<String>? tags;
  //const DetailScreen({ required this.serial, super.key,  required this.watchedSeries,   this.tags});
  const DetailScreen({ required this.serial, super.key});
 void obejrzany(context, SerialProvider serialProvider) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => SetRanking(
    allTags: serialProvider.fetchedTags,
    isWatched: true,
    newSerial: serial,
    series: serialProvider.watchedSeries,
    firestore: FirebaseFirestore.instance,
    isNew: false,
    newSesson: false,
    addSesson: false,
  )));
 }
 void deleteSeries(context, SerialProvider serialProvider) {
  // final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Na pewno?'),
        content: const Text('Czy na pewno chcesz usunąć serial?'),
        actions: <Widget>[
          TextButton(
            child: Text('Tak', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              FirebaseFirestore.instance.collection('seriale').doc(serial.firebaseId).delete().then((value) => {
                serialProvider.orderList.remove(serial.firebaseId),
                FirebaseFirestore.instance.collection('kolejnosc').doc('serialeObejrzane').update({
                  'documentIds' : serialProvider.orderList,
                }).then((_) async {
                await serialProvider.fetchSerials();
              })});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Nie', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
 }

 void nowySezon(context, SerialProvider serialProvider) {
  //final serialProvider = Provider.of<SerialProvider>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return serial.isWatched && !serial.newSesson!
      ? AlertDialog(
        title: const Text('Nowey sezon'),
        content: const Text('Wybierz czy nowy sezon zosatł już obejrzany czy powinien zostać dodany do sekcji Do obejrzenia'),
        actions: <Widget>[
          TextButton(
            child: Text('Obejrzany', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetRanking(
                allTags: serialProvider.fetchedTags,
                isWatched: true,
                newSerial: serial,
                series: serialProvider.watchedSeries,
                firestore: FirebaseFirestore.instance,
                isNew: false,
                newSesson: true,
                addSesson: true
            )));
              
            },
          ),
          TextButton(
            child: Text('Do obejrzenia', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () async {
              FirebaseFirestore.instance.collection('seriale').doc(serial.firebaseId).update({
                'newSesson' : true,
                'sesons': serial.sesons! + 1,
                'updatedAt' : Timestamp.now(),
                'prority' : 2
              }).then((_) async {
                await serialProvider.fetchSerials();
              }); 
              Navigator.of(context).pop();
            },
          ),
        ],
      )
      : AlertDialog(
        title: const Text('Nowey sezon'),
        content: const Text('Czy na pewno chcesz dodać nowy sezon?'),
        actions: <Widget>[
          TextButton(
            child: Text('Tak', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              FirebaseFirestore.instance.collection('seriale').doc(serial.firebaseId).update({
                'newSesson' : true,
                'sesons': serial.sesons! + 1,
                'updatedAt' : Timestamp.now(),
              }).then((_) async {
                await serialProvider.fetchSerials();
              }); 
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Nie', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
 }

  @override
  Widget build(BuildContext context) {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    String tekstJeden = ' ';
    // print('${DateFormat('dd MMMM yyyy, HH:mm').format(serial.wachedAt!.toDate())} > ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime(2024,8,6,23)).toString()} => ${serial.wachedAt!.toDate().isAfter(DateTime(2024,8,6,23))} ');
    if (serial.releaseYear != null) tekstJeden=tekstJeden+serial.releaseYear.toString();
    if (serial.endYear != null) tekstJeden='$tekstJeden - ${serial.endYear}';
    if (serial.sesons != null) {
      if (serial.sesons == 1) tekstJeden='$tekstJeden • ${serial.sesons} sezon';
      if (serial.sesons! > 1 && serial.sesons! < 5 ) tekstJeden='$tekstJeden • ${serial.sesons} sezony';
      if (serial.sesons! >= 5) tekstJeden='$tekstJeden • ${serial.sesons} sezonów';
    }
    List<Widget> platformImages = serial.platforms.map((platform) => Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: serial.platforms[0] == 'Nie_Wiem' ? 
        const Text(
          '?  ',
          style: TextStyle(fontSize: 34, color: Colors.grey),
        ): 
        Image.asset('assets/platform/$platform.png',
          height: 50,
          width: 50,
      )
    )as Widget).toList();
    platformImages.insert(0,const Text('Dostępny na: ', style: TextStyle( fontSize: 18, color: Color.fromARGB(255, 158, 158, 184))));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String result) {
                  switch (result) {
                    case 'Option 1':
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SetRanking(
                        allTags: serialProvider.fetchedTags, 
                        isWatched: true, 
                        newSerial: serial, 
                        series: serialProvider.watchedSeries, 
                        firestore: FirebaseFirestore.instance, 
                        isNew: false, 
                        newSesson: true, 
                        addSesson: false,
                      ))
                    );
                      break;
                    case 'Option 2':
                      nowySezon(context, serialProvider);
                      break;
                    case 'Option 3':
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditSeries(serial: serial, watchedSeries: serialProvider.watchedSeries, tags: serialProvider.fetchedTags)));
                      break;
                    case 'Option 4':
                      obejrzany(context, serialProvider);
                      break;
                    case 'delete':
                      deleteSeries(context, serialProvider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (!serial.isWatched) const PopupMenuItem<String>(
                    value: 'Option 4',
                    child: Text('Serial został obejrzany'),
                  ),
                  if (serial.isWatched && serial.newSesson!) const PopupMenuItem<String>(
                    value: 'Option 1',
                    child: Text('Nowy sezon zosatał obejrzany'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Option 2',
                    child: Text('Dodaj nowy sezon'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Option 3',
                    child: Text('Edytuj'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Usuń'),
                  ),
                ],
              ),
            ],
            pinned: false, // AppBar pozostanie na górze ekranu
            floating: true, // AppBar pokaże się ponownie po przewinięciu w górę
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      
                      if (serial.imageUrl != null)  BlureImage(imageURL: serial.imageUrl!), 
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Text(serial.title, style: const TextStyle( fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(tekstJeden, style: const TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                            ),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: serial.apiGenre!.map((gener) => GenerCard(title: gener, onTap: null)).toList()
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Row(
                                children: platformImages,
                              ),
                            ),
                            if (serial.plotOverview != null) Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Zarys Fabuły:', style: TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('  ${serial.plotOverview!}'),
                                  )
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if(serial.trailerUrl != null) ButtonUrl(url: serial.trailerUrl!, image:  'assets/platform/yt.png', h: 30, w: 70 ),
                                  if(serial.imdbId != null) ButtonUrl(url: 'https://www.imdb.com/title/${serial.imdbId}/', image:  'assets/IMDb.png', h: 40, w: 70 ),
                                ],
                              ),
                            ),
                            const Center(child: Text('Oceny:', style: TextStyle( fontSize: 23, color:  Color.fromARGB(255, 158, 158, 184)))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if(serial.userRating != null) Column(
                                  children: [
                                    const Text('Użytkownicy', style: TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                    Text(serial.userRating!.toString(), style: const TextStyle( fontSize: 18, color: Color.fromARGB(255, 158, 158, 184))),
                                  ],
                                ),
                                // if(serial.rating != null) Column(
                                //   children: [
                                //     const Text('Moja', style: TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                //     Text(serial.rating!.toString(), style: const TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                //   ],
                                // ),
                                if(serial.criticScore != null) Column(
                                  children: [
                                    const Text('Krytycy', style: TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                    Text(serial.criticScore!.toString(), style: const TextStyle( fontSize: 18, color:  Color.fromARGB(255, 158, 158, 184))),
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 14.0, right: 8.0, left: 8.0),
                              child: Column(
                                children: [
                                  if(serial.wachedAt != null && serial.wachedAt!.isNotEmpty) Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const DetaleText(widgetText: 'Obejrzany: ' , size: 16,),
                                          Text(DateFormat('dd MMMM yyyy').format(serial.wachedAt!.first.toDate()).toString())
                                        ],
                                      ),
                                      if(serial.wachedAt!.length > 1) Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const DetaleText(widgetText: 'Ostatnio obejrzany: ' , size: 16,),
                                          Text(DateFormat('dd MMMM yyyy').format(serial.wachedAt!.last.toDate()).toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if(serial.createdAt != null) Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const DetaleText(widgetText: 'Utworzono: ' , size: 16,),
                                      Text(DateFormat('dd MMMM yyyy, HH:mm').format(serial.createdAt!.toDate()).toString())
                                    ],
                                  ),
                                  if(serial.updatedAt != null) Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const DetaleText(widgetText: 'Zaktualizowano: ' , size: 16,),
                                      Text(DateFormat('dd MMMM yyyy, HH:mm').format(serial.updatedAt!.toDate()).toString())
                                    ],
                                  ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                      ),
                      SizedBox(height: 25,)
                      
                      // Tytuł DONE
                      // rok wydania - rok end DONE
                      // ilość sezonów nie wiem co z ilością sezonów obejrzanych DONE
                      // gatunki/Tagi w postaci fajnej ale bez obramówki DONE
                      // dostępny na obrazki DONE
                      // albo nad/pod plot overview przycsk imdb i yt DONE
                      // plot overvierw DONE
                      // w jednym row oceny moja , critic i users, done
                      // data dodania, updatu, obejrzenia , obejrzenia najowszego sezonu
                      
                      
                      
                    ],
                  ),
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
      
    );
    
  }
}




//   !serial.isWatched ? ButtonMy(text: 'Obejrzany', onPressed: (){

          //     Navigator.push(context, MaterialPageRoute(builder: (context) => setRanking(
          //       allTags: tags!,
          //       isWatched: true,
          //       newSerial: serial,
          //       series: watchedSeries,
          //       firestore: FirebaseFirestore.instance,
          //       isNew: false,
          //       newSesson: false,
          //     )));

          //   }):const SizedBox(),
          //   if (serial.isWatched && serial.newSesson!) ButtonMy(
          //     text: 'Nowy sezon zosatał obejrzany',
          //     onPressed: () {
          //       Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => setRanking(
          //           allTags: tags!, 
          //           isWatched: true, 
          //           newSerial: serial, 
          //           series: watchedSeries, 
          //           firestore: FirebaseFirestore.instance, 
          //           isNew: false, 
          //           newSesson: true, 
          //         ))
          //       );
          //     }
          //   ),
          // ButtonMy(text: 'Nowey sezon', onPressed: (){

            

          //   }
          //   )
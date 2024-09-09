import 'package:flutter/material.dart';
import 'package:kajecik/components/rankingupdate.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/pages/detailscreen.dart';

class PosterMinicard extends StatelessWidget {
  final Serial serial;
  final List<Serial> watchedSeries;
  final bool withNewSessons;
  final List<String> tags;
  
  const PosterMinicard({ required this.serial, super.key, required this.watchedSeries, required this.withNewSessons, required this.tags});
  
  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(serial: serial, watchedSeries: watchedSeries, tags: tags)));
      },
      onLongPress: () {
        if(serial.isWatched) Navigator.push(context, MaterialPageRoute(builder: (context) => RankingUpdate(serial: serial, series: watchedSeries, allTags: tags,)));
      },
      
      child: Container(
        margin: const EdgeInsets.all(16),
        
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
            bottomStart: Radius.elliptical(50, 20),
            bottomEnd: Radius.elliptical(50, 20),
          )
        ),
      
        
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: serial.imageUrl != null 
              ? Image.network(
                  serial.imageUrl!,
                  fit: BoxFit.cover,
                  height: 140,
                )
              : const Text('noImage')
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (serial.emote != null && serial.emote!.isNotEmpty && !withNewSessons)
                Image.asset('assets/emote/${serial.emote}.png',
                height: 40,
                width: 40,
                ),
                if (withNewSessons && serial.newSesson! && serial.watchedSessons != 0) Text(' S${serial.watchedSessons!+1}', style: const TextStyle(fontSize: 20),),
                !serial.platforms.contains('Nie_Wiem') ?
                  Image.asset('assets/platform/${serial.platforms[0]}.png',
                    height: 40,
                    width: 40,
                  )
                  : const Text('?', style: TextStyle( fontSize: 25)),

              ],
            )
          ]
          
        )
        
      ),
    ); 
  }
}
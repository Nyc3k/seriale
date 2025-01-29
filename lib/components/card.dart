import 'package:flutter/material.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/pages/detailscreen.dart';

class SeriesCard extends StatelessWidget {
  final Serial serial;
  final List<Serial> watchedSeries;
  
  const SeriesCard({ required this.serial, super.key, required this.watchedSeries});
  
  @override
  Widget build(BuildContext context) {

    String tekst;
    (serial.sesons as int) > 4 ? tekst = '${serial.sesons} sezonów |':
    (serial.sesons as int) > 1 ? tekst = '${serial.sesons} sezony |' :
    tekst = '${serial.sesons} sezon |';
    tekst = '$tekst ${serial.releaseYear} | ${serial.tags![0]}';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(serial: serial )));
      },
      child: Container(
        width: 180,
        //height: 145,
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
        children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              
              child: serial.imageUrl2 != null ? Image.network(serial.imageUrl2!): const Text('noImage')
            ),
            !serial.platforms.contains('Nie_Wiem') ? Positioned(
              left: 5,
              top: 5,
              child: Image.asset('assets/platform/${serial.platforms[0]}.png',scale: 10,),
              ) : const Positioned(
              left: 5,
              top: 5,
              child: Text('?',style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,)),
              )
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Text('${serial.title} ', style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  ),
                  const Expanded( flex: 1, child: Text("")),
                  serial.emote!.isNotEmpty ? 
                  Expanded(
                    flex: 2,
                    child: Text('${serial.emote}', style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    )),
                  ) : const SizedBox()
                ],
          ),
          Text(tekst, style: const TextStyle(
              fontSize: 10,
              color: Color.fromARGB(255, 158, 158, 184),
              
              ),
            ),
        ],
      )
      
        ]
      ),
      ),
    ); 
  }
}
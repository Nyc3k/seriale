import 'package:flutter/material.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/pages/detailscreen.dart';

class Postercard extends StatelessWidget {
  final Serial serial;
  final List<Serial> watchedSeries;
  
  const Postercard({ required this.serial, super.key, required this.watchedSeries});
  
  @override
  Widget build(BuildContext context) {

    String tekstSezony;
    String tekstTagi;

    String tekstJeden = '';
    if (serial.releaseYear != null) tekstJeden=tekstJeden+serial.releaseYear.toString();
    if (serial.endYear != null) tekstJeden='$tekstJeden - ${serial.endYear}';
    (serial.sesons as int) > 4 ? tekstSezony = '${serial.sesons} sezonów':
    (serial.sesons as int) > 1 ? tekstSezony = '${serial.sesons} sezony' :
    tekstSezony = '${serial.sesons} sezon';
    tekstTagi = '${serial.apiGenre}';
    tekstTagi = tekstTagi.substring(1,tekstTagi.length-1);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(serial: serial)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          
          children: [
            Expanded(
              flex: 7,
              child: Column(
                
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${serial.title} ', style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(tekstSezony, style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 158, 158, 184),
                            ),
                          ),
                          const SizedBox(height: 3,),
                          Text(tekstJeden, style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 158, 158, 184),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    if (serial.emote != null && serial.emote!.isNotEmpty) Expanded(
                      flex: 1,
                      child: Image.asset('assets/emote/${serial.emote}.png',
                        height: 40,
                        width: 40,
                ),
                    //   Text('${serial.emote}', style: const TextStyle(
                    //   color: Colors.white,
                    //   fontSize: 20
                    // )),
                    )
                  ],
                ),
                Text(tekstTagi, 
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 158, 158, 184),
                  ),
                ),
              ]),
            ),
            
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                borderRadius: BorderRadius.circular(20),
                
                child: serial.imageUrl != null ? Image.network(serial.imageUrl!, width: 90,): const Text('noImage')
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
                ],
              ),
            ),

          ],
        )
        
      ),
    ); 
  }
}
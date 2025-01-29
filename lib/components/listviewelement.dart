import 'package:flutter/material.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/pages/detailscreen.dart';

class ListViewElement extends StatelessWidget {
  const ListViewElement({
    super.key,
    required this.serial,
  });

  final Serial serial;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(serial.firebaseId),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10), 
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(serial: serial)));
      },
      title: Row(
        children: [
          Image.network(
            serial.imageUrl!,
            fit: BoxFit.cover,
            height: 120,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serial.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'wydany: ${serial.releaseYear} | sezony: ${serial.sesons}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          serial.platforms[0] == 'Nie_Wiem' ? 
            const Text(
                  '?  ',
                  style: TextStyle(fontSize: 34, color: Colors.grey),
                ):
            Image.asset(
              'assets/platform/${serial.platforms[0]}.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
        ],
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ButtonUrl extends StatelessWidget {
  final String url;
  final String image;
  final double w,h;
  const ButtonUrl({super.key, required this.url, required this.image, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () async{
      Uri uri = Uri.parse(url);
      try {
        //if (await canLaunchUrl(uri)) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            AlertDialog(
        title: const Text('???????'),
        content: const Text('Nie wiem coś się wywaliło'),
        actions: <Widget>[
          
          TextButton(
            child: Text('  :(  ', style: TextStyle(color: Theme.of(context).primaryColor),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
          }
        // } else {
        //   throw 'Nie można otworzyć $url';
        // }
      } catch (e) {
        //print('Error w  canLaunchUrl: $e');
      }
    }, 
    icon: Image.asset(image, height: h, width: w,),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:kajecik/components/posterCard.dart';
import 'package:kajecik/components/posterminicard.dart';
import 'package:kajecik/components/serial.dart';

class Serieslist extends StatelessWidget {
  final List<Serial> serials;
  final List<Serial> watchedSeries;
  final int opcja;
  final bool withNewSessons;
  final List<String> tags;
  const Serieslist({super.key, required this.serials, required this.watchedSeries, required this.opcja, required this.withNewSessons, required this.tags});

  @override
  Widget build(BuildContext context) {

    if(opcja == 1){
      return serials.isEmpty ? const Center(child: Text('Brak seriali')):
      ListView.builder(
        itemCount: serials.length,
        itemBuilder: (context, index){
        return Postercard(serial: serials[index], watchedSeries: watchedSeries,);
      });
    } else {
      return serials.isEmpty ? const Center(child: Text('Brak seriali')):
      GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ((MediaQuery.of(context).size.width)/120).floor(),
          childAspectRatio: 0.51
        ),
        itemCount: serials.length,
        itemBuilder: (context, index) {
          return PosterMinicard(
            serial: serials[index], 
            watchedSeries: watchedSeries,
            withNewSessons: withNewSessons,
            tags: tags,
          );
      });
    }
  }
}
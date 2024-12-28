import 'package:flutter/material.dart';
import 'package:kajecik/components/posterCard.dart';
import 'package:kajecik/components/posterminicard.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/serial_provider.dart';
import 'package:provider/provider.dart';

class Serieslist extends StatefulWidget {
  final List<Serial> serials;
  final List<Serial> watchedSeries;
  final int opcja;
  final bool withNewSessons;
  final List<String> tags;
  final List<String> seriesOrder;
  const Serieslist({super.key, required this.serials, required this.watchedSeries, required this.opcja, required this.withNewSessons, required this.tags, required this.seriesOrder});

  @override
  State<Serieslist> createState() => _SerieslistState();
}

class _SerieslistState extends State<Serieslist> {
  

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = widget.serials.removeAt(oldIndex);
      widget.serials.insert(newIndex, item);

      // Aktualizuj kolejność ID
      final id = widget.seriesOrder.removeAt(oldIndex);
      widget.seriesOrder.insert(newIndex, id);
    });

    // Zapisz nową kolejność w Firestore
    //_updateSeriesOrder();
  }

  @override
  Widget build(BuildContext context) {


    if(widget.opcja == 1){
      return widget.serials.isEmpty ? const Center(child: Text('Brak seriali')):
      ReorderableListView(
              onReorder: _onReorder,
              children: [
                for (final serial in widget.serials)
                  ListTile(
                    key: ValueKey(serial.firebaseId),
                    title: Text(serial.title),
                    subtitle: Text('Ocena: ${serial.rating ?? "Brak"}'),
                  ),
              ],
            );
    } else {
      return widget.serials.isEmpty ? const Center(child: Text('Brak seriali')):
      GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ((MediaQuery.of(context).size.width)/120).floor(),
          childAspectRatio: 0.51
        ),
        itemCount: widget.serials.length,
        itemBuilder: (context, index) {
          return PosterMinicard(
            serial: widget.serials[index], 
            watchedSeries: widget.watchedSeries,
            withNewSessons: widget.withNewSessons,
            tags: widget.tags,
          );
      });
    }
  }
}
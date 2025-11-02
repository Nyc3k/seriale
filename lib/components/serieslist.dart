import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajecik/components/posterCard.dart';
import 'package:kajecik/components/posterminicard.dart';
import 'package:kajecik/components/serial.dart';
import 'package:kajecik/components/serial_provider.dart';
import 'package:kajecik/pages/detailscreen.dart';
import 'package:provider/provider.dart';
import 'package:kajecik/components/listviewelement.dart';

class Serieslist extends StatefulWidget {
  final List<Serial> serials;
  final List<Serial> watchedSeries;
  final int opcja;
  final bool withNewSessons;
  final List<String> tags;
  final List<String> seriesOrder;
  final bool watched;
  const Serieslist({super.key, required this.serials, required this.watchedSeries, required this.opcja, required this.withNewSessons, required this.tags, required this.seriesOrder, required this.watched});

  @override
  State<Serieslist> createState() => _SerieslistState();
}

class _SerieslistState extends State<Serieslist> {
  

  void _onReorder(int oldIndex, int newIndex) {
    final serialProvider = Provider.of<SerialProvider>(context, listen: false);
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = widget.serials.removeAt(oldIndex);
      widget.serials.insert(newIndex, item);

      // Aktualizuj kolejność ID
      final id = widget.seriesOrder.removeAt(oldIndex);
      widget.seriesOrder.insert(newIndex, id);
    });

    
    if (widget.watched) {
      // Zapisz nową kolejność w Firestore
      FirebaseFirestore.instance.collection('kolejnosc').doc('serialeObejrzane').update({
          'documentIds' : widget.seriesOrder,
      });
      for (var i = serialProvider.orderList.length-1; i >= 0; i--) {
        final serial = serialProvider.watchedSeries.firstWhere((element) => element.firebaseId == widget.seriesOrder[i]);
        serialProvider.watchedSeries.remove(serial);
        serialProvider.watchedSeries.insert(0, serial);
      }
    } else {
      // Zapisz nową kolejność w Firestore
      FirebaseFirestore.instance.collection('kolejnosc').doc('ToWatch').update({
          'documentIds' : widget.seriesOrder,
      });
      for (var i = serialProvider.orderToWatchList.length-1; i >= 0; i--) {
        final serial = serialProvider.seriesToWatch.firstWhere((element) => element.firebaseId == widget.seriesOrder[i]);
        serialProvider.seriesToWatch.remove(serial);
        serialProvider.seriesToWatch.insert(0, serial);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if(widget.opcja == 1){
      return widget.serials.isEmpty ? const Center(child: Text('Brak seriali')):
      ReorderableListView(
        onReorder: _onReorder,
        children: [
          for (final serial in widget.serials)
            ListViewElement(serial: serial, key: ValueKey(serial.firebaseId),),
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



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajecik/components/fajnyprzycisk.dart';
import 'package:kajecik/components/multichooser.dart';
import 'package:kajecik/globals.dart';
import 'package:kajecik/pages/addseriesapi.dart';
import '../components/serial.dart';

class AddNewSeries extends StatefulWidget {

  final List<String> multiSelectTags;
  final List<Serial> series;

  const AddNewSeries({
    required this.multiSelectTags, 
    super.key,
    required this.series
  });

  @override
  _AddNewSeriesState createState() => _AddNewSeriesState();
}

class _AddNewSeriesState extends State<AddNewSeries> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sezonsController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _newOptionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;



  //List<String> _selectedTags = [];
  List<String> _selectedPlatforms = [];
  bool _isWatched = true;

  final List<String> _multiSelectPlatform = ['Netflix', 'Apple_TV', 'Canal_Plus', 'Disney_Plus','HBO_MAX','TVN_Player','Prime_Video','ShyShowTime','Nie_Wiem',];

  void _resetForm() {
    _formKey.currentState?.reset();
    _sezonsController.clear();
    _titleController.clear();
    _notesController.clear();
    _newOptionController.clear();
    setState(() {
      _selectedPlatforms = [];
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowy Tytuł', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        )),
        backgroundColor: const Color.fromARGB(255, 18, 18, 23),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 50.0, right: 50.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Do obejrzenia",style: TextStyle(
                  color: Colors.white,
                  fontSize: 15),),
                  Switch(
                    value: _isWatched, 
                    onChanged: (bool value) {
                      setState(() {
                        _isWatched = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),  
                const Text("Obejrzany",style: TextStyle(
                  color: Colors.white,
                  fontSize: 15),),
                ],
              ),
              
              const SizedBox(height: 20.0),

              // Pole tekstowe
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tytuł', 
                  labelStyle: const TextStyle(
                    color: Colors.white
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 41, 41, 56),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  )),
                style: const TextStyle(
                  color: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nie no coś wpisać trzeba';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              const Center(child: Text("Platforma", style: TextStyle(color: Colors.white, fontSize: 20))),
              // Lista wyboru wielokrotnego
              const SizedBox(height: 5.0),
              MultiChooser(
                initvalues: _selectedPlatforms,
                allTags: _multiSelectPlatform, 
                onConfirm: (selectedList) {
                  setState(() {
                    _selectedPlatforms = selectedList.cast<String>();
                  });
                }, 
                title: "Platforma", 
                myChipDisplay: true,
              ),
              

              
              const SizedBox(height: 20.0),
              
              if (Globals.mode.value == 0) TextFormField(
                controller: _sezonsController,
                decoration: InputDecoration(
                  labelText: 'Ilość sezonów', 
                  labelStyle: const TextStyle(
                    color: Colors.white
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 41, 41, 56),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  )),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nie no coś wpisać trzeba';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 20.0),

              // Pole tekstowe
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Dodatkowe uwagi', 
                  labelStyle: const TextStyle(
                    color: Colors.white
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 41, 41, 56),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  )),
                style: const TextStyle(
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 20.0),
              // Przycisk submit
              ButtonMy(text: 'Dodaj', onPressed: () {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();
                  Serial newSerial = Globals.mode.value == 0 ? 
                    Serial(isWatched: _isWatched, title: _titleController.text , platforms: _selectedPlatforms, sesons: int.parse(_sezonsController.text), notes: _notesController.text):
                    Serial(isWatched: _isWatched, title: _titleController.text , platforms: _selectedPlatforms, notes: _notesController.text);
                  

                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddAPIandRanking(
                    firestore: _firestore,
                    isWatched: _isWatched,
                    allTags: widget.multiSelectTags,
                    series: widget.series,
                    newSerial: newSerial,
                    isNew: true,
                    newSesson: false,
                    formClick: _resetForm
                    
                    )));
                 },),
                 const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
// TO JEST DZIWNE \/
class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip(this.reportList, {super.key, required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];
  
  _buildChoiceList() {
    List<Widget> choices = [];

    for (var i = 0; i < widget.reportList.length; i += ((MediaQuery.of(context).size.width)/180).floor()) {
      List<Widget> rowChoices = [];
      for (var j = i; j < i + ((MediaQuery.of(context).size.width)/180).floor() && j < widget.reportList.length; j++) {
        rowChoices.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2.0),
              child: ChoiceChip(
                label: Text(widget.reportList[j]),
                selected: selectedChoices.contains(widget.reportList[j]),
                onSelected: (selected) {
                  setState(() {
                    selectedChoices.contains(widget.reportList[j])
                        ? selectedChoices.remove(widget.reportList[j])
                        : selectedChoices.add(widget.reportList[j]);
                    widget.onSelectionChanged(selectedChoices);
                  });
                },
              ),
            ),
          ),
        );
      }
      choices.add(Row(children: rowChoices));
    }

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildChoiceList(),
    );
  }
}

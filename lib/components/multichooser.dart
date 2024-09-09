import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiChooser extends StatefulWidget {
  final List<String> allTags;
  final Function(List<String>) onConfirm;
  final String title;
  final bool myChipDisplay;
  final List<String> initvalues;
  const MultiChooser({super.key , required this.allTags, required this.onConfirm, required this.title, required this.myChipDisplay, required this.initvalues});

  @override
  State<MultiChooser> createState() => _MultiChooserState();
}

class _MultiChooserState extends State<MultiChooser> {
  late List<String> _selectedItems;

 @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initvalues);
  }

  @override
  Widget build(BuildContext context) {

    return   MultiSelectBottomSheetField(
      initialChildSize: 0.4,
      listType: MultiSelectListType.CHIP,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.45),
        //color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        // border: Border.all(
        //   color: Theme.of(context).primaryColor,
        //   width: 2,
        // ),
      ),
      buttonIcon: const Icon(
        Icons.filter_list,
        color: Colors.white,
      ),
      searchable: true,
      initialValue: widget.initvalues,
      buttonText: Text(widget.title, style: const TextStyle(fontSize: 14),),
      title: Text(widget.title),
      items: widget.allTags.map((tag) => MultiSelectItem<String>(tag, tag)).toList(),
      onConfirm: (values) {
        setState(() {
          _selectedItems = List<String>.from(values);
        });
        widget.onConfirm(_selectedItems);
        },
      chipDisplay: widget.myChipDisplay 
      ? MultiSelectChipDisplay(
            onTap: (value) {
              setState(() {
                _selectedItems.remove(value);
              });
              widget.onConfirm(_selectedItems);
            },
          )
      : MultiSelectChipDisplay.none(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nie no coś wybrać trzeba';
        }
        return null;
      },
    );
  }
}
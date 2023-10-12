import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trinkspielplatz/model/spieler_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'assets/colors.dart' as colors;

class SpielerEinhundertModal extends StatefulWidget {
  final List<Spieler100> spieler;
  final Function() setName;

  const SpielerEinhundertModal(
      {super.key, required this.spieler, required this.setName});

  @override
  State<SpielerEinhundertModal> createState() => _SpielerEinhundertModalState();
}

class _SpielerEinhundertModalState extends State<SpielerEinhundertModal> {
  TextEditingController nameController = TextEditingController();
  String nameEingabe = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bluegray,
      appBar: AppBar(
          title: const Text("Spieler hinzufügen"),
          centerTitle: true,
          backgroundColor: colors.teal,
          foregroundColor:
              Colors.black), // Adjust the opacity and color as needed
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Spieler',
                      style: TextStyle(
                          fontSize: 22,
                          color: colors.teal,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.4,
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0))),
                  child: ListView.builder(
                    itemCount: widget.spieler.length,
                    itemBuilder: (context, index) {
                      final spieler = widget.spieler[index];
                      Color? bgColor =
                          index.isEven ? Colors.white : Colors.grey[200];
                      return Dismissible(
                        // Specify the direction to swipe and delete
                        direction: DismissDirection.endToStart,
                        key: Key(spieler.name),
                        onDismissed: (direction) {
                          // Removes that item the list on swipwe
                          setState(() {
                            widget.spieler.removeAt(index);
                          });
                          // Shows the information on Snackbar
                          /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${spieler.name} gelöscht'))); */
                          notify.notifyError(
                              context, '${spieler.name} gelöscht');
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.delete)),
                          ),
                        ),
                        child: Container(
                            color: bgColor,
                            child: ListTile(title: Text(spieler.name))),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30), // Limit input to 30 characters
                  ],
                  controller: nameController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      nameEingabe = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Name eingeben...',
                    filled: true, // Set to true to enable background color
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton(
                      heroTag: 'spieler_einhundert_add_tag',
                      foregroundColor: Colors.black,
                      backgroundColor: colors.teal,
                      onPressed: () {
                        setState(() {
                          if (nameEingabe.isEmpty) {
                            notify.notifyError(context, 'Kein Name eingegeben');
                          } else if (widget.spieler
                              .where((einSpieler) =>
                                  einSpieler.name == nameEingabe)
                              .toList()
                              .isNotEmpty) {
                            notify.notifyError(context, 'Name breits vergeben');
                          } else {
                            widget.spieler.add(Spieler100(
                                id: '', name: nameEingabe, punkte: 0));
                            nameEingabe = '';
                            nameController.clear();
                          }
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      heroTag: 'einhundert_start_tag',
                      foregroundColor: Colors.black,
                      backgroundColor: colors.teal,
                      onPressed: () {
                        widget.setName();
                        setState(() {
                          for (var spieler in widget.spieler) {
                            spieler.punkte = 0;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.play_arrow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // You can replace this with your custom overlay content
      ),
    );
  }
}

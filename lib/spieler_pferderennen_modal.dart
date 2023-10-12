import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trinkspielplatz/custom_widget.dart';
import 'package:trinkspielplatz/model/spieler_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'assets/colors.dart' as colors;

class SpielerPferderennenModal extends StatefulWidget {
  final List<SpielerPferderennen> spieler;

  const SpielerPferderennenModal({super.key, required this.spieler});

  @override
  State<SpielerPferderennenModal> createState() => _SpielerPferderennenModalState();
}

class _SpielerPferderennenModalState extends State<SpielerPferderennenModal> {
  TextEditingController nameController = TextEditingController();
  TextEditingController schluckeController = TextEditingController();
  String zeichenAuswahl = '';
  String nameEingabe = '';
  int schluckeEingabe = 1;

  void handleOptionChanged(String option) {
    setState(() {
      zeichenAuswahl = option;
    });
  }

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
                      style:
                          TextStyle(fontSize: 22, color: colors.teal, fontWeight: FontWeight.w800)),
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
                        background: Container(color: Colors.red, child: const Padding(
                          padding: EdgeInsets.only(right: 15.0),
                          child: Align(alignment: Alignment.centerRight, child: Icon(Icons.delete)),
                        ),),
                        child: Container(
                          color: bgColor,
                          child: ListTile(
                              title: Text(
                                  '${spieler.name} wettet ${spieler.schlucke} Schluck/e auf ${spieler.zeichen}')),
                        ),
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
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  controller: schluckeController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter
                        .digitsOnly,
                    LengthLimitingTextInputFormatter(2), // Allow only numeric input
                  ],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      schluckeEingabe = int.tryParse(value) ?? 1;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Schlucke eingeben...',
                    filled: true, // Set to true to enable background color
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomRadioButtonGroup(
                    options: const ['Herz', 'Kreuz', 'Karo', 'Pik'],
                    zeichenAuswahl: zeichenAuswahl,
                    onChanged: handleOptionChanged),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton(
                      heroTag: 'spieler_pferderennen_add_tag',
                      foregroundColor: Colors.black,
                      backgroundColor: colors.teal,
                      onPressed: () {
                        setState(() {
                          if (nameEingabe.isEmpty) {
                            notify.notifyError(context, 'Kein Name eingegeben');
                          } else if (schluckeEingabe == 0 ||
                              schluckeController.text.isEmpty) {
                            notify.notifyError(context, 'Keine Schlucke eingegeben');
                          } else if (zeichenAuswahl.isEmpty) {
                            notify.notifyError(context, 'Kein Zeichen ausgewählt');
                          } else if (widget.spieler
                              .where((einSpieler) =>
                                  einSpieler.name == nameEingabe)
                              .toList()
                              .isNotEmpty) {
                            notify.notifyError(context, 'Name bereits vergeben');
                          } else {
                            widget.spieler.add(SpielerPferderennen(
                                id: '',
                                name: nameEingabe,
                                schlucke: schluckeEingabe,
                                zeichen: zeichenAuswahl));
                            nameEingabe = '';
                            schluckeEingabe = 1;
                            zeichenAuswahl = '';
                            nameController.clear();
                            schluckeController.clear();
                          }
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      heroTag: 'pferderennen_start_tag',
                      foregroundColor: Colors.black,
                      backgroundColor: colors.teal,
                      onPressed: () {
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

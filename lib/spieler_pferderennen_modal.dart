import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_project/custom_widget.dart';
import 'package:my_flutter_project/model/spieler_class.dart';
import 'package:another_flushbar/flushbar.dart';
import 'assets/colors.dart' as colors;

class SpielerPferderennenModal extends StatefulWidget {
  final List<SpielerPferderennen> spieler;

  const SpielerPferderennenModal({super.key, required this.spieler});

  @override
  _SpielerPferderennenState createState() => _SpielerPferderennenState();
}

class _SpielerPferderennenState extends State<SpielerPferderennenModal> {
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

  void _notifyError(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: colors.red.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
              const Divider(thickness: 1.0,),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: widget.spieler.length,
                  itemBuilder: (context, index) {
                    final spieler = widget.spieler[index];
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${spieler.name} gelöscht')));
                      },
                      background: Container(color: Colors.red, child: const Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Align(alignment: Alignment.centerRight, child: Icon(Icons.delete)),
                      ),),
                      child: ListTile(
                          title: Text(
                              '${spieler.name} wettet ${spieler.schlucke} Schluck/e auf ${spieler.zeichen}')),
                    );
                  },
                ),
              ),
              const Divider(thickness: 1.0,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      nameEingabe = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Name eingeben...',
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
                        .digitsOnly, // Allow only numeric input
                  ],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      schluckeEingabe = int.tryParse(value) ?? 1;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Schlucke eingeben...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              CustomRadioButtonGroup(
                  options: const ['Herz', 'Kreuz', 'Karo', 'Pik'],
                  zeichenAuswahl: zeichenAuswahl,
                  onChanged: handleOptionChanged),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
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
                            _notifyError(context, 'Kein Name eingegeben');
                          } else if (schluckeEingabe == 0 ||
                              schluckeController.text.isEmpty) {
                            _notifyError(context, 'Schlucke eingeben');
                          } else if (zeichenAuswahl.isEmpty) {
                            _notifyError(context, 'Kein Zeichen ausgewählt');
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

import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/bier_button.dart';
import 'package:trinkspielplatz/custom_widget.dart';
import 'dart:math';
import 'package:trinkspielplatz/deck_utils.dart';
import 'package:trinkspielplatz/model/cards_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Karten extends StatefulWidget {
  const Karten({ super.key });

  @override
  State<Karten> createState() => _KartenState();
}

class _KartenState extends State<Karten> with RouteAware {
  var notification = Notify();
  int n = 0;
  List<Cards> deck = [];

  final random = Random();

  bool started = false;
  List<String> optionsZeichen = ['Herz', 'Kreuz', 'Karo', 'Pik'];
  List<String> optionsZahl = ['2-6', '7-10', 'Bube-Ass'];
  List<String> selectedOptionsZeichen = ['Herz', 'Kreuz', 'Karo', 'Pik'];
  List<String> selectedOptionsZahl = [
    '2-6',
    '7-10',
    'Bube-Ass'
  ]; // Initialize with options selected
  List<String> pendingOptionsZeichen = ['Herz', 'Kreuz', 'Karo', 'Pik'];
  List<String> pendingOptionsZahl = ['2-6', '7-10', 'Bube-Ass'];

  

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kartenauswahl'),
          content: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Zeichen'),
                      ),
                      CustomMultiSelectRadio(
                        options: optionsZeichen,
                        selectedOptions: selectedOptionsZeichen,
                        onChanged: (List<String> newSelectedOptionsZeichen) {
                          setState(() {
                            pendingOptionsZeichen = newSelectedOptionsZeichen;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Zahlen'),
                      ),
                      CustomMultiSelectRadio(
                        options: optionsZahl,
                        selectedOptions: selectedOptionsZahl,
                        onChanged: (List<String> newSelectedOptionsZahl) {
                          setState(() {
                            pendingOptionsZahl = newSelectedOptionsZahl;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedOptionsZeichen = pendingOptionsZeichen;
                  selectedOptionsZahl = pendingOptionsZahl;
                  n = 0;
                  started = false;
                  deck = _filterDeck();
                });
                Navigator.pop(context);
              },
              child: const Text('Speichern'),
            )
          ],
        );
      },
    );
  }

  List<Cards> _filterDeck() {
    List<Cards> deckFiltered = createDeck();
    if (!selectedOptionsZeichen.contains('Herz')) {
      deckFiltered =
          deckFiltered.where((card) => card.zeichen != 'herz').toList();
    }
    if (!selectedOptionsZeichen.contains('Kreuz')) {
      deckFiltered =
          deckFiltered.where((card) => card.zeichen != 'kreuz').toList();
    }
    if (!selectedOptionsZeichen.contains('Karo')) {
      deckFiltered =
          deckFiltered.where((card) => card.zeichen != 'karo').toList();
    }
    if (!selectedOptionsZeichen.contains('Pik')) {
      deckFiltered =
          deckFiltered.where((card) => card.zeichen != 'pik').toList();
    }

    if (!selectedOptionsZahl.contains('2-6')) {
      deckFiltered = deckFiltered.where((card) => card.value > 6).toList();
    }
    if (!selectedOptionsZahl.contains('7-10')) {
      deckFiltered = deckFiltered
          .where((card) => card.value < 7 || card.value > 10)
          .toList();
    }
    if (!selectedOptionsZahl.contains('Bube-Ass')) {
      deckFiltered = deckFiltered.where((card) => (card.value < 11)).toList();
    }
    deckFiltered.shuffle();
    return deckFiltered;
  }

  void _naechsteKarte() {
    setState(() {
      if (started) {
        if (n < deck.length - 1) {
          n++;
        } else {
          n = 0;
          deck.shuffle();
        }
      } else {
        started = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Karten"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black,
            actions: [
              AnleitungenButton()
              // You can add more icons here if needed
            ]),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    //height: 500,
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: const BorderSide(
                                width: 10, color: colors.teal))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const BierButton(),
                                  FloatingActionButton(
                                    heroTag: 'settings_wuerfel_tag',
                                    foregroundColor: Colors.black,
                                    backgroundColor: colors.teal,
                                    onPressed: () {
                                      _showSettingsDialog(context);
                                    },
                                    child: const Icon(Icons.settings),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      key: ValueKey<int>(deck[n].id),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.33,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.4), // Shadow color and opacity
                                            spreadRadius:
                                                2, // How far the shadow spreads
                                            blurRadius:
                                                5, // The blur radius of the shadow
                                            offset: const Offset(0,
                                                3), // Offset of the shadow (x, y)
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        started
                                            ? 'images/cards/${deck[n].card}.png'
                                            : 'images/cards/back2.png',
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 8.0),
                AnimatedButton(
                    width: (MediaQuery.of(context).size.width * 0.95),
                    color: colors.teal,
                    onPressed: () {
                      _naechsteKarte();
                    },
                    child: const Text(strings.naechsteKarte)),
                const AdScreen()
              ],
            ),
          ),
        ));
  }
}

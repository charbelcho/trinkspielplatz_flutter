import 'package:flutter/material.dart';
import 'dart:math';
import 'package:my_flutter_project/deck_utils.dart';
import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class KingsCup extends StatefulWidget {
  const KingsCup({Key? key}) : super(key: key);

  @override
  _KingsCupState createState() => _KingsCupState();
}

class _KingsCupState extends State<KingsCup> {
  int n = 0;
  List<Cards> deck = [];

  final random = Random();

  String text = '';
  bool started = false;

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
    Future.delayed(const Duration(milliseconds: 500), () {
      _showStartDialog(context);
    });
  }

  void _showStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Spielstart'),
          content: const Text(
              'Ihr braucht zum Spielen ein weiteres Glas als King\'s Cup'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Start'),
            )
          ],
        );
      },
    );
  }

  void _showWasserfallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erklärung'),
          content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                  '''Setzt alle zum Trinken an. Es darf erst abgesetzt werden, wenn der rechte Sitznachbar abgesetzt hat. Wer dass Ass gezogen hat, darf zuerst absetzen''')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Verstanden!'),
            )
          ],
        );
      },
    );
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
        //text = _setText();
      } else {
        started = true;
      }
      text = _setText();
    });
  }

  String _setText() {
    switch (deck[n].value) {
      case 2:
        return 'Verteile ${random.nextInt(6) + 2} Schlucke';
      case 3:
        return 'Trinke ${random.nextInt(6) + 2} Schlucke';
      case 4:
        return 'Wer zuletzt den Boden berührt, trinkt ${random.nextInt(6) + 2} Schlucke';
      case 5:
        return 'Wer zuletzt den Daumen auf den Tisch legt, trinkt ${random.nextInt(6) + 2} Schlucke';
      case 6:
        return 'Alle Frauen trinken ${random.nextInt(6) + 2} Schlucke';
      case 7:
        return 'Wer zuletzt die Hand hebt, trinkt ${random.nextInt(6) + 2} Schlucke';
      case 8:
        return 'Wähle einen Trinkpartner, er/sie trinkt wenn du trinkst';
      case 9:
        return 'Beginne mit einem Wort, die Mitspieler nennen Reimwörter, der Verlierer trinkt ${random.nextInt(6) + 2} Schlucke';
      case 10:
        return 'Alle Männer trinken ${random.nextInt(6) + 2} Schlucke';
      case 11:
        return 'Erstelle eine Spielregel, alte Regeln können nicht außer Kraft gesetzt werden';
      case 12:
        return 'Spielt "Ich hab noch nie.."';
      case 13:
        return 'Kippe ein Getränk deiner Wahl in den King\'s Cup';
      case 14:
        return 'Wasserfall';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("King's Cup"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Container(
                  height: 500,
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side:
                              const BorderSide(width: 10, color: colors.teal))),
                  child: Center(
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
                          child: Image.asset(
                            started
                                ? 'images/cards/${deck[n].card}.png'
                                : 'images/cards/back2.png',
                            key: ValueKey<int>(deck[n].id),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 70,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        constraints: BoxConstraints(
                                          maxWidth: deck[n].value != 14
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                        ),
                                        child: SizedBox(
                                          height: 70,
                                          child: Center(
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              transitionBuilder:
                                                  (child, animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              child: Text(text,
                                                  key: ValueKey<String>(text),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        )),
                                    if (started && deck[n].value == 14)
                                      IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: () {
                                            _showWasserfallDialog(context);
                                          }),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.95),
                        color: colors.teal,
                        onPressed: () {
                          _naechsteKarte();
                        },
                        child: const Text(strings.naechsteKarte))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

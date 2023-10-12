import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'dart:math';
import 'package:trinkspielplatz/deck_utils.dart';
import 'package:trinkspielplatz/model/cards_class.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class KingsCup extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;
  const KingsCup({Key? key, required this.observer}) : super(key: key);

  @override
  State<KingsCup> createState() => _KingsCupState();
}

class _KingsCupState extends State<KingsCup> with RouteAware {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int n = 0;
  List<Cards> deck = [];

  final random = Random();

  String text = '';
  bool started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
    Future.delayed(const Duration(milliseconds: 500), () {
      _showStartDialog(context);
    });
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    analytics.setCurrentScreen(
      screenName: '/kings_cup',
    );
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
    double screenWidth = MediaQuery.of(context).size.width;
    double varFontSize;

    // Calculate font size based on screen width
    if (screenWidth < 300) {
      varFontSize = 12.0;
    } else if (screenWidth < 325) {
      varFontSize = 13.0;
    } else if (screenWidth < 350) {
      varFontSize = 14.0;
    } else if (screenWidth < 375) {
      varFontSize = 15.0;
    } else if (screenWidth < 400) {
      varFontSize = 16.0;
    } else {
      varFontSize = 18.0;
    }

    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("King's Cup"),
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
                              height: MediaQuery.of(context).size.height * 0.33,
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
                                    offset: const Offset(
                                        0, 3), // Offset of the shadow (x, y)
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                started
                                    ? 'images/cards/${deck[n].card}.png'
                                    : 'images/cards/back2.png',
                              ),
                            )),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Stack(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.7,
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          transitionBuilder: (child, animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                          child: Text(text,
                                              key: ValueKey<String>(text),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: varFontSize,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    if (started && deck[n].value == 14)
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              icon: const Icon(Icons.info_outline),
                                              onPressed: () {
                                                _showWasserfallDialog(context);
                                              }),
                                        ),
                                      ),
                                  ],
                                ),
                              ]),
                        ),
                      ],
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

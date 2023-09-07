import 'package:flutter/material.dart';
import 'package:my_flutter_project/deck_utils.dart';
import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class CaptainShithead extends StatefulWidget {
  const CaptainShithead({Key? key}) : super(key: key);

  @override
  _CaptainShitheadState createState() => _CaptainShitheadState();
}

class _CaptainShitheadState extends State<CaptainShithead> {
  int n = 0;
  List<Cards> deck = [];

  String text = '';
  bool started = false;
  bool? correct;
  int correctInRow = 0;

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
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
        text = _setText();
      } else {
        started = true;
        text = _setText();
      }
    });
  }

  bool between(int start, int value, int end) {
    if (start < value && value < end) {
      return true;
    }
    return false;
  }

  String _setText() {
    if (deck[n].colour == "rot" && between(0, deck[n].value, 11)) {
      return "Verteile ${deck[n].value} Schlucke\n";
    } else if (deck[n].colour == "schwarz" && between(0, deck[n].value, 11)) {
      return "Trinke ${deck[n].value} Schlucke\n";
    } else if (deck[n].value == 11) {
      return "Alle Männer trinken\n5 Schlucke";
    } else if (deck[n].value == 12) {
      return "Alle Frauen trinken\n5 Schlucke";
    } else if (deck[n].value == 13) {
      return "Du bist Captain Shithead\n";
    } else if (deck[n].value == 14) {
      return "Du bist vor Captain\nShithead geschützt";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Captain Shithead"),
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
                      const SizedBox(height: 8.0),
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Image.asset(started
                              ? 'images/cards/${deck[n].card}.png'
                              : 'images/cards/back2.png', key: ValueKey<int>(deck[n].id),)),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
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
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  key: ValueKey<String>(text),
                                ),
                              )
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

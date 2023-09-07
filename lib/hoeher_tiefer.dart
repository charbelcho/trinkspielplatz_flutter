import 'package:flutter/material.dart';
import 'package:my_flutter_project/deck_utils.dart';
import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;

class HoeherTiefer extends StatefulWidget {
  const HoeherTiefer({Key? key}) : super(key: key);

  @override
  _HoeherTieferState createState() => _HoeherTieferState();
}

class _HoeherTieferState extends State<HoeherTiefer> {
  int n = 0;
  List<Cards> deck = [];

  bool? correct;
  int correctInRow = 0;

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
  }

  void _correctFunc() {
    if (correctInRow == 3) {
      correctInRow = 0;
    }
    correct = true;
    correctInRow += 1;
  }

  void _notCorrectFunc() {
    if (correctInRow == 3) {
      correctInRow = 0;
    }
    correct = false;
    correctInRow = 0;
  }

  void _hoeher() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value < deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value < deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  void _gleich() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value == deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value == deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  void _tiefer() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value > deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value > deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Höher oder Tiefer?"),
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
                        child: Image.asset(
                          'images/cards/${deck[n].card}.png',
                          key: ValueKey<int>(deck[n].id),
                        ),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                child: Opacity(
                                    key: ValueKey(correct),
                                    opacity: correct != null ? 1.0 : 0.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: ShapeDecoration(
                                          color: correct == true
                                              ? correct == false
                                                  ? Colors.transparent
                                                  : colors.green
                                              : colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0))),
                                      child: Text(
                                          correct == true
                                              ? correct == false
                                                  ? ''
                                                  : 'Richtig'
                                              : 'Falsch',
                                          style: const TextStyle(fontSize: 18)),
                                    )),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                child: Text("Richtig in Folge: $correctInRow",
                                    // This key causes the AnimatedSwitcher to interpret this as a "new"
                                    // child each time the count changes, so that it will begin its animation
                                    // when the count changes.
                                    key: ValueKey<int>(correctInRow),
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ]),
                      ),
                      Text(correctInRow == 3 ? 'Nächster Spieler' : '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.28),
                        color: colors.teal,
                        onPressed: () {
                          _hoeher();
                        },
                        child: const Icon(Icons.arrow_upward)),
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.28),
                        color: colors.teal,
                        onPressed: () {
                          _gleich();
                        },
                        child: const Text("=",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              //fontWeight: FontWeight.w500,
                            ))),
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.28),
                        color: colors.teal,
                        onPressed: () {
                          _tiefer();
                        },
                        child: const Icon(Icons.arrow_downward))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
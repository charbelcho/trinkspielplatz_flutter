import 'package:flutter/material.dart';
import 'package:my_flutter_project/anleitungen.dart';
import 'package:my_flutter_project/deck_utils.dart';
import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/flip_card.dart';
import 'package:my_flutter_project/model/spieler_class.dart';
import 'package:my_flutter_project/spieler_pferderennen_modal.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'dart:math';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Pferderennen extends StatefulWidget {
  const Pferderennen({super.key});

  @override
  State<Pferderennen> createState() => _PferderennenState();
}

class _PferderennenState extends State<Pferderennen>
    with TickerProviderStateMixin {
  late List<AnimationController> animationControllers;

  final random = Random();
  List<SpielerPferderennen> spielerPferderennen = [];

  int n = 0;
  List<Cards> deck = [];
  List<Cards> deckVerdeckt = [];
  bool started = false;

  int position1 = 0;
  int position2 = 0;
  int position3 = 0;
  int position4 = 0;

  @override
  void initState() {
    super.initState();

    deck = createDeckPferderennen(createDeck());
    deck.shuffle();
    deckVerdeckt = deck.sublist(0, 7);
    deck = deck.sublist(7);

    animationControllers = List.generate(
      7,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
    );

    for (var controller in animationControllers) {
      controller.value = 1.0;
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              SpielerPferderennenModal(spieler: spielerPferderennen),
        ),
      );
    });
  }

  void _naechsteKarte() {
    if (spielerPferderennen.length > 1) {
      setState(() {
        if (started) {
          if (n < deck.length - 1) {
            n++;
            _setCards();
            _checkPosition();
          }
        } else {
          started = true;
          _setCards();
          _checkPosition();
        }
      });
    }
  }

  void _setCards() {
    setState(() {
      switch (deck[n].zeichen) {
        case "herz":
          position1 += 1;
          break;
        case "kreuz":
          position2 += 1;
          break;
        case "karo":
          position3 += 1;
          break;
        case "pik":
          position4 += 1;
          break;
        default:
          break;
      }
    });
  }

  void _checkPosition() {
    setState(() {
      List<int> positionArray = [position1, position2, position3, position4];
      int minValue =
          positionArray.reduce((min, current) => current < min ? current : min);
      int winner = positionArray.indexWhere((element) => element == 8);
      String zeichen = '';

      switch (minValue) {
        case 1:
          if (animationControllers[0].value > 0.5) {
            _goBack(0);
            animationControllers[0].reverse();
          }
          break;
        case 2:
          if (animationControllers[1].value > 0.5) {
            _goBack(1);
            animationControllers[1].reverse();
          }
          break;
        case 3:
          if (animationControllers[2].value > 0.5) {
            _goBack(2);
            animationControllers[2].reverse();
          }
          break;
        case 4:
          if (animationControllers[3].value > 0.5) {
            _goBack(3);
            animationControllers[3].reverse();
          }
          break;
        case 5:
          if (animationControllers[4].value > 0.5) {
            _goBack(4);
            animationControllers[4].reverse();
          }
          break;
        case 6:
          if (animationControllers[5].value > 0.5) {
            _goBack(5);
            animationControllers[5].reverse();
          }
          break;
        case 7:
          if (animationControllers[6].value > 0.5) {
            _goBack(6);
            animationControllers[6].reverse();
          }
          break;
        default:
          break;
      }

      Map<String, List<SpielerPferderennen>> result = {'': []};

      switch (winner) {
        case 0:
          result = _setWinnerLoser('Herz');
          zeichen = 'Herz';
          break;
        case 1:
          result = _setWinnerLoser('Kreuz');
          zeichen = 'Kreuz';
          break;
        case 2:
          result = _setWinnerLoser('Karo');
          zeichen = 'Karo';
          break;
        case 3:
          result = _setWinnerLoser('Pik');
          zeichen = 'Pik';
          break;
        default:
          break;
      }

      if (winner != -1) {
        _showDialogWinner(
            context, result['winner']!, result['loser']!, zeichen);
      }
    });
  }

  Map<String, List<SpielerPferderennen>> _setWinnerLoser(String zeichen) {
    return {
      'winner': spielerPferderennen
          .where((spieler) => spieler.zeichen == zeichen)
          .toList(),
      'loser': spielerPferderennen
          .where((spieler) => spieler.zeichen != zeichen)
          .toList(),
    };
  }

  void _goBack(int x) {
    String zeichen = '';
    setState(() {
      switch (deck[x].zeichen) {
        case "herz":
          position1 -= 1;
          zeichen = 'Herz';
          break;
        case "kreuz":
          position2 -= 1;
          zeichen = 'Kreuz';
          break;
        case "karo":
          position3 -= 1;
          zeichen = 'Karo';
          break;
        case "pik":
          position4 -= 1;
          zeichen = 'Pik';
          break;
        default:
          break;
      }
    });
    _showDialogStrafe(
        context,
        spielerPferderennen
            .where((spieler) => spieler.zeichen == zeichen)
            .toList(),
        zeichen,
        random.nextInt(5) + 3);
  }

  void _neustart() {
    setState(() {
      n = 0;

      deck = createDeckPferderennen(createDeck());
      deck.shuffle();
      deckVerdeckt = deck.sublist(0, 7);
      deck = deck.sublist(7);

      animationControllers = List.generate(
        7,
        (index) => AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        ),
      );

      for (var controller in animationControllers) {
        controller.value = 1.0;
      }

      position1 = 0;
      position2 = 0;
      position3 = 0;
      position4 = 0;
      started = false;

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                SpielerPferderennenModal(spieler: spielerPferderennen),
          ),
        );
      });
    });
  }

  void _showDialogStrafe(BuildContext context,
      List<SpielerPferderennen> spieler, String zeichen, int trinkanzahl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stafe für $zeichen'),
          content: Container(
            width: double.minPositive,
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              itemCount: spieler.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${spieler[index].name} trinkt $trinkanzahl Schluck/e'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Trink!'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogWinner(BuildContext context, List<SpielerPferderennen> winner,
      List<SpielerPferderennen> loser, String zeichen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$zeichen hat gewonnen'),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: winner.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            '${winner[index].name} verteilt ${winner[index].schlucke}  Schluck/e'),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: loser.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            '${loser[index].name} trinkt seine ${loser[index].schlucke * 2}  Schluck/e'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _neustart();
                Navigator.pop(context);
              },
              child: const Text('Neustart!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Pferderennen"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black,
            actions: [
              AnleitungenButton()
              // You can add more icons here if needed
            ]),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 350.0,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side:
                              const BorderSide(width: 10, color: colors.teal))),
                  child: Center(
                      child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.settings, color: Colors.grey,), // Icon to be displayed
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SpielerPferderennenModal(
                                          spieler: spielerPferderennen),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[6],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[6].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[5],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[5].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[4],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[4].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[3],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[3].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[2],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[2].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[1],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[1].card : 'herz2'}.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: FlipCardReverse(
                                      animationReverseController:
                                          animationControllers[0],
                                      frontChild: Image.asset(
                                          'images/cards/${deck.isNotEmpty ? deckVerdeckt[0].card : 'herz2'}.png'))),
                              const SizedBox(height: 60, width: 40)
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 7 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 6 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 5 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 4 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 3 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 2 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 1 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position1 == 0 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/herza.png')))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 7 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 6 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 5 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 4 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 3 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 2 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 1 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position2 == 0 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/kreuza.png')))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 7 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 6 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 5 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 4 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 3 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 2 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 1 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position3 == 0 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/karoa.png')))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 7 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 6 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 5 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 4 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 3 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 2 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 1 ? 1.0 : 0.0,
                                      child: Image.asset(
                                          'images/cards/pika.png'))),
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      opacity: position4 == 0 ? 1.0 : 0.0,
                                      child:
                                          Image.asset('images/cards/pika.png')))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 40,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                          opacity: animation, child: child);
                                    },
                                    child: Image.asset(
                                        'images/cards/${started ? deck[n].card : 'back2'}.png',
                                        key: ValueKey<int>(deck[n].id)),
                                  )),
                              const SizedBox(
                                height: 60,
                                width: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                AnimatedButton(
                  width: (MediaQuery.of(context).size.width * 0.95),
                  color: colors.teal,
                  onPressed: () {
                    //_showOverlay(context);
                    _naechsteKarte();
                  },
                  child: const Text(
                    strings.naechsteKarte,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

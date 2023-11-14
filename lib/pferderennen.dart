import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/deck_utils.dart';
import 'package:trinkspielplatz/model/cards_class.dart';
import 'package:trinkspielplatz/flip_card.dart';
import 'package:trinkspielplatz/model/spieler_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:trinkspielplatz/pferderennen_card.dart';
import 'package:trinkspielplatz/spieler_pferderennen_modal.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'dart:math';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Pferderennen extends StatefulWidget {
  const Pferderennen({super.key});

  @override
  State<Pferderennen> createState() => _PferderennenState();
}

class _PferderennenState extends State<Pferderennen>
    with TickerProviderStateMixin, RouteAware {
  late List<AnimationController> animationControllers;

  final random = Random();
  List<SpielerPferderennen> spielerPferderennen = [];

  bool loading = true;
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
      setState(() {
        loading = false;
      });
      _openSpielerDialog();
    });
  }

  List<Widget> generateVerdeckt() {
    List<Widget> verdecktPferderennenCards = [];

    for (int i = 6; i >= 0; i--) {
      verdecktPferderennenCards.add(
        PferderennenCardVerdeckt(
            width: 40,
            childWidget: FlipCardReverse(
                animationReverseController: animationControllers[i],
                frontChild: Image.asset(
                    'images/cards/${deck.isNotEmpty ? deckVerdeckt[i].card : 'herz2'}.png'))),
      );
    }
    verdecktPferderennenCards.add(const SizedBox(height: 60, width: 40));
    return verdecktPferderennenCards;
  }

  List<Widget> generateHerzA() {
    List<Widget> herzPferderennenCards = [];

    for (int i = 7; i >= 0; i--) {
      herzPferderennenCards.add(PferderennenCard(
          width: 40,
          visible: position1 == i,
          childWidget: Image.asset('images/cards/herza.png')));
    }
    return herzPferderennenCards;
  }

  List<Widget> generateKreuzA() {
    List<Widget> kreuzPferderennenCards = [];

    for (int i = 7; i >= 0; i--) {
      kreuzPferderennenCards.add(PferderennenCard(
          width: 40,
          visible: position2 == i,
          childWidget: Image.asset('images/cards/kreuza.png')));
    }
    return kreuzPferderennenCards;
  }

  List<Widget> generateKaroA() {
    List<Widget> karoPferderennenCards = [];

    for (int i = 7; i >= 0; i--) {
      karoPferderennenCards.add(PferderennenCard(
          width: 40,
          visible: position3 == i,
          childWidget: Image.asset('images/cards/karoa.png')));
    }
    return karoPferderennenCards;
  }

  List<Widget> generatePikA() {
    List<Widget> pikPferderennenCards = [];

    for (int i = 7; i >= 0; i--) {
      pikPferderennenCards.add(PferderennenCard(
          width: 40,
          visible: position4 == i,
          childWidget: Image.asset('images/cards/pika.png')));
    }
    return pikPferderennenCards;
  }

  void _openSpielerDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            SpielerPferderennenModal(spieler: spielerPferderennen, loading: loading),
      ),
    );
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
    } else {
      notify.notifyError(context, 'Füge mind. 2 Spieler hinzu');
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
      switch (deckVerdeckt[x].zeichen) {
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
        _openSpielerDialog();
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
                  //height: 100,
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
                  //height: 100,
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
    return Stack(
      children: [
        Scaffold(
            backgroundColor: colors.bluegray,
            appBar: AppBar(
                title: const Text("Pferderennen"),
                centerTitle: true,
                backgroundColor: colors.teal,
                foregroundColor: Colors.black,
                actions: [
                  IconButton(
                      onPressed: _openSpielerDialog,
                      icon: const Icon(Icons.settings)),
                  AnleitungenButton()
                  // You can add more icons here if needed
                ]),
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        //height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: const EdgeInsets.all(10.0),
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(
                                    width: 10, color: colors.teal))),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateVerdeckt()),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateHerzA()),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateKreuzA()),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateKaroA()),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generatePikA()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                            opacity: animation, child: child);
                                      },
                                      child: PferderennenCardVerdeckt(
                                          width: 40,
                                          childWidget: Image.asset(
                                            'images/cards/${started ? deck[n].card : 'back2'}.png',
                                          ),
                                          key: ValueKey<int>(deck[n].id))),
                                  const SizedBox(
                                    height: 60,
                                    width: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    AnimatedButton(
                      width: (MediaQuery.of(context).size.width * 0.95),
                      color: colors.teal,
                      onPressed: () {
                        _naechsteKarte();
                      },
                      child: const Text(strings.naechsteKarte),
                    ),
                    const AdScreen()
                  ],
                ),
              ),
            )),
        if (loading)
          Container(
            color:
                Colors.black.withOpacity(0.3), // Semi-transparent overlay color
            child: const Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
          ),
      ],
    );
  }
}

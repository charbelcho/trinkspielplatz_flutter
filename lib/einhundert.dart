import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_flutter_project/model/spieler_class.dart';
import 'package:my_flutter_project/spieler_einhundert_modal.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Einhundert extends StatefulWidget {
  const Einhundert({super.key});

  @override
  State<Einhundert> createState() => _EinhundertState();
}

class _EinhundertState extends State<Einhundert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer timer;
  final random = Random();
  int value1 = 1;
  int n = 0;
  List<Spieler100> spielerEinhundert = [];

  int punkteEnde = 0;

  String text = '';
  String nameFirstSpieler = '';

  bool naechsterSpieler = false;
  bool rolling = false;
  bool textVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duration for the rotation
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.linear)).animate(_controller);

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => SpielerEinhundertModal(
              spieler: spielerEinhundert, setName: _setName),
        ),
      );
    });
  }

  bool _checkEmptySpielerAndPunkte() {
    if (spielerEinhundert.isNotEmpty) {
      if (punkteEnde != spielerEinhundert[n].punkte) {
        return true;
      }
    }
    return false;
  }

  void _setName() {
    if (spielerEinhundert.isNotEmpty) {
      setState(() {
        spielerEinhundert.first.name = spielerEinhundert[0].name;
      });
    }
  }

  void _wuerfeln() {
    if (spielerEinhundert.length > 1) {
      if (!rolling && !naechsterSpieler) {
        setState(() {
          rolling = true;
          textVisible = false;
        });
        _controller.forward(from: 0.0);

        timer = Timer.periodic(const Duration(milliseconds: 1100), (timer) {
          setState(() {
            value1 = random.nextInt(6) + 1;
          });
        });

        // Add a listener to stop the animation when it completes
        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.reset();
            timer.cancel();
            // ignore: invalid_use_of_protected_member
            _controller.clearStatusListeners();
            setState(() {
              value1 = random.nextInt(6) + 1;
              rolling = false;

              if (value1 < 6) {
                if (value1 == 1) {
                  text =
                      'Alle außer dir trinken ${random.nextInt(7) + 1} Schluck/e!';
                  textVisible = true;
                }
                punkteEnde += value1;
                if (punkteEnde >= 100) {
                  Map<String, List<Spieler100>> result = _setWinnerLoser(n);
                  _showDialogWinner(
                      context, result['winner']![0].name, result['loser']!);
                }
              } else if (value1 == 6) {
                text = 'Du trinkst ${random.nextInt(7) + 1} Schluck/e!';
                naechsterSpieler = true;
                textVisible = true;
              }
            });
          }
        });
      }
    }
  }

  Map<String, List<Spieler100>> _setWinnerLoser(int index) {
    return {
      'winner': [spielerEinhundert[index]],
      'loser': spielerEinhundert
          .where((spieler) => spieler != spielerEinhundert[index])
          .toList(),
    };
  }

  void _speichern() {
    setState(() {
      if (!naechsterSpieler) {
        spielerEinhundert[n].punkte = punkteEnde;
        if (n < spielerEinhundert.length - 1) {
          n++;
        } else {
          n = 0;
        }
      } else {
        naechsterSpieler = false;
      }
      punkteEnde = spielerEinhundert[n].punkte;
    });
  }

  void _neustart() {
    setState(() {
      value1 = 1;
      n = 0;
      punkteEnde = 0;
      text = '';
      naechsterSpieler = false;
      rolling = false;
      textVisible = false;

      Future.delayed(const Duration(seconds: 0), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => SpielerEinhundertModal(
                spieler: spielerEinhundert, setName: _setName),
          ),
        );
      });
    });
  }

  void _showDialogWinner(
      BuildContext context, String winner, List<Spieler100> loser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$winner hat gewonnen'),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: loser.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            '${loser[index].name} hat verloren und trinkt ${random.nextInt(7) + 1} Schluck/e'),
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
            title: const Text("100"),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                const Text(
                                  'Am Zug:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(spielerEinhundert.isNotEmpty
                                    ? spielerEinhundert[n].name
                                    : '')
                              ]),
                              Column(children: [
                                const Text(
                                  'Punkte:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(spielerEinhundert.isNotEmpty
                                    ? '${spielerEinhundert[n].punkte}'
                                    : '0'),
                                const Text('aktuell:'),
                                Text('$punkteEnde'),
                              ]),
                            ]),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animation.value *
                                      2 *
                                      3.14159265359, // 2 * Pi
                                  child: InkWell(
                                      onTap: _wuerfeln,
                                      child: Image.asset(
                                          'images/wuerfel/wuerfel-$value1-black.png',
                                          height: 200.0,
                                          width: 200.0)),
                                );
                              },
                            ),
                            SizedBox(
                              height: 40,
                              width: 200,
                              child: Text(textVisible ? text : ''),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Opacity(
                      opacity: ((!rolling && _checkEmptySpielerAndPunkte()) ||
                              naechsterSpieler
                          ? 1.0
                          : 0.0),
                      child: AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.95),
                        color: colors.teal,
                        onPressed: () {
                          _speichern();
                        },
                        child: Text(
                          !naechsterSpieler
                              ? strings.speichern
                              : strings.naechsterSpieler,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

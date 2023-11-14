import 'dart:async';
import 'dart:math';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/bier_button.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Wuerfel extends StatefulWidget {
  
  const Wuerfel({super.key});

  @override
  State<Wuerfel> createState() => _WuerfelState();
}

class _WuerfelState extends State<Wuerfel>
    with TickerProviderStateMixin, RouteAware {
  int n = 0;
  late List<AnimationController> controllerList;
  late List<Animation<double>> animationList;
  late Timer timer;
  final random = Random();
  List<int> valueArr = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
  List<bool> savedArr = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  int anzahlWuerfel = 6;

  final List<String> items = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];

  bool rolling = false;

  @override
  void initState() {
    timer = Timer(const Duration(milliseconds: 1), () {});
    super.initState();

    controllerList = List.generate(
      12,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      ),
    );

    animationList = List.generate(
        12,
        (index) => Tween<double>(
              begin: 0,
              end: 1,
            )
                .chain(CurveTween(curve: Curves.linear))
                .animate(controllerList[index]));
  }

  void _wuerfeln() {
    if (!savedArr.contains(false)) {
      return;
    }
    if (!rolling) {
      setState(() {
        rolling = true;
      });
      timer = Timer.periodic(const Duration(milliseconds: 1100), (timer) {
        setState(() {
          for (var i = 0; i < valueArr.length; i++) {
            if (!savedArr[i]) {
              valueArr[i] = random.nextInt(6) + 1;
            }
          }
        });
      });

      for (var i = 0; i < controllerList.length; i++) {
        if (!savedArr[i]) {
          controllerList[i].forward(from: 0.0);
          controllerList[i].addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controllerList[i].stop();

              setState(() {
                for (var i = 0; i < valueArr.length; i++) {
                  if (!savedArr[i]) {
                    valueArr[i] = random.nextInt(6) + 1;
                  }
                }
              });
            }
          });
        }
      }
      Timer(const Duration(seconds: 3), () {
        setState(() {
          timer.cancel();
          rolling = false;
        });
      });
    }
  }

  void _save(int index) {
    setState(() {
      if (!rolling) {
        savedArr[index] = !savedArr[index];
      }
    });
  }

  void _alleWaehlenEntfernen() {
    if (timer.isActive) {
      timer.cancel();
    }
    setState(() {
      if (!rolling) {
        if (savedArr.contains(false)) {
          for (var i = 0; i < savedArr.length; i++) {
            savedArr[i] = true;
          }
        } else {
          for (var i = 0; i < savedArr.length; i++) {
            savedArr[i] = false;
          }
        }
      }
    });
  }

  void _showSettingsDialog(BuildContext context) {
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: anzahlWuerfel - 1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Anzahl Würfel'),
          content: SizedBox(
            height: 150,
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: scrollController,
              onSelectedItemChanged: (index) {
                setState(() {
                  n = index + 1;
                });
              },
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: CupertinoColors.activeBlue.withOpacity(0.2),
              ),
              children: List<Widget>.generate(
                items.length,
                (int index) {
                  return Center(
                    child: Text(items[index]),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  anzahlWuerfel = n;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Würfel"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (!rolling) {
                  Navigator.pop(context);
                }
              },
            ),
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
                    width: MediaQuery.of(context).size.width * 0.95,
                    //height: 540,
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
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const BierButton(),
                                  SizedBox(
                                    height: 60,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _alleWaehlenEntfernen();
                                      },
                                      style: ButtonStyle(
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                10.0),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.black),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                colors.teal),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                40.0), // Set the border radius here
                                          ),
                                        ),
                                        // Add other button style properties as needed
                                      ),
                                      child: const Text(
                                          strings.alleAuswaehlenEntfernen,
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
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
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AnimatedBuilder(
                                        animation: animationList[0],
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: animationList[0].value *
                                                2 *
                                                3.14159265359, // 2 * Pi
                                            child: InkWell(
                                                onTap: () {
                                                  _save(0);
                                                },
                                                child: Image.asset(
                                                    'images/wuerfel/wuerfel-${valueArr[0]}-${!savedArr[0] ? 'black' : 'green'}.png',
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                          );
                                        },
                                      ),
                                      if (anzahlWuerfel > 1)
                                        AnimatedBuilder(
                                          animation: animationList[1],
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: animationList[1].value *
                                                  2 *
                                                  3.14159265359, // 2 * Pi
                                              child: InkWell(
                                                  onTap: () {
                                                    _save(1);
                                                  },
                                                  child: Image.asset(
                                                      'images/wuerfel/wuerfel-${valueArr[1]}-${!savedArr[1] ? 'black' : 'green'}.png',
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2)),
                                            );
                                          },
                                        ),
                                      if (anzahlWuerfel > 2)
                                        AnimatedBuilder(
                                          animation: animationList[2],
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: animationList[2].value *
                                                  2 *
                                                  3.14159265359, // 2 * Pi
                                              child: InkWell(
                                                  onTap: () {
                                                    _save(2);
                                                  },
                                                  child: Image.asset(
                                                      'images/wuerfel/wuerfel-${valueArr[2]}-${!savedArr[2] ? 'black' : 'green'}.png',
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2)),
                                            );
                                          },
                                        ),
                                    ]),
                                if (anzahlWuerfel > 3)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (anzahlWuerfel > 3)
                                          AnimatedBuilder(
                                            animation: animationList[3],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[3].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(3);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[3]}-${!savedArr[3] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 4)
                                          AnimatedBuilder(
                                            animation: animationList[4],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[4].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(4);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[4]}-${!savedArr[4] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 5)
                                          AnimatedBuilder(
                                            animation: animationList[5],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[5].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(5);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[5]}-${!savedArr[5] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                      ]),
                                if (anzahlWuerfel > 6)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (anzahlWuerfel > 6)
                                          AnimatedBuilder(
                                            animation: animationList[6],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[6].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(6);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[6]}-${!savedArr[6] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 7)
                                          AnimatedBuilder(
                                            animation: animationList[7],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[7].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(7);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[7]}-${!savedArr[7] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 8)
                                          AnimatedBuilder(
                                            animation: animationList[8],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[8].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(8);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[8]}-${!savedArr[8] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                      ]),
                                if (anzahlWuerfel > 9)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (anzahlWuerfel > 9)
                                          AnimatedBuilder(
                                            animation: animationList[9],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[9].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(9);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[9]}-${!savedArr[9] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 10)
                                          AnimatedBuilder(
                                            animation: animationList[10],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[10].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(10);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[10]}-${!savedArr[10] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                        if (anzahlWuerfel > 11)
                                          AnimatedBuilder(
                                            animation: animationList[11],
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: animationList[11].value *
                                                    2 *
                                                    3.14159265359, // 2 * Pi
                                                child: InkWell(
                                                    onTap: () {
                                                      _save(11);
                                                    },
                                                    child: Image.asset(
                                                        'images/wuerfel/wuerfel-${valueArr[11]}-${!savedArr[11] ? 'black' : 'green'}.png',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2)),
                                              );
                                            },
                                          ),
                                      ]),
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
                  enabled: (!rolling || !savedArr.contains(false)),
                  width: (MediaQuery.of(context).size.width * 0.95),
                  color: colors.teal,
                  onPressed: () {
                    setState(() {
                      _wuerfeln();
                    });
                  },
                  child: const Text(
                    strings.wuerfeln,
                  ),
                ),
                const AdScreen()
              ],
            ),
          ),
        ));
  }
}

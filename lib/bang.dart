import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'dart:async';
import 'dart:math';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Bang extends StatefulWidget {
  const Bang({Key? key}) : super(key: key);

  @override
  State<Bang> createState() => _BangState();
}

class _BangState extends State<Bang> with RouteAware {
  late Timer timer;
  late Timer delayedTimer;

  final random = Random();
  bool? timerRunning;
  int seconds = 3;
  int timeSpieler1 = 0;
  int timeSpieler2 = 0;

  @override
  void dispose() {
    timer.cancel();
    delayedTimer.cancel();
    timerRunning = false;
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer(const Duration(milliseconds: 1), () {});
    delayedTimer = Timer(const Duration(milliseconds: 1), () {});
    super.initState();
  }

  void _startTimer() {
    if (timerRunning == null) {
      setState(() {
        timerRunning = true;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds--;
        });
        if (seconds == 1) {
          timer.cancel();
          delayedTimer =
              Timer(Duration(milliseconds: random.nextInt(7000)), () {
            setState(() {
              timerRunning = false;
              _stopTimer();
            });
          });
        }
      });
    }
  }

  void _stopTimer() {
    if (timer.isActive) {
      timer.cancel();
    }
    if (delayedTimer.isActive) {
      delayedTimer.cancel();
    }
  }

  void _resetState() {
    setState(() {
      timerRunning = null;
      seconds = 3;

      timeSpieler1 = 0;
      timeSpieler2 = 0;
    });
  }

  void _showZufruehDialog(
      BuildContext context, int spielerZuFrueh, int randomVerliererTrinkzahl) {
    bool buttonVisible = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Show the AlertDialog
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 3), () {
              // Set the visibility of the button to true after 3 seconds
              setState(() {
                buttonVisible = true;
              });
            });

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: 3.14159265359,
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                            "Spieler $spielerZuFrueh hat zu früh geschossen und trinkt $randomVerliererTrinkzahl Schluck/e!",
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        const Text('Spieler 1'),
                        const SizedBox(height: 8.0),
                        AnimatedButton(
                          enabled: buttonVisible,
                          width: (MediaQuery.of(context).size.width * 0.6),
                          color: colors.teal,
                          onPressed: () {
                            _resetState();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            strings.nochmal,
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
                  const Divider(
                    thickness: 1.0,
                  ),
                  Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Text(
                          "Spieler $spielerZuFrueh hat zu früh geschossen und trinkt $randomVerliererTrinkzahl Schluck/e!",
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      const Text('Spieler 2'),
                      const SizedBox(height: 8.0),
                      AnimatedButton(
                        enabled: buttonVisible,
                        width: (MediaQuery.of(context).size.width * 0.6),
                        color: colors.teal,
                        onPressed: () {
                          _resetState();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          strings.nochmal,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showVerliererDialog(
      BuildContext context, int verlierer, int randomVerliererTrinkzahl) {
    bool buttonVisible = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Show the AlertDialog
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 3), () {
              // Set the visibility of the button to true after 3 seconds
              setState(() {
                buttonVisible = true;
              });
            });

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: 3.14159265359,
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                            "Spieler $verlierer hat verloren und trinkt $randomVerliererTrinkzahl Schluck/e!",
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        const Text('Spieler 1'),
                        const SizedBox(height: 8.0),
                        Opacity(
                          opacity: buttonVisible ? 1.0 : 0.5,
                          child: AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.6),
                            color: colors.teal,
                            onPressed: () {
                              _resetState();

                              Navigator.pop(context);
                            },
                            child: const Text(
                              strings.nochmal,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 1.0,
                  ),
                  Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Text(
                          "Spieler $verlierer hat verloren und trinkt $randomVerliererTrinkzahl Schluck/e!",
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      const Text('Spieler 2'),
                      const SizedBox(height: 8.0),
                      Opacity(
                        opacity: buttonVisible ? 1.0 : 0.5,
                        child: AnimatedButton(
                          width: (MediaQuery.of(context).size.width * 0.6),
                          color: colors.teal,
                          onPressed: () {
                            _resetState();

                            Navigator.pop(context);
                          },
                          child: const Text(
                            strings.nochmal,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _compareTime() {
    int verlierer = 0;
    if (timeSpieler1 > timeSpieler2 && timeSpieler2 > 0) {
      verlierer = 1;
    } else if (timeSpieler2 > 0 && timeSpieler1 == 0) {
      verlierer = 1;
    } else if (timeSpieler2 > timeSpieler1 && timeSpieler1 > 0) {
      verlierer = 2;
    } else if (timeSpieler1 > 0 && timeSpieler2 == 0) {
      verlierer = 2;
    }
    _showVerliererDialog(context, verlierer, random.nextInt(7) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("BANG!"),
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
                    //height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: const BorderSide(
                                width: 10, color: colors.teal))),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.rotate(
                          angle: 3.14159265359,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  timerRunning == true
                                      ? '$seconds'
                                      : timerRunning == false
                                          ? 'BANG!'
                                          : strings.start,
                                  style: const TextStyle(
                                      fontSize: 70,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1),
                              const Text("Spieler 1"),
                              const SizedBox(height: 8.0),
                              AnimatedButton(
                                width:
                                    (MediaQuery.of(context).size.width * 0.85),
                                color: colors.teal,
                                onPressed: () {
                                  if (timerRunning == null) {
                                    _startTimer();
                                  } else if (timerRunning == true) {
                                    _showZufruehDialog(
                                        context, 1, random.nextInt(5) + 1);
                                    _stopTimer();
                                  } else if (timerRunning == false) {
                                    setState(() {
                                      timeSpieler1 =
                                          DateTime.now().millisecondsSinceEpoch;
                                    });
                                    _compareTime();
                                    _stopTimer();
                                  }
                                },
                                child: Text(
                                  seconds != 3 || timerRunning == true
                                      ? strings.bang
                                      : strings.start,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 1.0,
                        ),
                        Column(
                          children: [
                            Text(
                                timerRunning == true
                                    ? '$seconds'
                                    : timerRunning == false
                                        ? 'BANG!'
                                        : strings.start,
                                style: const TextStyle(
                                    fontSize: 70,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1),
                            const Text("Spieler 2"),
                            const SizedBox(height: 8.0),
                            AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.85),
                              color: colors.teal,
                              onPressed: () {
                                if (timerRunning == null) {
                                  _startTimer();
                                } else if (timerRunning == true) {
                                  _showZufruehDialog(
                                      context, 2, random.nextInt(5) + 1);
                                  _stopTimer();
                                } else if (timerRunning == false) {
                                  setState(() {
                                    timeSpieler2 =
                                        DateTime.now().millisecondsSinceEpoch;
                                  });
                                  _compareTime();
                                  _stopTimer();
                                }
                              },
                              child: Text(
                                seconds != 3 || timerRunning == true
                                    ? strings.bang
                                    : strings.start,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
                //SizedBox(height: 20.0,),
                const AdScreen()
              ],
            ),
          ),
        ));
  }
}

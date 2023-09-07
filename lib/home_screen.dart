import 'package:flutter/material.dart';
import 'package:my_flutter_project/bang.dart';
import 'package:my_flutter_project/busfahrer.dart';
import 'package:my_flutter_project/captain_shithead.dart';
import 'package:my_flutter_project/eher.dart';
import 'package:my_flutter_project/einhundert.dart';
import 'package:my_flutter_project/hoeher_tiefer.dart';
import 'package:my_flutter_project/karten.dart';
import 'package:my_flutter_project/kings_cup.dart';
import 'package:my_flutter_project/maexchen.dart';
import 'package:my_flutter_project/noch_nie.dart';
import 'package:my_flutter_project/pferderennen.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'package:my_flutter_project/wahrheit_pflicht.dart';
import 'package:my_flutter_project/wer_bin_ich.dart';
import 'package:my_flutter_project/wuerfel.dart';
import 'assets/colors.dart' as colors;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Trinkspielplatz"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const NochNie();
                            }));
                          },
                          child: const Text(
                            "Ich hab noch nie",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Eher();
                            }));
                          },
                          child: const Text(
                            "Wer würde eher?",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Bang();
                            }));
                          },
                          child: const Text(
                            "BANG!",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Pferderennen();
                            }));
                          },
                          child: const Text(
                            "Pferderennen",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const WerBinIch();
                            }));
                          },
                          child: const Text(
                            "Wer bin ich?",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Maexchen();
                            }));
                          },
                          child: const Text(
                            "Mäxchen",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Wuerfel();
                            }));
                          },
                          child: const Text(
                            "Würfel",
                            style: buttonStyle,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const WahrheitPflicht();
                            }));
                          },
                          child: const Text(
                            "Wahrheit oder Pflicht?",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const HoeherTiefer();
                            }));
                          },
                          child: const Text(
                            "Höher oder Tiefer",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const CaptainShithead();
                            }));
                          },
                          child: const Text(
                            "Captain Shithead",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const KingsCup();
                            }));
                          },
                          child: const Text(
                            "King's Cup",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Busfahrer();
                            }));
                          },
                          child: const Text(
                            "Busfahrer",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Einhundert();
                            }));
                          },
                          child: const Text(
                            "100",
                            style: buttonStyle,
                          ),
                        ),
                        spacer10,
                        AnimatedButton(
                          height: 64,
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return const Karten();
                            }));
                          },
                          child: const Text(
                            "Karten",
                            style: buttonStyle,
                          ),
                        ),
                      ],
                    ),
                  ])),
        ));
  }
}

const buttonStyle = TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.normal,
);

const spacer10 = SizedBox(height: 10.0);

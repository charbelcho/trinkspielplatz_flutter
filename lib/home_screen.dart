import 'package:flutter/material.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/bang.dart';
import 'package:trinkspielplatz/busfahrer.dart';
import 'package:trinkspielplatz/captain_shithead.dart';
import 'package:trinkspielplatz/eher.dart';
import 'package:trinkspielplatz/einhundert.dart';
import 'package:trinkspielplatz/hoeher_tiefer.dart';
import 'package:trinkspielplatz/karten.dart';
import 'package:trinkspielplatz/kings_cup.dart';
import 'package:trinkspielplatz/maexchen.dart';
import 'package:trinkspielplatz/noch_nie.dart';
import 'package:trinkspielplatz/pferderennen.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'package:trinkspielplatz/wahrheit_pflicht.dart';
import 'package:trinkspielplatz/wer_bin_ich.dart';
import 'package:trinkspielplatz/wuerfel.dart';

import 'assets/colors.dart' as colors;

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({
    super.key,
    required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, StatefulWidget> spieleSpalte1 = {
    /* 'Ich hab noch nie': const NochNie(),
    'Wer würde eher?': const Eher(),
    'BANG!': const Bang(),
    'Pferderennen': const Pferderennen(),
    'Wer bin ich?': const WerBinIch(),
    'Mäxchen': const Maexchen(),
    'Würfel': const Wuerfel(), */
  };

  Map<String, StatefulWidget> create() {
    Map<String, StatefulWidget> spiele1 = {
      'Ich hab noch nie': NochNie(),
      'Wer würde eher?': Eher(),
      'BANG!': Bang(),
      'Pferderennen': Pferderennen(),
      'Wer bin ich?': WerBinIch(),
      'Mäxchen': Maexchen(),
      'Würfel': Wuerfel(),
    };
    return spiele1;
  }

  Map<String, StatefulWidget> create2() {
    Map<String, StatefulWidget> spiele2 = {
      'Wahrheit oder Pflicht?': WahrheitPflicht(),
      'Höher oder Tiefer?': HoeherTiefer(),
      'Captain Shithead': CaptainShithead(),
      'King\'s Cup': KingsCup(),
      'Busfahrer': Busfahrer(),
      '100': Einhundert(),
      'Karten': Karten()
    };
    return spiele2;
  }

  final Map<String, StatefulWidget> spieleSpalte2 = {
    /* 'Wahrheit oder Pflicht?': const WahrheitPflicht(),
    'Höher oder Tiefer?': const HoeherTiefer(),
    'Captain Shithead': const CaptainShithead(),
    'King\'s Cup': const KingsCup(),
    'Busfahrer': const Busfahrer(),
    '100': const Einhundert(),
    'Karten': Karten(
      analytics: analytics,
      observer: observer,
    ) */
  };

  @override
  void initState() {
    super.initState();
  }

  List<Widget> spieleListe(
      BuildContext context, Map<String, StatefulWidget> spiele) {
    List<Widget> widgetList = [];
    spiele.forEach((key, value) {
      widgetList.add(AnimatedButton(
        height: 64,
        width: (MediaQuery.of(context).size.width * 0.43),
        color: colors.teal,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return value;
          }));
        },
        child: Text(key, style: buttonStyle, textAlign: TextAlign.center),
      ));
      widgetList.add(spacer10);
    });
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Trinkspielplatz"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black,
            actions: [
              AnleitungenButton()
              // You can add more icons here if needed
            ]),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: spieleListe(context, create())),
                    Column(
                        children:
                            spieleListe(context, create2())),
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

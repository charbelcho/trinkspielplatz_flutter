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
import 'package:firebase_analytics/firebase_analytics.dart';
import 'assets/colors.dart' as colors;

class HomeScreen extends StatefulWidget {
  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  HomeScreen({
    Key? key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

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

  Map<String, StatefulWidget> create(FirebaseAnalyticsObserver observer) {
    Map<String, StatefulWidget> spiele1 = {
      'Ich hab noch nie': NochNie(observer: widget.observer,),
      'Wer würde eher?': Eher(observer: widget.observer,),
      'BANG!': Bang(observer: widget.observer,),
      'Pferderennen': Pferderennen(observer: widget.observer,),
      'Wer bin ich?': WerBinIch(observer: widget.observer,),
      'Mäxchen': Maexchen(observer: widget.observer,),
      'Würfel': Wuerfel(observer: widget.observer,),
    };
    return spiele1;
  }

  Map<String, StatefulWidget> create2(FirebaseAnalyticsObserver observer) {
    Map<String, StatefulWidget> spiele2 = {
      'Wahrheit oder Pflicht?': WahrheitPflicht(observer: widget.observer,),
      'Höher oder Tiefer?': HoeherTiefer(observer: widget.observer,),
      'Captain Shithead': CaptainShithead(observer: widget.observer,),
      'King\'s Cup': KingsCup(observer: widget.observer,),
      'Busfahrer': Busfahrer(observer: widget.observer, analytics: widget.analytics,),
      '100': Einhundert(observer: widget.observer,),
      'Karten': Karten(
        observer: observer,
      )
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

  Future<void> _testResetAnalyticsData() async {
    await widget.analytics.resetAnalyticsData();
    print('resetAnalyticsData succeeded');
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

  Future<void> goToPage(String screenName, String screenClass) async {
    await FirebaseAnalytics.instance
        .logEvent(name: 'Zu $screenName wechseln', parameters: {
      'firebase_screen': screenName,
      'firebase_screen_class': screenClass,
    });
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
                    Column(children: spieleListe(context, create(widget.observer))),
                    Column(
                        children:
                            spieleListe(context, create2(widget.observer))),
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

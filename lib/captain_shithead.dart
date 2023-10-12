import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/deck_utils.dart';
import 'package:trinkspielplatz/model/cards_class.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class CaptainShithead extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;

  const CaptainShithead({Key? key, required this.observer,}) : super(key: key);

  @override
  State<CaptainShithead> createState() => _CaptainShitheadState();
}

class _CaptainShitheadState extends State<CaptainShithead> with RouteAware {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int n = 0;
  List<Cards> deck = [];

  String text = '';
  bool started = false;
  bool? correct;
  int correctInRow = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    deck = createDeck();
    deck.shuffle();
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    analytics.setCurrentScreen(
      screenName: '/captain_shithead',
    );
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
    _logCustomEvent();
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

  void _logCustomEvent() {
    analytics.logEvent(
      name: 'custom_event_name',
      parameters: {
        'parameter_name': 'parameter_value',
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double varFontSize;

    // Calculate font size based on screen width
    if (screenWidth < 300) {
      varFontSize = 12.0;
    } else if (screenWidth < 325) {
      varFontSize = 13.0;
    } else if (screenWidth < 350) {
      varFontSize = 14.0;
    } else if (screenWidth < 375) {
      varFontSize = 15.0;
    } else if (screenWidth < 400) {
      varFontSize = 16.0;
    } else {
      varFontSize = 18.0;
    }

    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Captain Shithead"),
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
                    //height: 500,
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: const BorderSide(
                                width: 10, color: colors.teal))),
                    child: Center(
                        child: Column(
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
                            child: Container(
                              key: ValueKey<int>(deck[n].id),
                              height: MediaQuery.of(context).size.height * 0.33,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.4), // Shadow color and opacity
                                    spreadRadius:
                                        2, // How far the shadow spreads
                                    blurRadius:
                                        5, // The blur radius of the shadow
                                    offset: const Offset(
                                        0, 3), // Offset of the shadow (x, y)
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                started
                                    ? 'images/cards/${deck[n].card}.png'
                                    : 'images/cards/back2.png',
                              ),
                            )),
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
                                    style: TextStyle(
                                        fontSize: varFontSize,
                                        fontWeight: FontWeight.bold),
                                    key: ValueKey<String>(text),
                                  ),
                                )
                              ]),
                        ),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 8.0),
                AnimatedButton(
                    width: (MediaQuery.of(context).size.width * 0.95),
                    color: colors.teal,
                    onPressed: () {
                      _naechsteKarte();
                    },
                    child: const Text(strings.naechsteKarte)),
                const AdScreen(),
              ],
            ),
          ),
        ));
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/logger.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;
import 'model/data_class.dart';

class NochNie extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;

  const NochNie({super.key, required this.observer});

  @override
  State<NochNie> createState() => _NochNieState();
}

class _NochNieState extends State<NochNie> with RouteAware {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int n = 0;
  List<NochNieData> nochnieList = [];
  bool loadingNochnie = true;

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

    fetchData();
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
      screenName: '/noch_nie',
    );
  }

  Future<void> simulateAsyncFunction() async {
    // Simulate an asynchronous operation with a micro-task delay
    await Future.delayed(Duration(seconds: 10));

    // Your "async" code here
    if (mounted) {
      setState(() {
        n = 100;
      });
    }

    print('Async operation completed');
  }

  Future<void> fetchData() async {
    const url =
        'https://trinkspielplatz.herokuapp.com/trinkspiele/nochnie/'; // Replace with your API endpoint URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Data was fetched successfully
        // Convert the JSON response into a list of Car objects
        final List<dynamic> responseData = /*json.decode(response.body);*/
            json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            nochnieList = responseData
                .map((nochnieData) => NochNieData.fromJson(nochnieData))
                .toList();
            nochnieList.shuffle();
          });
        }
      } else {
        // Request failed with an error status code
        logger.e(
            'Requesting Nochnie-Data failed with status: ${response.statusCode}');

        if (mounted) {
          // Or return null, an empty list, or handle the error case accordingly
          notify.notifyError(context, 'Es ist ein Fehler aufgetreten');
        }
      }
    } catch (e) {
      // An error occurred while fetching the data
      logger.e('Error during request from $url:  $e');
      // Or return null, an empty list, or handle the error case accordingly
      if (mounted) {
        notify.notifyError(context, 'Es ist ein Fehler aufgetreten');
      }
    }
    if (mounted) {
      setState(() {
        loadingNochnie = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Ich hab noch nie"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black,
            actions: [
              AnleitungenButton()
              // You can add more icons here if needed
            ]),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Container(
                      height: 400,
                      decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: const BorderSide(
                                  width: 10, color: colors.teal))),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("Ich hab noch nie...",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                      (nochnieList.isEmpty)
                                          ? ''
                                          : nochnieList[n].text,
                                      key: (nochnieList.isEmpty)
                                          ? const ValueKey<int>(0)
                                          : ValueKey<int>(nochnieList[n].id),
                                      style: const TextStyle(fontSize: 20))),
                            )),
                          ],
                        ),
                      )),
                    ),
                    const SizedBox(height: 8.0),
                    AnimatedButton(
                      enabled: nochnieList.isNotEmpty,
                      width: (MediaQuery.of(context).size.width * 0.95),
                      color: colors.teal,
                      onPressed: () {
                        setState(() {
                          if (n < nochnieList.length) {
                            n++;
                          } else {
                            n = 0;
                            nochnieList.shuffle();
                          }
                        });
                      },
                      child: const Text(strings.weiter),
                    ),
                  ],
                ),
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdScreen(),
              ],
            ),
            if (loadingNochnie)
              Container(
                color: Colors.black
                    .withOpacity(0.3), // Background color with opacity
                child: const Center(
                  child:
                      CircularProgressIndicator(), // Replace with your overlay content
                ),
              ),
          ],
        ));
  }
}

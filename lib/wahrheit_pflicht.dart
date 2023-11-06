import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/bier_button.dart';
import 'package:trinkspielplatz/logger.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;
import 'model/data_class.dart';

class WahrheitPflicht extends StatefulWidget {
  const WahrheitPflicht({Key? key}) : super(key: key);

  @override
  State<WahrheitPflicht> createState() => _WahrheitPflichtState();
}

class _WahrheitPflichtState extends State<WahrheitPflicht> with RouteAware {
  int n = 0;
  int m = 0;
  final random = Random();
  List<WahrheitData> wahrheitList = [];
  List<PflichtData> pflichtList = [];
  bool wahrheitVisible = false;
  bool pflichtVisible = false;
  bool loadingWahrheit = true;
  bool loadingPflicht = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    fetchDataWahrheit();
    fetchDataPflicht();
  }

  Future<void> fetchDataWahrheit() async {
    const url =
        'https://trinkspielplatz.herokuapp.com/trinkspiele/wahrheit/'; // Replace with your API endpoint URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Data was fetched successfully
        // Convert the JSON response into a list of Car objects
        final List<dynamic> responseData = /*json.decode(response.body);*/
            json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            wahrheitList = responseData
                .map((wahrheitData) => WahrheitData.fromJson(wahrheitData))
                .toList();
          });
        }
      } else {
        // Request failed with an error status code
        logger.e(
            'Requesting Wahrheit-Data failed with status: ${response.statusCode}');

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
        loadingWahrheit = false;
      });
    }
  }

  Future<void> fetchDataPflicht() async {
    const url =
        'https://trinkspielplatz.herokuapp.com/trinkspiele/pflicht/'; // Replace with your API endpoint URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Data was fetched successfully
        // Convert the JSON response into a list of Car objects
        final List<dynamic> responseData = /*json.decode(response.body);*/
            json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            pflichtList = responseData
                .map((pflichtData) => PflichtData.fromJson(pflichtData))
                .toList();
          });
        }
      } else {
        // Request failed with an error status code
        logger.e(
            'Requesting Pflicht-Data failed with status: ${response.statusCode}');

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
        loadingPflicht = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Wahrheit oder Pflicht?"),
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
                          color: colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: const BorderSide(
                                  width: 10, color: colors.teal))),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!wahrheitVisible && !pflichtVisible) {
                                    n = random.nextInt(wahrheitList.length);
                                    wahrheitVisible = true;
                                  }
                                });
                              },
                              child: AnimatedCrossFade(
                                firstChild: Container(
                                    height: 175,
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        )),
                                    child: Center(
                                      child: Text(wahrheitList.isNotEmpty
                                          ? wahrheitList[n].text
                                          : ''),
                                    )),
                                secondChild: Container(
                                  height: 175,
                                  decoration: ShapeDecoration(
                                      color: colors.bluegray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      )),
                                  child: const Center(
                                      child: Text(
                                    'Wahrheit',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                                crossFadeState: wahrheitVisible
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(seconds: 1),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {
                                setState(() {
                                  if (!wahrheitVisible && !pflichtVisible) {
                                    m = random.nextInt(pflichtList.length);
                                    pflichtVisible = true;
                                  }
                                }),
                              },
                              child: AnimatedCrossFade(
                                firstChild: Container(
                                    height: 175,
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        )),
                                    child: Center(
                                      child: Text(pflichtList.isNotEmpty
                                          ? pflichtList[m].text
                                          : ''),
                                    )),
                                secondChild: Container(
                                  height: 175,
                                  decoration: ShapeDecoration(
                                      color: colors.bluegray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      )),
                                  child: const Center(
                                      child: Text(
                                    'Pflicht',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                                crossFadeState: pflichtVisible
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(seconds: 1),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedButton(
                          width: (MediaQuery.of(context).size.width * 0.75),
                          color: colors.teal,
                          onPressed: () {
                            setState(() {
                              if (wahrheitVisible || pflichtVisible) {
                                wahrheitVisible = false;
                                pflichtVisible = false;
                              }
                            });
                          },
                          child: const Text(strings.weiter),
                        ),
                        const BierButton()
                      ],
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
            if (loadingPflicht || loadingWahrheit)
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

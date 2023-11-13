import 'package:flutter/material.dart';
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class ConnectionErrorWidget extends StatefulWidget {
  final Function() onFloatingButtonPressed;
  final Function() onBackButtonPressed;

  const ConnectionErrorWidget({super.key, required this.onFloatingButtonPressed, required this.onBackButtonPressed});

  @override
  State<ConnectionErrorWidget> createState() => _ConnectionErrorWidgetState();
}

class _ConnectionErrorWidgetState extends State<ConnectionErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
                color: Colors.black
                    .withOpacity(0.3), // Semi-transparent overlay color
                child: Center(
                  child: Stack(
                    children: [
                      DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: null),
                        child: Wrap(
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                              color: Colors.black.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                        strings.verbindungFehlgeschlagen),
                                    const SizedBox(height: 16.0),
                                    FloatingActionButton(
                                      onPressed: widget.onFloatingButtonPressed,
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      child: const Icon(
                                        Icons.autorenew,
                                        size: 45,
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Text(strings.zurueckZuStart),
                                    const SizedBox(height: 16.0),
                                    AnimatedButton(
                                        color: colors.teal,
                                        onPressed: widget.onBackButtonPressed,
                                        child: const Text(strings.zurueck,
                                            style: TextStyle(color: Colors.black))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}

            
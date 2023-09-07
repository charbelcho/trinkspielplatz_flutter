import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_flutter_project/bier_button.dart';
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Maexchen extends StatefulWidget {
  const Maexchen({super.key});

  @override
  State<Maexchen> createState() => _MaexchenState();
}

class _MaexchenState extends State<Maexchen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer timer;
  final random = Random();
  int value1 = 1;
  int value2 = 1;
  int value1Hidden = 1;
  int value2Hidden = 1;
  bool gewuerfelt = false;
  bool rolling = false;
  bool choosed = false;
  bool tipVisible = true;

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
  }

  void _wuerfeln() {
    if (!rolling && !gewuerfelt) {
      setState(() {
        tipVisible = false;
        rolling = true;
      });
      _controller.forward(from: 0.0);

      timer = Timer.periodic(const Duration(milliseconds: 1100), (timer) {
        setState(() {
          value1 = random.nextInt(6) + 1;
          value2 = random.nextInt(6) + 1;
        });
      });

      // Add a listener to stop the animation when it completes
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.stop();
          timer.cancel();
          setState(() {
            value1 = random.nextInt(6) + 1;
            value2 = random.nextInt(6) + 1;
            rolling = false;
            gewuerfelt = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Mäxchen"),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Stack(children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: 
                              BierButton(),
                          ),
                          if (tipVisible)
                            const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(children: [
                                    Text('Tippe zum Würfeln'),
                                    Icon(Icons.arrow_downward)
                                  ])
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
                                        height: 130.0,
                                        width: 130.0)),
                              );
                            },
                          ),
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
                                        'images/wuerfel/wuerfel-$value2-black.png',
                                        height: 130.0,
                                        width: 130.0)),
                              );
                            },
                          ),
                        ]),
                      )
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                !choosed
                    ? Row(
                        children: [
                          AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.95),
                            color: colors.teal,
                            onPressed: () {
                              setState(() {
                                if (gewuerfelt) {
                                  choosed = true;

                                  value1Hidden = value1;
                                  value2Hidden = value2;
                                  value1 = 0;
                                  value2 = 0;
                                }
                              });
                            },
                            child: const Text(
                              strings.naechsterSpieler,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.43),
                            color: colors.green,
                            onPressed: () {
                              setState(() {
                                choosed = false;
                                gewuerfelt = false;
                                value1Hidden = 0;
                                value2Hidden = 0;
                              });
                            },
                            child: const Text(
                              strings.stimmt,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.43),
                            color: colors.red,
                            onPressed: () {
                              setState(() {
                                choosed = false;
                                gewuerfelt = false;
                                value1 = value1Hidden;
                                value2 = value2Hidden;
                              });
                            },
                            child: const Text(
                              strings.stimmtNicht,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
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

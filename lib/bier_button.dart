import 'dart:math';

import 'package:flutter/material.dart';
import 'assets/colors.dart' as colors;

class BierButton extends StatefulWidget {  
  const BierButton({super.key});

  @override
  State<BierButton> createState() => _BierButtonState();
}

class _BierButtonState extends State<BierButton> {
  Random random = Random();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _showBierButtonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text(
              'Trinke ${random.nextInt(7) + 1} Schluck/e', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Trink!'),
            )
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: colors.teal,
      onPressed: () {_showBierButtonDialog(context);},
      child: SizedBox.square(
          dimension: 30.0,
          child: Image.asset(
              'images/biericon/biericon.png')),
    );
  }
}
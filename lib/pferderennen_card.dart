import 'package:flutter/material.dart';

class PferderennenCardVerdeckt extends StatelessWidget {
  final double width;
  final Widget childWidget;

  const PferderennenCardVerdeckt(
      {super.key, required this.width, required this.childWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: width * 1.5,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4), // Shadow color and opacity
              spreadRadius: 2, // How far the shadow spreads
              blurRadius: 5, // The blur radius of the shadow
              offset: const Offset(0, 3), // Offset of the shadow (x, y)
            ),
          ],
        ),
        child: childWidget);
  }
}

class PferderennenCard extends StatelessWidget {
  final double width;
  final bool visible;
  final Widget childWidget;

  const PferderennenCard(
      {super.key,
      required this.width,
      required this.visible,
      required this.childWidget});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1.0 : 0.0,
      child: Container(
          height: width * 1.5,
          width: width,
          decoration: visible
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.4), // Shadow color and opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // The blur radius of the shadow
                      offset: const Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: childWidget),
    );
  }
}

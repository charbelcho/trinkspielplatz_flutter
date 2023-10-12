import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final AnimationController animationController;
  final Widget frontChild;
  final Function(int, int) onButtonPressed;
  final int index;
  final int row;

  const FlipCard(
      {super.key,
      required this.animationController,
      required this.frontChild,
      required this.onButtonPressed,
      required this.index,
      required this.row});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reverse the animation when the widget is tapped
        widget.onButtonPressed(widget.index, widget.row);
      },
      child: AnimatedBuilder(
        animation: widget.animationController,
        builder: (context, child) {
          return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(3.14 * widget.animationController.value), // Rotation
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3), // Shadow color and opacity
                      spreadRadius: 1, // How far the shadow spreads
                      blurRadius: 1, // The blur radius of the shadow
                      offset: const Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: widget.animationController.value < 0.5
                    ? widget.frontChild // Display front content
                    : Image.asset(
                        'images/cards/back2.png')), // Display back content
          );
        },
      ),
    );
  }
}

class FlipCardReverse extends StatefulWidget {
  final AnimationController animationReverseController;
  final Widget frontChild;

  const FlipCardReverse(
      {super.key,
      required this.animationReverseController,
      required this.frontChild});

  @override
  State<FlipCardReverse> createState() => _FlipCardReverseState();
}

class _FlipCardReverseState extends State<FlipCardReverse>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedBuilder(
        animation: widget.animationReverseController,
        builder: (context, child) {
          return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(
                  3.14 * widget.animationReverseController.value), // Rotation
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3), // Shadow color and opacity
                      spreadRadius: 1, // How far the shadow spreads
                      blurRadius: 1, // The blur radius of the shadow
                      offset: const Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: widget.animationReverseController.value < 0.5
                    ? widget.frontChild // Display front content
                    : Image.asset(
                        'images/cards/back2.png')), // Display back content
          );
        },
      ),
    );
  }
}

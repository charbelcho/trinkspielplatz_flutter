import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {  
  final AnimationController animationController; 
  final Widget frontChild;
  final Function(int, int) onButtonPressed;
  final int index;
  final int row;

  const FlipCard({super.key, required this.animationController, required this.frontChild, required this.onButtonPressed, required this.index, required this.row});

  @override
  _FlipCardState createState() => _FlipCardState();
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
            child: widget.animationController.value < 0.5
                ? widget.frontChild// Display front content
                : Image.asset('images/cards/back2.png'), // Display back content
          );
        },
      ),
    );
  }
}


class FlipCardReverse extends StatefulWidget {
  final AnimationController animationReverseController;  
  final Widget frontChild;

  const FlipCardReverse({super.key, required this.animationReverseController, required this.frontChild});

  @override
  _FlipCardReverseState createState() => _FlipCardReverseState();
}

class _FlipCardReverseState extends State<FlipCardReverse>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              ..rotateY(3.14 * widget.animationReverseController.value), // Rotation
            child: widget.animationReverseController.value < 0.5
                ? widget.frontChild// Display front content
                : Image.asset('images/cards/back2.png'), // Display back content
          );
        },
      ),
    );
  }
}
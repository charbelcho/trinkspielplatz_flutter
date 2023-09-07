import 'package:flutter/material.dart';

class FlipAnimation extends StatefulWidget {
  const FlipAnimation({super.key});


  @override
  _FlipAnimationState createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Starts the animation when the widget is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reverse the animation when the widget is tapped
        if (_animationController.isCompleted) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(3.14), // Rotation
            child: _animationController.value < 0.5
                ? Image.asset('images/cards/herz2.png') // Display front content
                : Image.asset('images/cards/back2.png'), // Display back content
          );
        },
      ),
    );
  }
}

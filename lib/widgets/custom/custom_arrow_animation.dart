import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CustomArrowAnimation extends StatefulWidget {
  final double iconHeight;
  final List<String> textList;
  final Color iconColor;
  final Color textColor;
  final ArrowDirection direction;

  const CustomArrowAnimation({
    super.key,
    required this.iconHeight,
    required this.textList,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    this.direction = ArrowDirection.up,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomArrowAnimationState createState() => _CustomArrowAnimationState();
}

enum ArrowDirection { up, down }

class _CustomArrowAnimationState extends State<CustomArrowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: widget.iconHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  0,
                  widget.direction == ArrowDirection.up
                      ? -_animation.value
                      : _animation.value),
              child: Icon(
                widget.direction == ArrowDirection.up
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 30,
                color: widget.iconColor,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 30,
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 16, color: widget.textColor),
            child: AnimatedTextKit(
              animatedTexts: widget.textList.map((text) {
                return TypewriterAnimatedText(text,
                    speed: const Duration(milliseconds: 45));
              }).toList(),
              repeatForever: true,
            ),
          ),
        ),
      ],
    );
  }
}


// Example usage:
/* void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CustomArrowAnimation(
            iconHeight: 20,
            textList: ["Hello", "Flutter", "Animation"],
            iconColor: Colors.blue,
            textColor: Colors.red,
            direction: ArrowDirection.down,
          ),
        ),
      ),
    ),
  );
} */

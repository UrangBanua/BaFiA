import 'package:flutter/material.dart';

class CustomButtonSerapan extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;
  final double borderWidth;
  final double fontSize;
  final String textCaption;

  const CustomButtonSerapan({
    super.key,
    required this.onPressed,
    required this.textCaption,
    this.color = Colors.blue,
    this.borderWidth = 2.0,
    this.fontSize = 20.0,
  });

  @override
  CustomButtonSerapanState createState() => CustomButtonSerapanState();
}

class CustomButtonSerapanState extends State<CustomButtonSerapan>
    with TickerProviderStateMixin {
  late AnimationController _innerCircleController;
  late AnimationController _outerCircleScaleController;
  late AnimationController _outerCircleFadeController;
  late Animation<double> _innerCircleAnimation;
  late Animation<double> _outerCircleScaleAnimation;
  late Animation<double> _outerCircleFadeAnimation;

  @override
  void initState() {
    super.initState();

    _innerCircleController = AnimationController(
      duration: const Duration(milliseconds: 748),
      vsync: this,
    )..repeat(reverse: true);

    _outerCircleScaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _outerCircleFadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _innerCircleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _innerCircleController, curve: Curves.easeInOut),
    );

    _outerCircleScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _outerCircleScaleController, curve: Curves.easeInOut),
    );

    _outerCircleFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _outerCircleFadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _innerCircleController.dispose();
    _outerCircleScaleController.dispose();
    _outerCircleFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          FadeTransition(
            opacity: _outerCircleFadeAnimation,
            child: ScaleTransition(
              scale: _outerCircleScaleAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.color, width: widget.borderWidth),
                ),
              ),
            ),
          ),
          // Inner circle
          ScaleTransition(
            scale: _innerCircleAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: widget.color, width: widget.borderWidth),
              ),
            ),
          ),
          // Text
          Text(
            widget.textCaption,
            style: TextStyle(
              color: widget.color,
              fontSize: widget.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

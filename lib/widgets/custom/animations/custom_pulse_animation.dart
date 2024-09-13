import 'package:flutter/material.dart';
import '../../../views/chat_ai_page.dart';

class CustomPulseButton extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CustomPulseButtonState createState() => _CustomPulseButtonState();
}

class _CustomPulseButtonState extends State<CustomPulseButton> {
  bool _isGifPlaying = false;

  void _onImageTapped() {
    setState(() {
      _isGifPlaying = true;
    });
  }

  void _onImageReleased() {
    Future.delayed(const Duration(seconds: 1), () {
      _showChatDialog();
    });
    setState(() {
      _isGifPlaying = false;
    });
  }

  void _showChatDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return ChatAiPage(); // Use the new ChatDialog class
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onImageTapped(),
      onLongPressEnd: (_) => _onImageReleased(),
      child: Image.asset(
        _isGifPlaying
            ? 'assets/images/menu_press.gif'
            : 'assets/images/menu.gif',
        height: 80,
        width: 80,
      ),
    );
  }
}

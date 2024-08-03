import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bafia/controllers/connectivity_controller.dart';
import 'package:bafia/widgets/custom/custom_button_animation.dart';

void main() {
  runApp(CustomApp());
}

class CustomApp extends StatefulWidget {
  @override
  CustomAppState createState() => CustomAppState();
}

class CustomAppState extends State<CustomApp> {
  bool _isDarkTheme = true;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: MainScreen(toggleTheme: _toggleTheme),
    );
  }
}

class MainScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const MainScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final ConnectivityController controller = Get.put(ConnectivityController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Button Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButtonSerapan(
              onPressed: () {
                _showDialog(context);
              },
              color: Colors.blue,
              borderWidth: 3.0,
              fontSize: 32.0,
              textCaption: 'MULAI',
            ),
            const SizedBox(height: 40),
            // Set Connection Status Text with AnimatedTextKit
            Obx(() => AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      controller.connectionType == MConnectivityResult.wifi
                          ? "Wifi Connected"
                          : controller.connectionType ==
                                  MConnectivityResult.mobile
                              ? 'Mobile Data Connected'
                              : 'No Internet Available',
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.blue),
                      duration: const Duration(milliseconds: 2000),
                    ),
                  ],
                  repeatForever: false,
                )),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dialog Title'),
          content: const Text('This is a custom dialog!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

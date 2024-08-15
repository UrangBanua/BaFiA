import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:bafia/services/tutorial_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Tutorial Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey keyButton1 = GlobalKey();
  final GlobalKey keyButton2 = GlobalKey();
  final TutorialService tutorialService = TutorialService();

  @override
  void initState() {
    super.initState();
    _setupTutorial();
  }

  // Setup tutorial dengan menambahkan target
  void _setupTutorial() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      keyButton1,
      'Ini adalah tombol pertama.',
      title: 'Tombol Pertama', // Title for this target
      align: ContentAlign.top,
      customColor: Colors.blue, // Custom color for this target
      shape: ShapeLightFocus.Circle, // Custom shape for this target
      borderSide: const BorderSide(
          color: Colors.white, width: 1.0), // Custom border for this target
      icon: Icons.looks_one, // Icon for this target
    );
    tutorialService.addTarget(
      keyButton2,
      'Ini adalah tombol kedua.',
      descriptionTextStyle: const TextStyle(color: Colors.green, fontSize: 16),
      title: 'Tombol Kedua', // Title for this target
      align: ContentAlign.right,
      customColor: Colors.red, // Custom color for this target
      shape: ShapeLightFocus.RRect, // Custom shape for this target
      borderSide: const BorderSide(
          color: Colors.black, width: 2.0), // Custom border for this target
      icon: Icons.looks_two, // Icon for this target
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: keyButton1,
              onPressed: () {
                _showTutorial(); // Tampilkan tutorial saat tombol ditekan
              },
              child: const Text('Tombol 1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: keyButton2,
              onPressed: () {
                _showTutorial(); // Tampilkan tutorial saat tombol ditekan
              },
              child: const Text('Tombol 2'),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk menampilkan tutorial
  void _showTutorial() {
    tutorialService.showTutorial(context, onFinish: () {
      print("Tutorial Selesai");
    });
  }
}

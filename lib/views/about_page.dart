import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          Center(
            child: ClipOval(
              child: Image.asset('assets/icons/logo.ico'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                'Aplikasi Asisten Keuangan khususnya untuk Keluarga LKPD Kabupaten Hulu Sungai Tengah'),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                'https://github.com/UrangBanua/BaFiA/releases/tag/pre-release'),
          ),
        ],
      ),
    );
  }
}

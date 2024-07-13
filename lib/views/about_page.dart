import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () async {
                const url =
                    'https://github.com/UrangBanua/BaFiA/releases/tag/pre-release';
                if (await canLaunch(url)) {
                  await launch(
                    url,
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'Cek release versi terbaru disini',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

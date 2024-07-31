import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version: ${packageInfo.version}';
    });
  }

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
                'Aplikasi Asisten Keuangan khususnya untuk keluarga LKPD - Kabupaten Hulu Sungai Tengah',
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _version,
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Linkify(
              text:
                  'Cek release versi terbaru disini\nhttps://github.com/UrangBanua/BaFiA/releases',
              options: const LinkifyOptions(humanize: false),
              onOpen: (link) async {
                FlutterWebBrowser.openWebPage(url: link.url);
              },
            ),
          ),
        ],
      ),
    );
  }
}

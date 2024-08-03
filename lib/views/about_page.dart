import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  String _version = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 4 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version: ${packageInfo.version}';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: GestureDetector(
              onTap: () {
                _controller.forward(from: 0);
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.rotationY(_animation.value),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset('assets/icons/logo.ico'),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                'Aplikasi Asisten Keuangan\nUntuk keluarga LKPD\nKabupaten Hulu Sungai Tengah',
                style: TextStyle(fontSize: 18.0),
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

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/api_service.dart';

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
      _version = 'Versi: ${packageInfo.version}';
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
        title: const Text('Info Aplikasi'),
      ),
      body: ListView(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                _controller.forward(from: 0);
                _showDialogInfo(context);
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

Future<void> _showDialogInfo(context) async {
  var response = await ApiService.getAppReleaseVersion();
  var packageInfo = await PackageInfo.fromPlatform();

  if (response != null) {
    var statusVersi = (response['version'] == packageInfo.version)
        ? 'BaFiA sudah diversi yang terbaru'
        : 'Diperluakan update ke versi ${response['version']}\nuntuk mendapatkan perbaikan bug dan fitur baru :';
    List<TextSpan> featureSpans = [];
    for (var feature in response['features']) {
      featureSpans.add(
        TextSpan(
          text: '\n\n${feature['title']}\n',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
      );
      featureSpans.add(
        TextSpan(
            text: '${feature['description']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.lightBlue[700],
            )),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Informasi'),
            content: RichText(
              text: TextSpan(
                //style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: statusVersi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  ...featureSpans,
                ],
              ),
            ),
            actions: <Widget>[
              if (response['version'] == packageInfo.version)
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              else ...[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Download'),
                  onPressed: () {
                    // Download & Install the latest version of the app
                    FlutterWebBrowser.openWebPage(
                      url: response['url_download_apk'],
                    );
                  },
                ),
              ],
            ]);
      },
    );
  }
}

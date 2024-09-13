import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart'; // Tambahkan ini

class BukuPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _BukuPageState createState() => _BukuPageState();
}

class _BukuPageState extends State<BukuPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Buku Jurnal",
      "description":
          "Akan terlihat Tahapan & Jadwal, klik detail untuk melihat dan approve Anggaran, wajib sebelum approve jurnal yg lainnya!",
      "totalJurnal": "74",
      "totalApprove": "74",
      "imageUrl": 'assets/images/buku_jurnal.png',
      "route": "/akuntansi/buku/jurnal"
    },
    {
      "title": "Buku Besar",
      "description":
          "Lihat detail pendapatan, cek bentuk jurnal dan approve pendapatan, khusus untuk SKPD yang memiliki pendapatan",
      "totalJurnal": "29",
      "totalApprove": "11",
      "imageUrl": 'assets/images/buku_besar.png',
      "route": "/akuntansi/buku/besar"
    },
    {
      "title": "Buku Besar Pembantu",
      "description":
          "Lihat detail belanja, cek bentuk jurnal dan approve belanja",
      "totalJurnal": "304",
      "totalApprove": "224",
      "imageUrl": 'assets/images/buku_besar_pembantu.png',
      "route": "/akuntansi/buku/besar_pembantu"
    },
    {
      "title": "Buku Mutasi Rekening",
      "description":
          "Lihat detail Pembiayaan, cek bentuk jurnal dan approve pembiayaan, khusus untuk PPKD atau yang memiliki pembiayaan",
      "totalJurnal": "3",
      "totalApprove": "3",
      "imageUrl": 'assets/images/buku_mutasi_rekening.png',
      "route": "/akuntansi/mutasi_rekening"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories),
            color: Colors.blue,
            onPressed: () {
              FlutterWebBrowser.openWebPage(
                url:
                    'https://raw.githubusercontent.com/UrangBanua/BaFiA/master/doc/manual_book.pdf', // Ganti dengan URL file PDF
                customTabsOptions: const CustomTabsOptions(
                  instantAppsEnabled: true,
                  showTitle: true,
                  urlBarHidingEnabled: true,
                ),
                safariVCOptions: const SafariViewControllerOptions(
                  barCollapsingEnabled: true,
                  preferredBarTintColor: Colors.blue,
                  preferredControlTintColor: Colors.white,
                  dismissButtonStyle:
                      SafariViewControllerDismissButtonStyle.close,
                  modalPresentationCapturesStatusBarAppearance: true,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Silahkan Pilih\nModul Pembukuan (AKLAP)',
                  textStyle: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                  colors: [Colors.blue, Colors.red, Colors.amber],
                ),
              ],
              isRepeatingAnimation: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return buildCard(
                  _pages[index]["title"]!,
                  _pages[index]["description"]!,
                  _pages[index]["totalJurnal"]!,
                  _pages[index]["totalApprove"]!,
                  _pages[index]["imageUrl"]!,
                  _pages[index]["route"]!,
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: _pages.length,
            effect: const WormEffect(
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              LoggerService.logger.i('Pilih ${_pages[_currentPage]["title"]}');
              Get.toNamed(_pages[_currentPage]["route"]!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              textStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            child: Text("${_pages[_currentPage]["title"]}",
                style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildCard(String title, String description, String totalJurnal,
      String totalApprove, String imageUrl, String route) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (totalJurnal.isNotEmpty && totalApprove.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total Jurnal $totalJurnal",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Sudah Approve $totalApprove",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    imageUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

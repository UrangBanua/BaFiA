import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BaFia',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'BaFia adalah aplikasi pembantu pelaporan keuangan yang menyediakan '
              'berbagai fitur untuk memudahkan pengelolaan data keuangan Anda. '
              'Aplikasi ini dirancang untuk tetap dapat digunakan meskipun sedang offline, '
              'dan akan secara otomatis menyinkronkan data ketika kembali online.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Versi: 1.0.0', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

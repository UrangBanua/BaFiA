import 'package:flutter/material.dart';

class BukuJurnalPage extends StatelessWidget {
  const BukuJurnalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Jurnal'),
      ),
      body: const Center(
        child: Text('Buku Jurnal Page Content'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class JurnalUmumPage extends StatelessWidget {
  const JurnalUmumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Umum Page'),
      ),
      body: const Center(
        child: Text('Jurnal Umum Page Content'),
      ),
    );
  }
}

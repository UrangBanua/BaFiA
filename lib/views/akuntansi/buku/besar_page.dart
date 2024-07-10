import 'package:flutter/material.dart';

class BukuBesarPage extends StatelessWidget {
  const BukuBesarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Besar'),
      ),
      body: const Center(
        child: Text('Buku Besar Page Content'),
      ),
    );
  }
}

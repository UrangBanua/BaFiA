import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List - Keluarga LKPD'),
      ),
      body: const Center(
        child: Text('Task List - Keluarga LKPD Masih Dalam Pengembangan'),
      ),
    );
  }
}

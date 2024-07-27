import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';

class LaporanPage extends StatelessWidget {
  final LaporanController laporanController = Get.put(LaporanController());
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<Map<String, dynamic>>>
      filteredButtonsPenatausahaanRegister = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
      filteredButtonsPenatausahaanLaporan = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
      filteredButtonsAkuntansiLaporan = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
      filteredButtonsAkuntansiPertanggungjawaban = ValueNotifier([]);

  final List<Map<String, dynamic>> buttonsPenatausahaanRegister = [
    {'icon': Icons.request_page, 'text': 'STBP'},
    {'icon': Icons.receipt, 'text': 'STS'},
    {
      'icon': Icons.assignment_add,
      'color': const Color.fromARGB(255, 42, 104, 211),
      'text': 'TBP GU'
    },
    {
      'icon': Icons.request_page,
      'color': const Color.fromARGB(255, 42, 104, 211),
      'text': 'Ajuan TU'
    },
    {'icon': Icons.request_page, 'color': Colors.blue, 'text': 'SPP'},
    {'icon': Icons.payment, 'color': Colors.blue, 'text': 'SPM'},
    {'icon': Icons.receipt, 'color': Colors.blue, 'text': 'SP2D'},
  ];

  final List<Map<String, dynamic>> buttonsPenatausahaanLaporan = [
    {
      'icon': Icons.receipt,
      'text': 'LPJ UP/GU',
      'pageToGo': '/penatausahaan/laporan_pertanggungjawaban/lpj_up_gu'
    },
    {
      'icon': Icons.receipt,
      'text': 'LPJ TU',
      'pageToGo': '/penatausahaan/laporan_pertanggungjawaban/lpj_tu'
    },
    {
      'icon': Icons.receipt,
      'color': Colors.green,
      'text': 'LPJ Admi',
      'pageToGo': '/penatausahaan/laporan_pertanggungjawaban/lpj_administratif'
    },
    {
      'icon': Icons.receipt,
      'color': Colors.green,
      'text': 'LPJ Fung',
      'pageToGo': '/penatausahaan/laporan_pertanggungjawaban/lpj_fungsional'
    },
  ];

  final List<Map<String, dynamic>> buttonsAkuntansiLaporan = [
    {
      'icon': Icons.analytics,
      'text': 'LRA',
      'pageToGo': '/akuntansi/laporan_keuangan/lra'
    },
    {
      'icon': Icons.analytics,
      'text': 'LO',
      'pageToGo': '/akuntansi/laporan_keuangan/lo'
    },
    {
      'icon': Icons.analytics,
      'color': Colors.orange,
      'text': 'LPE',
      'pageToGo': '/akuntansi/laporan_keuangan/lpe'
    },
    {
      'icon': Icons.analytics,
      'color': Colors.orange,
      'text': 'Neraca',
      'pageToGo': '/akuntansi/laporan_keuangan/neraca'
    },
    {
      'icon': Icons.assessment,
      'color': Colors.deepOrangeAccent,
      'text': 'LPSAL'
    },
    {'icon': Icons.assessment, 'color': Colors.deepOrangeAccent, 'text': 'LAK'},
  ];

  final List<Map<String, dynamic>> buttonsAkuntansiPertanggungjawaban = [
    {'icon': Icons.gavel, 'color': Colors.cyan, 'text': 'PERDA'},
    {'icon': Icons.gavel, 'color': Colors.cyan, 'text': 'PERBUP'},
  ];

  LaporanPage() {
    filteredButtonsPenatausahaanRegister.value = buttonsPenatausahaanRegister;
    filteredButtonsPenatausahaanLaporan.value = buttonsPenatausahaanLaporan;
    filteredButtonsAkuntansiLaporan.value = buttonsAkuntansiLaporan;
    filteredButtonsAkuntansiPertanggungjawaban.value =
        buttonsAkuntansiPertanggungjawaban;
    searchController.addListener(_filterButtons);
  }

  void _filterButtons() {
    final query = searchController.text.toLowerCase();
    filteredButtonsPenatausahaanRegister.value =
        buttonsPenatausahaanRegister.where((button) {
      return button['text'].toLowerCase().contains(query);
    }).toList();
    filteredButtonsPenatausahaanLaporan.value =
        buttonsPenatausahaanLaporan.where((button) {
      return button['text'].toLowerCase().contains(query);
    }).toList();
    filteredButtonsAkuntansiLaporan.value =
        buttonsAkuntansiLaporan.where((button) {
      return button['text'].toLowerCase().contains(query);
    }).toList();
    filteredButtonsAkuntansiPertanggungjawaban.value =
        buttonsAkuntansiPertanggungjawaban.where((button) {
      return button['text'].toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Laporan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Panel Cari
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cari Jenis Laporan'),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama register/laporan',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Panel Penatausahaan - Register
            SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Penatausahaan - Register Pendapatan & Belanja',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // tambahkan jarak antara judul dan daftar laporan
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: filteredButtonsPenatausahaanRegister,
                      builder: (context, filteredButtons, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: filteredButtons.map((button) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    backgroundColor: Colors
                                        .transparent, // Set background color to transparent
                                    elevation: 0, // Remove elevation
                                  ),
                                  child: Icon(
                                    button['icon'],
                                    color: button['color'],
                                    size: 36.0,
                                  ),
                                ),
                                Text(button['text']),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Panel Laporan Penatausahaan
            SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Penatausahaan - Laporan Pertanggungjawaban',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // tambahkan jarak antara judul dan daftar laporan
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: filteredButtonsPenatausahaanLaporan,
                      builder: (context, filteredButtons, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: filteredButtons.map((button) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed(button['pageToGo']);
                                    LoggerService.logger
                                        .i('Navigasi ke ${button['pageToGo']}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    backgroundColor: Colors
                                        .transparent, // Set background color to transparent
                                    elevation: 0, // Remove elevation
                                  ),
                                  child: Icon(
                                    button['icon'],
                                    color: button['color'],
                                    size: 36.0,
                                  ),
                                ),
                                Text(button['text']),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Panel Laporan Akuntansi
            SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Akuntansi - Laporan Keuangan',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // tambahkan jarak antara judul dan daftar laporan
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: filteredButtonsAkuntansiLaporan,
                      builder: (context, filteredButtons, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: filteredButtons.map((button) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed(button['pageToGo']);
                                    LoggerService.logger
                                        .i('Navigasi ke ${button['pageToGo']}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    backgroundColor: Colors
                                        .transparent, // Set background color to transparent
                                    elevation: 0, // Remove elevation
                                  ),
                                  child: Icon(
                                    button['icon'],
                                    color: button['color'],
                                    size: 36.0,
                                  ),
                                ),
                                Text(button['text']),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Panel Laporan Akuntansi
            SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Akuntansi - Laporan Pertanggungjawaban',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // tambahkan jarak antara judul dan daftar laporan
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable:
                          filteredButtonsAkuntansiPertanggungjawaban,
                      builder: (context, filteredButtons, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: filteredButtons.map((button) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    /* foregroundColor: Colors.white,
                                    backgroundColor:
                                        Colors.orangeAccent, // Text color
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0), 
                                    ),*/
                                    padding: const EdgeInsets.all(20),
                                    backgroundColor: Colors
                                        .transparent, // Set background color to transparent
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    button['icon'],
                                    color: button['color'],
                                    size: 36.0,
                                  ),
                                ),
                                Text(button['text']),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

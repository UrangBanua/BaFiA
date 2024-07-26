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
    {'icon': Icons.attach_money, 'text': 'STBP'},
    {'icon': Icons.receipt, 'text': 'STS'},
    {'icon': Icons.attach_money, 'text': 'SPP'},
    {'icon': Icons.payment, 'text': 'SPM'},
    {'icon': Icons.receipt, 'text': 'SP2D'},
    {'icon': Icons.account_balance_wallet, 'text': 'TBP GU'},
    {'icon': Icons.request_page, 'text': 'Pengajuan TU'},
  ];

  final List<Map<String, dynamic>> buttonsPenatausahaanLaporan = [
    {'icon': Icons.report, 'text': 'LPJ UP/GU'},
    {'icon': Icons.report, 'text': 'LPJ TU'},
    {'icon': Icons.report, 'text': 'LPJ Administratif'},
    {'icon': Icons.report, 'text': 'LPJ Fungsional'},
  ];

  final List<Map<String, dynamic>> buttonsAkuntansiLaporan = [
    {'icon': Icons.account_balance, 'text': 'LRA'},
    {'icon': Icons.account_balance, 'text': 'LO'},
    {'icon': Icons.account_balance, 'text': 'LPE'},
    {'icon': Icons.account_balance, 'text': 'Neraca'},
    {'icon': Icons.account_balance, 'text': 'LPSAL'},
    {'icon': Icons.account_balance, 'text': 'LAK'},
  ];

  final List<Map<String, dynamic>> buttonsAkuntansiPertanggungjawaban = [
    {'icon': Icons.gavel, 'text': 'PERDA'},
    {'icon': Icons.gavel, 'text': 'PERBUP'},
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Penatausahaan - Register Pendapatan & Belanja'),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: Icon(button['icon']),
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Penatausahaan - Laporan Pertanggungjawaban'),
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
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: Icon(button['icon']),
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Akuntansi - Laporan Keuangan'),
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
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: Icon(button['icon']),
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Akuntansi - Laporan Pertanggungjawaban'),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: Icon(button['icon']),
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

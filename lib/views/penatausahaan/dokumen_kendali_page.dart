import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/penatausahaan/dokumen_kendali_controller.dart';
import '../../services/logger_service.dart'; // Impor LoggerService

class DokumenKendaliPage extends StatefulWidget {
  @override
  _DokumenKendaliPageState createState() => _DokumenKendaliPageState();
}

class _DokumenKendaliPageState extends State<DokumenKendaliPage> {
  final DokumenKendaliController controller =
      Get.put(DokumenKendaliController());
  final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp'); // Define currency format

  @override
  void initState() {
    super.initState();
    controller.fetchKendaliSkpd(); // Fetch kendaliSkpd data at the beginning
  }

  double calculatePercentage(int anggaran, int realisasiRill) {
    if (realisasiRill == 0) return 0;
    return (anggaran / realisasiRill) * 100;
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Penjelasan'),
          content: const Text(
              'Dokumen Kendali ini befungsi untuk memastikan pengajuan realisasi tidak terkendala dalam proses atau hanya lupa dihapus/dibatalkan.\nNilai ini juga termasuk dari jumlah pengembalian belanja'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumen Kendali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support, color: Colors.blueAccent),
            //onPressed: showDialog
            onPressed: _showExplanationDialog,
          ),
        ],
      ),
      body: Obx(() {
        LoggerService.logger.i('Fetching kendaliSkpd data'); // Logging
        if (controller.kendaliSkpd.isEmpty) {
          LoggerService.logger.i('kendaliSkpd is empty'); // Logging
          return const Center(child: CircularProgressIndicator());
        } else {
          LoggerService.logger.i('kendaliSkpd has data'); // Logging
          return ListView.builder(
            itemCount: controller.kendaliSkpd.length,
            itemBuilder: (context, index) {
              var skpd = controller.kendaliSkpd[index];
              double persentase =
                  calculatePercentage(skpd['realisasi_rill'], skpd['anggaran']);
              return ExpansionTile(
                backgroundColor: Colors.blueGrey[100],
                collapsedBackgroundColor: Colors.grey[100],
                title: Text(
                    '${skpd['kode_sub_skpd']} - ${skpd['nama_sub_skpd']} \nAnggaran    : ${currencyFormat.format(skpd['anggaran'])} \nRealisasi     : ${currencyFormat.format(skpd['realisasi_rill'])} \nPersentase : ${persentase.toStringAsFixed(2)}% \nPengajuan  : ${currencyFormat.format(skpd['realisasi_rencana'] - skpd['realisasi_rill'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.black)),
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    LoggerService.logger.i(
                        'Fetching kendaliUrusan data for ${skpd['kode_skpd']}'); // Logging
                    controller.fetchKendaliUrusan(
                        skpd['id_skpd'], skpd['id_sub_skpd']);
                  }
                },
                children: [
                  Obx(() {
                    LoggerService.logger
                        .i('Fetching kendaliUrusan data'); // Logging
                    if (controller.kendaliUrusan.isEmpty) {
                      LoggerService.logger
                          .i('kendaliUrusan is empty'); // Logging
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      LoggerService.logger
                          .i('kendaliUrusan has data'); // Logging
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.kendaliUrusan.length,
                        itemBuilder: (context, index) {
                          var urusan = controller.kendaliUrusan[index];
                          double persentase = calculatePercentage(
                              urusan['realisasi_rill'], urusan['anggaran']);
                          return ExpansionTile(
                            collapsedBackgroundColor: Colors.grey[100],
                            title: Text(
                                '   [ URUSAN ]\n   ${urusan['kode_bidang_urusan']} - ${urusan['nama_bidang_urusan']} \n   Anggaran    : ${currencyFormat.format(urusan['anggaran'])} \n   Realisasi     : ${currencyFormat.format(urusan['realisasi_rill'])} \n   Persentase : ${persentase.toStringAsFixed(2)}% \n   Pengajuan  : ${currencyFormat.format(urusan['realisasi_rencana'] - urusan['realisasi_rill'])}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                LoggerService.logger.i(
                                    'Fetching kendaliProgram data for ${urusan['id_bidang_urusan']}'); // Logging
                                controller.fetchKendaliProgram(
                                    skpd['id_skpd'],
                                    skpd['id_sub_skpd'],
                                    urusan['id_bidang_urusan']);
                              }
                            },
                            children: [
                              Obx(() {
                                LoggerService.logger.i(
                                    'Fetching kendaliProgram data'); // Logging
                                if (controller.kendaliProgram.isEmpty) {
                                  LoggerService.logger
                                      .i('kendaliProgram is empty'); // Logging
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  LoggerService.logger
                                      .i('kendaliProgram has data'); // Logging
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: controller.kendaliProgram.length,
                                    itemBuilder: (context, index) {
                                      var program =
                                          controller.kendaliProgram[index];
                                      double persentase = calculatePercentage(
                                          program['realisasi_rill'],
                                          program['anggaran']);
                                      return ExpansionTile(
                                        collapsedBackgroundColor:
                                            Colors.grey[100],
                                        title: Text(
                                            '      [ PROGRAM ]\n${program['kode_program']} - ${program['nama_program']} \n      Anggaran    : ${currencyFormat.format(program['anggaran'])} \n      Realisasi     : ${currencyFormat.format(program['realisasi_rill'])} \n      Persentase : ${persentase.toStringAsFixed(2)}% \n      Pengajuan  : ${currencyFormat.format(program['realisasi_rencana'] - program['realisasi_rill'])}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black)),
                                        onExpansionChanged: (expanded) {
                                          if (expanded) {
                                            LoggerService.logger.i(
                                                'Fetching kendaliKegiatan data for ${program['id_program']}'); // Logging
                                            controller.fetchKendaliKegiatan(
                                                skpd['id_skpd'],
                                                skpd['id_sub_skpd'],
                                                urusan['id_bidang_urusan'],
                                                program['id_program']);
                                          }
                                        },
                                        children: [
                                          Obx(() {
                                            LoggerService.logger.i(
                                                'Fetching kendaliKegiatan data'); // Logging
                                            if (controller
                                                .kendaliKegiatan.isEmpty) {
                                              LoggerService.logger.i(
                                                  'kendaliKegiatan is empty'); // Logging
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else {
                                              LoggerService.logger.i(
                                                  'kendaliKegiatan has data'); // Logging
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: controller
                                                    .kendaliKegiatan.length,
                                                itemBuilder: (context, index) {
                                                  var kegiatan = controller
                                                      .kendaliKegiatan[index];
                                                  double persentase =
                                                      calculatePercentage(
                                                          kegiatan[
                                                              'realisasi_rill'],
                                                          kegiatan['anggaran']);
                                                  return ExpansionTile(
                                                    collapsedBackgroundColor:
                                                        Colors.grey[100],
                                                    title: Text(
                                                        '         [ KEGIATAN ]\n${kegiatan['kode_giat']} - ${kegiatan['nama_giat']} \n         Anggaran    : ${currencyFormat.format(kegiatan['anggaran'])} \n         Realisasi     : ${currencyFormat.format(kegiatan['realisasi_rill'])} \n         Persentase : ${persentase.toStringAsFixed(2)}% \n         Pengajuan  : ${currencyFormat.format(kegiatan['realisasi_rencana'] - kegiatan['realisasi_rill'])}',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black)),
                                                    onExpansionChanged:
                                                        (expanded) {
                                                      if (expanded) {
                                                        LoggerService.logger.i(
                                                            'Fetching kendaliSubKegiatan data for ${kegiatan['id_giat']}'); // Logging
                                                        controller.fetchKendaliSubKegiatan(
                                                            skpd['id_skpd'],
                                                            skpd['id_sub_skpd'],
                                                            urusan[
                                                                'id_bidang_urusan'],
                                                            program[
                                                                'id_program'],
                                                            kegiatan[
                                                                'id_giat']);
                                                      }
                                                    },
                                                    children: [
                                                      Obx(() {
                                                        LoggerService.logger.i(
                                                            'Fetching kendaliSubKegiatan data'); // Logging
                                                        if (controller
                                                            .kendaliSubKegiatan
                                                            .isEmpty) {
                                                          LoggerService.logger.i(
                                                              'kendaliSubKegiatan is empty'); // Logging
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else {
                                                          LoggerService.logger.i(
                                                              'kendaliSubKegiatan has data'); // Logging
                                                          return ListView
                                                              .builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: controller
                                                                .kendaliSubKegiatan
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var subKegiatan =
                                                                  controller
                                                                          .kendaliSubKegiatan[
                                                                      index];
                                                              double
                                                                  persentase =
                                                                  calculatePercentage(
                                                                      subKegiatan[
                                                                          'realisasi_rill'],
                                                                      subKegiatan[
                                                                          'anggaran']);
                                                              return ExpansionTile(
                                                                collapsedBackgroundColor:
                                                                    Colors.grey[
                                                                        100],
                                                                title: Text(
                                                                    '            [ SUBKEGIATAN ]\n${subKegiatan['kode_sub_giat']} - ${subKegiatan['nama_sub_giat']} \n            Anggaran    : ${currencyFormat.format(subKegiatan['anggaran'])} \n            Realisasi     : ${currencyFormat.format(subKegiatan['realisasi_rill'])} \n            Persentase : ${persentase.toStringAsFixed(2)}% \n            Pengajuan  : ${currencyFormat.format(subKegiatan['realisasi_rencana'] - subKegiatan['realisasi_rill'])}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black)),
                                                                onExpansionChanged:
                                                                    (expanded) {
                                                                  if (expanded) {
                                                                    LoggerService
                                                                        .logger
                                                                        .i('Fetching kendaliRekening data for ${subKegiatan['id_sub_giat']}'); // Logging
                                                                    controller.fetchKendaliRekening(
                                                                        skpd[
                                                                            'id_skpd'],
                                                                        skpd[
                                                                            'id_sub_skpd'],
                                                                        urusan[
                                                                            'id_bidang_urusan'],
                                                                        program[
                                                                            'id_program'],
                                                                        kegiatan[
                                                                            'id_giat'],
                                                                        subKegiatan[
                                                                            'id_sub_giat']);
                                                                  }
                                                                },
                                                                children: [
                                                                  Obx(() {
                                                                    LoggerService
                                                                        .logger
                                                                        .i('Fetching kendaliRekening data'); // Logging
                                                                    if (controller
                                                                        .kendaliRekening
                                                                        .isEmpty) {
                                                                      LoggerService
                                                                          .logger
                                                                          .i('kendaliRekening is empty'); // Logging
                                                                      return const Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    } else {
                                                                      LoggerService
                                                                          .logger
                                                                          .i('kendaliRekening has data'); // Logging
                                                                      return ListView
                                                                          .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemCount: controller
                                                                            .kendaliRekening
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          var rekening =
                                                                              controller.kendaliRekening[index];
                                                                          double
                                                                              persentase =
                                                                              calculatePercentage(rekening['realisasi_rill'], rekening['anggaran']);
                                                                          return ListTile(
                                                                            tileColor:
                                                                                Colors.grey[100],
                                                                            titleTextStyle:
                                                                                const TextStyle(fontSize: 12),
                                                                            textColor:
                                                                                Colors.black,
                                                                            title:
                                                                                Text(
                                                                              '               [ REKENING ]\n${rekening['kode_akun']} - ${rekening['nama_akun']} \n               Anggaran    : ${currencyFormat.format(rekening['anggaran'])} \n               Realisasi     : ${currencyFormat.format(rekening['realisasi_rill'])} \n               Persentase : ${persentase.toStringAsFixed(2)}% \n               Pengajuan  : ${currencyFormat.format(rekening['realisasi_rencana'] - rekening['realisasi_rill'])}',
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  }),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          }),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                            ],
                          );
                        },
                      );
                    }
                  }),
                ],
              );
            },
          );
        }
      }),
    );
  }
}

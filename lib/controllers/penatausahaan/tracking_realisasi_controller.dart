import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../auth_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/logger_service.dart';

class RBTrackingRealisasi extends GetxController {
  final RxString pilihBulan = '1'.obs;
  final RxString jenisKriteria = 'semua'.obs;
  final RxString jenisDokumen = '*'.obs;
  final Rx<Uint8List> filePdf = Uint8List(0).obs;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  // set variabel responData
  RxList<Map<String, dynamic>> responOutput = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; // Add loading state
  RxList<Map<String, dynamic>> filteredDetails =
      <Map<String, dynamic>>[].obs; // Add filteredDetails
  final searchQuery = ''.obs; // Add search query variable
  final TextEditingController searchQueryController = TextEditingController();

// set var userData from get autenticator controller
  var refreshToken = Get.find<AuthController>().userData['refresh_token'];
  var idSkpd = Get.find<AuthController>().userData['id_skpd'];
  var isDemo = Get.find<AuthController>().isDemo.value;

  // init columnWidthMode
  final ColumnWidthMode columnWidthMode = ColumnWidthMode.none;

  // init Columns Data Grid
  final List<GridColumn> columnsDataGrid = [
    GridColumn(
      columnName: 'jenis_transaksi',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Jenis',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'tanggal_dokumen',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Tanggal',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nomor_spp',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'SPP',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nomor_spm',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'SPM',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nomor_sp2d',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'SP2D',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_sub_fungsi',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Fungsi',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_urusan',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Urusan',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_program',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Program',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_giat',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Kegiatan',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_sub_giat',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Sub Kegiatan',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'kode_rekening',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Kode Rekening',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nama_rekening',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'Nama Rekening',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    GridColumn(
      columnName: 'nilai_realisasi',
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: const Text(
          'NILAI',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    // Add more columns as needed
  ];

  // init stacker header row
  final List<StackedHeaderRow> stackedHeaderRows = [
    StackedHeaderRow(cells: [
      StackedHeaderCell(
        columnNames: [
          'jenis_transaksi',
          'tanggal_dokumen',
          'nomor_spp',
          'nomor_spm',
          'nomor_sp2d'
        ],
        child: const Center(
          child: Text(
            'INFO DOKUMEN PENGAJUAN',
          ),
        ),
      ),
      StackedHeaderCell(
        columnNames: [
          'nama_sub_fungsi',
          'nama_urusan',
          'nama_program',
          'nama_giat',
          'nama_sub_giat'
        ],
        child: const Center(
          child: Text(
            'URUSAN - PROGRAM - KEGIATAN - SUBKEGIATAN',
          ),
        ),
      ),
      StackedHeaderCell(
        columnNames: ['kode_rekening', 'nama_rekening'],
        child: const Center(
          child: Text(
            'REKENING BELANJA',
          ),
        ),
      ),
      // Add more StackedHeaderCell as needed
    ]),
  ];

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    pilihBulan.value = "${now.month}";
  }

  // Fungsi filterDetails untuk menampilkan detail SP2D berdasarkan jenis SP2D
  void filterDetails() {
    RxList<Map<String, dynamic>> detailFilter;
    if (jenisDokumen.value == '*') {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput);
    }
    if (jenisDokumen.value == 'gantung') {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput
          .where((item) =>
              (item['nomor_spm'] == null || item['nomor_sp2d'] == null))
          .toList());
    } else {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput
          .where((item) => item['jenis_transaksi'] == jenisDokumen.value)
          .toList());
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      detailFilter = RxList<Map<String, dynamic>>.from(detailFilter
          .where((item) =>
              item['nama_sub_giat']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['nama_rekening']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['keterangan_dokumen']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList());
    }

    filteredDetails.value = detailFilter;
  }

  // Fungsi previewReport untuk menampilkan data SP2D
  void previewReport() async {
    isLoading.value = true; // Set loading state to true
    final int pBulan = int.parse(pilihBulan.value);
    var responData = await ApiService.postTrackingRealisasi(
        pBulan, idSkpd, refreshToken, isDemo);
    responOutput.value = List<Map<String, dynamic>>.from(responData);
    LoggerService.logger.i('Preview Respon: $responData');
    update(); // Update the state
    isLoading.value = false; // Set loading state to false
  }

  // Fungsi printPdf untuk mencetak PDF
  Future<void> printPdf(List<Map<String, dynamic>> dataToPdf) async {
    // Check if dataToPdf is null or contains null values
    if (dataToPdf.isEmpty) {
      Get.snackbar('Error', 'Error printing PDF: Data is null or invalid');
      LoggerService.logger.e('Error printing PDF: Data is null or invalid');
      return;
    }

    try {
      final pdf = pw.Document();

      // Add a title
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Tracking Realisasi - ${jenisDokumen.value == '*' ? 'Semua' : jenisDokumen.value}\n Periode: ${pilihBulan.value}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(
                        500), // Custom width for 'nomor_dokumen'
                    1: const pw.FixedColumnWidth(
                        80), // Custom width for 'jenis'
                    2: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_bruto'
                    3: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_potongan'
                    4: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_netto'
                    5: const pw.FixedColumnWidth(
                        200), // Custom width for 'tanggal_pembuatan'
                    6: const pw.FixedColumnWidth(
                        200), // Custom width for 'tanggal_pencairan'
                    7: const pw.FixedColumnWidth(
                        650), // Custom width for 'keterangan'
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        'nomor_dokumen',
                        'jenis',
                        'nilai_bruto',
                        'nilai_potongan',
                        'nilai_netto',
                        'tanggal_pembuatan',
                        'tanggal_pencairan',
                        'keterangan'
                      ].map((header) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                    ...dataToPdf.map((item) {
                      return pw.TableRow(
                        children: [
                          item['nomor_dokumen'].toString(),
                          item['jenis'].toString(),
                          formatCurrency(item['nilai_bruto'].toDouble()),
                          formatCurrency(item['nilai_potongan'].toDouble()),
                          formatCurrency(item['nilai_netto'].toDouble()),
                          formatter
                              .format(DateTime.parse(item['tanggal_pembuatan']))
                              .toString(),
                          formatter
                              .format(DateTime.parse(item['tanggal_pencairan']))
                              .toString(),
                          item['keterangan'].toString(),
                        ].map((value) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(value),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Convert the PDF document to bytes
      final pdfBytes = await pdf.save();

      // Print the PDF
      LoggerService.logger.i('Printing PDF'); // Add logging statement
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      LoggerService.logger.e('Error printing PDF: $e'); // Log the error
    }
  }

  // Fungsi formatCurrency untuk menampilkan format mata uang
  String formatCurrency(double value) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: 'id-ID',
    ).format(value);
  }
}

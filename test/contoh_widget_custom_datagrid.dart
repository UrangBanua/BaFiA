import 'package:flutter/material.dart';
import 'package:bafia/widgets/custom/custom_datagrid_widget.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<StackedHeaderRow> stackedHeaderRows = [
      StackedHeaderRow(cells: [
        StackedHeaderCell(
          columnNames: ['tanggal_dokumen', 'jenis_transaksi'],
          child: const Center(
            child: Text(
              'Info Dokumen',
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
              'Urusan Program Kegiatan SubKegiatan',
            ),
          ),
        ),
        StackedHeaderCell(
          columnNames: ['kode_rekening', 'nama_rekening'],
          child: const Center(
            child: Text(
              'Rekening Belanja',
            ),
          ),
        ),
        StackedHeaderCell(
          columnNames: ['nilai_realisasi', 'nilai_setoran'],
          child: Container(
            color: Colors.green,
            child: const Center(
              child: Text(
                'Nilai',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        // Add more StackedHeaderCell as needed
      ]),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom DataGrid Example')),
        body: CustomDataGridScreen(stackedHeaderRows: stackedHeaderRows),
      ),
    );
  }
}

class CustomDataGridScreen extends StatelessWidget {
  final List<StackedHeaderRow> stackedHeaderRows;

  const CustomDataGridScreen({required this.stackedHeaderRows});

  Future<List<Map<String, dynamic>>> fetchJsonData() async {
    final response = await http.get(
      Uri.parse(
          'https://service.sipd.kemendagri.go.id/pengeluaran/strict/laporan/realisasi/cetak?tipe=bulan&bulan=8'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTSVBEX0FVVEhfU0VSVklDRSIsInN1YiI6IjI4OTI5MS4yOTUiLCJleHAiOjE3MjM2NTY3OTksImlhdCI6MTcyMzQ0MDc5OSwidGFodW4iOjIwMjQsImlkX3VzZXIiOjI4OTI5MSwiaWRfZGFlcmFoIjoyOTUsImtvZGVfcHJvdmluc2kiOiI2MyIsImlkX3NrcGQiOjUzLCJpZF9yb2xlIjo0LCJpZF9wZWdhd2FpIjoyODQ3OTIsInN1Yl9kb21haW5fZGFlcmFoIjoiaHVsdXN1bmdhaXRlbmdhaGthYiJ9.qHyT9QTWm_rVQmraIdkwvQOWSdavq9gVxiWzsRyxtPc',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load data, StatusCode: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          List<GridColumn> columns = [
            GridColumn(
              columnName: 'tanggal_dokumen',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Tanggal Dokumen',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            GridColumn(
              columnName: 'jenis_transaksi',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Jenis Transaksi',
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
                  'Realisasi',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            GridColumn(
              columnName: 'nilai_setoran',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Setoran',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Add more columns as needed
          ];

          return CustomDataGrid(
            jsonData: snapshot.data!,
            columns: columns,
            stackedHeader: true,
            stackedHeaderRows: stackedHeaderRows,
          );
        }
      },
    );
  }
}

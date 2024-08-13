import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class CustomDataGrid extends StatefulWidget {
  final List<Map<String, dynamic>> jsonData;
  final List<GridColumn> columns;
  final ColumnWidthMode columnWidthMode;
  final bool stackedHeader;
  final List<StackedHeaderRow> stackedHeaderRows;

  const CustomDataGrid({
    super.key,
    required this.jsonData,
    required this.columns,
    this.columnWidthMode = ColumnWidthMode.none,
    this.stackedHeader = false,
    required this.stackedHeaderRows,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomDataGridState createState() => _CustomDataGridState();
}

class _CustomDataGridState extends State<CustomDataGrid> {
  late CustomDataGridSource _dataGridSource;

  @override
  void initState() {
    super.initState();
    _dataGridSource = CustomDataGridSource(
      widget.jsonData,
      columns: widget.columns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SfDataGrid(
            source: _dataGridSource,
            columns: widget.columns,
            stackedHeaderRows:
                widget.stackedHeader ? widget.stackedHeaderRows : [],
            columnWidthMode: widget.columnWidthMode,
          ),
        ),
      ],
    );
  }
}

class CustomDataGridSource extends DataGridSource {
  CustomDataGridSource(
    List<Map<String, dynamic>> jsonData, {
    required List<GridColumn> columns,
  }) {
    dataGridRows = jsonData.map<DataGridRow>((data) {
      final cells = columns.map<DataGridCell>((column) {
        return DataGridCell(
          columnName: column.columnName,
          value: data[column.columnName],
        );
      }).toList();
      return DataGridRow(cells: cells);
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final value = dataGridCell.value;
        String formattedValue;

        if (value is DateTime) {
          formattedValue = DateFormat('dd-MM-yyyy').format(value);
        } else if (value is double || value is int) {
          formattedValue = NumberFormat.currency(
            symbol: 'Rp ',
            decimalDigits: 2,
            locale: 'id-ID',
          ).format(value.toDouble());
        } else {
          formattedValue = value.toString();
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(formattedValue),
        );
      }).toList(),
    );
  }
}

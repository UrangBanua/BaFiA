// models/dashboard.dart
class DashboardModel {
  final int? idDaerah;
  final int? tahun;
  final int? idSkpd;
  final String? kodeSkpd;
  final String? namaSkpd;
  final double? anggaran;
  final double? realisasiRencana;
  final double? realisasiRill;
  final DateTime? timeUpdate;

  DashboardModel({
    this.idDaerah,
    this.tahun,
    this.idSkpd,
    this.kodeSkpd,
    this.namaSkpd,
    this.anggaran,
    this.realisasiRencana,
    this.realisasiRill,
    this.timeUpdate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      idDaerah: json['id_daerah'],
      tahun: json['tahun'],
      idSkpd: json['id_skpd'],
      kodeSkpd: json['kode_skpd'],
      namaSkpd: json['nama_skpd'],
      anggaran: json['anggaran'],
      realisasiRencana: json['realisasi_rencana'],
      realisasiRill: json['realisasi_rill'],
      timeUpdate: DateTime.tryParse(json['time_update']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_daerah': idDaerah,
      'tahun': tahun,
      'id_skpd': idSkpd,
      'kode_skpd': kodeSkpd,
      'nama_skpd': namaSkpd,
      'anggaran': anggaran,
      'realisasi_rencana': realisasiRencana,
      'realisasi_rill': realisasiRill,
      'time_update': timeUpdate?.toIso8601String(),
    };
  }
}

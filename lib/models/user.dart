// models/user.dart
class UserModel {
  final int? idUser;
  final String? username;
  final String? password;
  final int? tahun;
  final int? idPegawai;
  final String? namaPegawai;
  final int? idRole;
  final String? namaRole;
  final int? idSkpd;
  final int? kodeSkpd;
  final String? namaSkpd;
  final int? idDaerah;
  final String? namaDaerah;
  final String? token;
  final String? refreshToken;
  final String? profilePhoto;
  final bool? isDarkMode;
  final DateTime? timeUpdate;

  UserModel({
    this.idUser,
    this.username,
    this.password,
    this.tahun,
    this.idPegawai,
    this.namaPegawai,
    this.idRole,
    this.namaRole,
    this.idSkpd,
    this.kodeSkpd,
    this.namaSkpd,
    this.idDaerah,
    this.namaDaerah,
    this.token,
    this.refreshToken,
    this.profilePhoto,
    this.isDarkMode,
    this.timeUpdate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'],
      username: json['username'],
      password: json['password'],
      tahun: json['tahun'],
      idPegawai: json['id_pegawai'],
      namaPegawai: json['nama_pegawai'],
      idRole: json['id_role'],
      namaRole: json['nama_role'],
      idSkpd: json['id_skpd'],
      kodeSkpd: json['kode_skpd'],
      namaSkpd: json['nama_skpd'],
      idDaerah: json['id_daerah'],
      namaDaerah: json['nama_daerah'],
      token: json['token'],
      refreshToken: json['refresh_token'],
      profilePhoto: json['profile_photo'],
      isDarkMode: json['isDarkMode'] == 1,
      timeUpdate: DateTime.tryParse(json['time_update']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'password': password,
      'tahun': tahun,
      'id_pegawai': idPegawai,
      'nama_pegawai': namaPegawai,
      'id_role': idRole,
      'nama_role': namaRole,
      'id_skpd': idSkpd,
      'kode_skpd': kodeSkpd,
      'nama_skpd': namaSkpd,
      'id_daerah': idDaerah,
      'nama_daerah': namaDaerah,
      'token': token,
      'refresh_token': refreshToken,
      'profile_photo': profilePhoto,
      'isDarkMode': isDarkMode != null ? (isDarkMode! ? 1 : 0) : 0,
      'time_update': timeUpdate?.toIso8601String(),
    };
  }
}

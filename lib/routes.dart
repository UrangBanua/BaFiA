import 'package:get/get.dart';
import 'views/about_page.dart';
import 'views/login_page.dart';
import 'views/dashboard_page.dart';
import 'views/penatausahaan/buku_kas_umum.dart';
import 'views/penatausahaan/daftar_rekanan.dart';
import 'views/penatausahaan/dokumen_kendali_page.dart';
import 'views/penatausahaan/laporan_pertanggungjawaban/lpj_administratif.dart';
import 'views/penatausahaan/laporan_pertanggungjawaban/lpj_fungsional.dart';
import 'views/penatausahaan/laporan_pertanggungjawaban/lpj_tu.dart';
import 'views/penatausahaan/laporan_pertanggungjawaban/lpj_up_gu.dart';
import 'views/penatausahaan/register_pendapatan/stbp_page.dart';
import 'views/penatausahaan/register_pendapatan/sts_page.dart';
import 'views/penatausahaan/register_belanja/spp_page.dart';
import 'views/penatausahaan/register_belanja/spm_page.dart';
import 'views/penatausahaan/register_belanja/sp2d_page.dart';
import 'views/penatausahaan/register_belanja/pengajuan_tu_page.dart';
import 'views/penatausahaan/register_belanja/tbp_gu_page.dart';
import 'views/akuntansi/jurnal_approve/anggaran_page.dart';
import 'views/akuntansi/jurnal_approve/belanja_page.dart';
import 'views/akuntansi/jurnal_approve/pendapatan_page.dart';
import 'views/akuntansi/laporan_keuangan/lo_page.dart';
import 'views/akuntansi/laporan_keuangan/lpe_page.dart';
import 'views/akuntansi/laporan_keuangan/lra_page.dart';
import 'views/akuntansi/laporan_keuangan/neraca_page.dart';
import 'views/akuntansi/buku/besar_page.dart';
import 'views/akuntansi/buku/besar_pembantu_page.dart';
import 'views/akuntansi/buku/jurnal_page.dart';
import 'views/akuntansi/jurnal_umum_page.dart';
import 'views/akuntansi/mutasi_rekening_page.dart';
import 'views/akuntansi/neraca_saldo_page.dart';
import 'views/profile_user_page.dart';
// import other pages...

List<GetPage> appRoutes() {
  return [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/dashboard', page: () => DashboardPage()),
    GetPage(
        name: '/penatausahaan/dokumen_kendali',
        page: () => DokumenKendaliPage()),
    GetPage(
        name: '/penatausahaan/register_pendapatan/stbp',
        page: () => RPStbpPPage()),
    GetPage(
        name: '/penatausahaan/register_pendapatan/sts',
        page: () => RPStsPage()),
    GetPage(
        name: '/penatausahaan/register_belanja/spp', page: () => RBSppPage()),
    GetPage(
        name: '/penatausahaan/register_belanja/spm', page: () => RBSpmPage()),
    GetPage(
        name: '/penatausahaan/register_belanja/sp2d', page: () => RBSp2dPage()),
    GetPage(
        name: '/penatausahaan/register_belanja/tbp_gu',
        page: () => RBTbpGuPage()),
    GetPage(
        name: '/penatausahaan/register_belanja/pengajuan_tu',
        page: () => RBPengajuanTuPage()),
    GetPage(
        name: '/penatausahaan/daftar_rekanan',
        page: () => const DaftarRekananPage()),
    GetPage(
        name: '/penatausahaan/buku_kas_umum', page: () => BukuKasUmumPage()),
    GetPage(
        name: '/penatausahaan/laporan_pertanggungjawaban/lpj_up_gu',
        page: () => LPJGUPage()),
    GetPage(
        name: '/penatausahaan/laporan_pertanggungjawaban/lpj_tu',
        page: () => LPJTUPage()),
    GetPage(
        name: '/penatausahaan/laporan_pertanggungjawaban/lpj_administratif',
        page: () => LPJAdministratifPage()),
    GetPage(
        name: '/penatausahaan/laporan_pertanggungjawaban/lpj_fungsional',
        page: () => LPJFungsionalPage()),
    GetPage(
        name: '/akuntansi/jurnal_approve/anggaran',
        page: () => const JAAnggaranPage()),
    GetPage(
        name: '/akuntansi/jurnal_approve/pendapatan',
        page: () => const JAPendapatanPage()),
    GetPage(
        name: '/akuntansi/jurnal_approve/belanja',
        page: () => const JABelanjaPage()),
    GetPage(name: '/akuntansi/jurnal_umum', page: () => const JurnalUmumPage()),
    GetPage(name: '/akuntansi/buku/jurnal', page: () => const BukuJurnalPage()),
    GetPage(name: '/akuntansi/buku/besar', page: () => const BukuBesarPage()),
    GetPage(
        name: '/akuntansi/buku/besar_pembantu',
        page: () => const BukuBesarPembantuPage()),
    GetPage(
        name: '/akuntansi/mutasi_rekening',
        page: () => const MutasiRekeningPage()),
    GetPage(
        name: '/akuntansi/neraca_saldo', page: () => const NeracaSaldoPage()),
    GetPage(name: '/akuntansi/laporan_keuangan/lra', page: () => LKLraPage()),
    GetPage(name: '/akuntansi/laporan_keuangan/lo', page: () => LKLoPage()),
    GetPage(name: '/akuntansi/laporan_keuangan/lpe', page: () => LKLpePage()),
    GetPage(
        name: '/akuntansi/laporan_keuangan/neraca', page: () => LKNeracaPage()),
    GetPage(name: '/profile_user', page: () => ProfileUserPage()),
    GetPage(name: '/about', page: () => const AboutPage()),
    // add other routes...
  ];
}

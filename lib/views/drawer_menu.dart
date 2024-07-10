import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class DrawerMenu extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Get.toNamed('/dashboard');
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.folder),
            title: const Text('Penatausahaan'),
            children: <Widget>[
              ListTile(
                title: const Text('Dokumen Kendali'),
                onTap: () {
                  Get.toNamed('/penatausahaan/dokumen_kendali');
                },
              ),
              ExpansionTile(
                title: const Text('Register Pendapatan'),
                children: <Widget>[
                  ListTile(
                    title: const Text('STBP'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_pendapatan/stbp');
                    },
                  ),
                  ListTile(
                    title: const Text('STS'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_pendapatan/sts');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Register Belanja'),
                children: <Widget>[
                  ListTile(
                    title: const Text('SPP'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/spp');
                    },
                  ),
                  ListTile(
                    title: const Text('SPM'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/spm');
                    },
                  ),
                  ListTile(
                    title: const Text('SP2D'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/sp2d');
                    },
                  ),
                  ListTile(
                    title: const Text('TBP - GU'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/tbp_gu');
                    },
                  ),
                  ListTile(
                    title: const Text('Pengajuan - TU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/register_belanja/pengajuan_tu');
                    },
                  ),
                ],
              ),
              ListTile(
                title: const Text('Daftar Rekanan'),
                onTap: () {
                  Get.toNamed('/penatausahaan/daftar_rekanan');
                },
              ),
              ListTile(
                title: const Text('Buku Kas Umum'),
                onTap: () {
                  Get.toNamed('/penatausahaan/buku_kas_umum');
                },
              ),
              ExpansionTile(
                title: const Text('Laporan Pertanggungjawaban'),
                children: <Widget>[
                  ListTile(
                    title: const Text('LPJ UP/GU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_up_gu');
                    },
                  ),
                  ListTile(
                    title: const Text('LPJ TU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_tu');
                    },
                  ),
                  ListTile(
                    title: const Text('LPJ Administratif'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_administratif');
                    },
                  ),
                  ListTile(
                    title: const Text('LPJ Fungsional'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_fungsional');
                    },
                  ),
                ],
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Akuntansi'),
            children: <Widget>[
              ExpansionTile(
                title: const Text('Jurnal Approve'),
                children: <Widget>[
                  ListTile(
                    title: const Text('Anggaran'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/anggaran');
                    },
                  ),
                  ListTile(
                    title: const Text('Pendapatan'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/pendapatan');
                    },
                  ),
                  ListTile(
                    title: const Text('Belanja'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/belanja');
                    },
                  ),
                ],
              ),
              ListTile(
                title: const Text('Jurnal Umum'),
                onTap: () {
                  Get.toNamed('/akuntansi/jurnal_umum');
                },
              ),
              ExpansionTile(
                title: const Text('Buku'),
                children: <Widget>[
                  ListTile(
                    title: const Text('Jurnal'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/jurnal');
                    },
                  ),
                  ListTile(
                    title: const Text('Besar'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/besar');
                    },
                  ),
                  ListTile(
                    title: const Text('Besar Pembantu'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/besar_pembantu');
                    },
                  ),
                ],
              ),
              ListTile(
                title: const Text('Mutasi Rekening'),
                onTap: () {
                  Get.toNamed('/akuntansi/mutasi_rekening');
                },
              ),
              ListTile(
                title: const Text('Neraca Saldo'),
                onTap: () {
                  Get.toNamed('/akuntansi/neraca_saldo');
                },
              ),
              ExpansionTile(
                title: const Text('Laporan Keuangan'),
                children: <Widget>[
                  ListTile(
                    title: const Text('LRA'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lra');
                    },
                  ),
                  ListTile(
                    title: const Text('LO'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lo');
                    },
                  ),
                  ListTile(
                    title: const Text('LPE'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lpe');
                    },
                  ),
                  ListTile(
                    title: const Text('Neraca'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/neraca');
                    },
                  ),
                ],
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile User'),
            onTap: () {
              Get.toNamed('/profile_user');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Get.toNamed('/about');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}

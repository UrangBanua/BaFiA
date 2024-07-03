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
          DrawerHeader(
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
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Get.toNamed('/dashboard');
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.folder),
            title: Text('Penatausahaan'),
            children: <Widget>[
              ListTile(
                title: Text('Dokumen Kendali'),
                onTap: () {
                  Get.toNamed('/penatausahaan/dokumen_kendali');
                },
              ),
              ExpansionTile(
                title: Text('Register Pendapatan'),
                children: <Widget>[
                  ListTile(
                    title: Text('STBP'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_pendapatan/stbp');
                    },
                  ),
                  ListTile(
                    title: Text('STS'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_pendapatan/sts');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('Register Belanja'),
                children: <Widget>[
                  ListTile(
                    title: Text('SPP'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/spp');
                    },
                  ),
                  ListTile(
                    title: Text('SPM'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/spm');
                    },
                  ),
                  ListTile(
                    title: Text('SP2D'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/sp2d');
                    },
                  ),
                  ListTile(
                    title: Text('TBP - GU'),
                    onTap: () {
                      Get.toNamed('/penatausahaan/register_belanja/tbp_gu');
                    },
                  ),
                  ListTile(
                    title: Text('Pengajuan - TU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/register_belanja/pengajuan_tu');
                    },
                  ),
                ],
              ),
              ListTile(
                title: Text('Daftar Rekanan'),
                onTap: () {
                  Get.toNamed('/penatausahaan/daftar_rekanan');
                },
              ),
              ListTile(
                title: Text('Buku Kas Umum'),
                onTap: () {
                  Get.toNamed('/penatausahaan/buku_kas_umum');
                },
              ),
              ExpansionTile(
                title: Text('Laporan Pertanggungjawaban'),
                children: <Widget>[
                  ListTile(
                    title: Text('LPJ UP/GU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_up_gu');
                    },
                  ),
                  ListTile(
                    title: Text('LPJ TU'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_tu');
                    },
                  ),
                  ListTile(
                    title: Text('LPJ Administratif'),
                    onTap: () {
                      Get.toNamed(
                          '/penatausahaan/laporan_pertanggungjawaban/lpj_administratif');
                    },
                  ),
                  ListTile(
                    title: Text('LPJ Fungsional'),
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
            leading: Icon(Icons.account_balance),
            title: Text('Akuntansi'),
            children: <Widget>[
              ExpansionTile(
                title: Text('Jurnal Approve'),
                children: <Widget>[
                  ListTile(
                    title: Text('Anggaran'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/anggaran');
                    },
                  ),
                  ListTile(
                    title: Text('Pendapatan'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/pendapatan');
                    },
                  ),
                  ListTile(
                    title: Text('Belanja'),
                    onTap: () {
                      Get.toNamed('/akuntansi/jurnal_approve/belanja');
                    },
                  ),
                ],
              ),
              ListTile(
                title: Text('Jurnal Umum'),
                onTap: () {
                  Get.toNamed('/akuntansi/jurnal_umum');
                },
              ),
              ExpansionTile(
                title: Text('Buku'),
                children: <Widget>[
                  ListTile(
                    title: Text('Jurnal'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/jurnal');
                    },
                  ),
                  ListTile(
                    title: Text('Besar'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/besar');
                    },
                  ),
                  ListTile(
                    title: Text('Besar Pembantu'),
                    onTap: () {
                      Get.toNamed('/akuntansi/buku/besar_pembantu');
                    },
                  ),
                ],
              ),
              ListTile(
                title: Text('Mutasi Rekening'),
                onTap: () {
                  Get.toNamed('/akuntansi/mutasi_rekening');
                },
              ),
              ListTile(
                title: Text('Neraca Saldo'),
                onTap: () {
                  Get.toNamed('/akuntansi/neraca_saldo');
                },
              ),
              ExpansionTile(
                title: Text('Laporan Keuangan'),
                children: <Widget>[
                  ListTile(
                    title: Text('LRA'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lra');
                    },
                  ),
                  ListTile(
                    title: Text('LO'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lo');
                    },
                  ),
                  ListTile(
                    title: Text('LPE'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/lpe');
                    },
                  ),
                  ListTile(
                    title: Text('Neraca'),
                    onTap: () {
                      Get.toNamed('/akuntansi/laporan_keuangan/neraca');
                    },
                  ),
                ],
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile User'),
            onTap: () {
              Get.toNamed('/profile_user');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Get.toNamed('/about');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}

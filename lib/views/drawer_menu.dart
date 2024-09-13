import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';

// ignore: use_key_in_widget_constructors
class DrawerMenu extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Obx(() {
                  return FutureBuilder<ImageProvider<Object>>(
                    future: userController
                        .getProfileImage1(userController.fotoProfile.value),
                    builder: (context, snapshot) {
                      Widget profileWidget;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        profileWidget = Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.grey,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        profileWidget = Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        profileWidget = Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: snapshot.data!,
                          ),
                        );
                      } else {
                        profileWidget = Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    snapshot.hasData
                                        ? Image(image: snapshot.data!)
                                        : const Icon(Icons.person, size: 100),
                                    const SizedBox(height: 8.0),
                                    Text(userController
                                            .userProfile['nama_role'] ??
                                        ''),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: profileWidget,
                      );
                    },
                  );
                }),
                /* IconButton(
                  icon: Icon(
                    Get.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.changeTheme(
                      Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
                    );
                  },
                ), */
              ],
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
                title: const Text('Pohon Kendali'),
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
            title: const Text('Info BaFiA'),
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

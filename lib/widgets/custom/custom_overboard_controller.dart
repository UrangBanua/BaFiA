import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intro_slider/intro_slider.dart';

import '../../services/logger_service.dart';

class CustomOverboardController extends GetxController {
  final box = GetStorage();
  var isFirstLaunch = false.obs;
  var isAgreed = false.obs;
  List<ContentConfig> listContentOverboard = [];

  final keyAgreed = GlobalKey();

  static const String privacyPolicyText =
      '''"Silahkan Scroll ke bawah untuk Persetujuan Kebijakan Privasi",\nterhadap penggunaan aplikasi BaFiA.
      \nDiperbarui Tanggal: 09/08/2024
      \nBaFiA sangat menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat Anda menggunakan aplikasi kami.
      \n1. Informasi yang BaFiA Kumpulkan.\nBaFiA hanya mengumpulkan beberapa jenis informasi dari dan tentang pengguna aplikasi kami, diantaranya :\n- Informasi Perangkat: Informasi tentang perangkat yang Anda gunakan untuk mengakses aplikasi kami, termasuk alamat IP, jenis perangkat, sistem operasi, dan pengidentifikasi perangkat unik.\n- Data Penggunaan: Informasi tentang bagaimana Anda menggunakan aplikasi kami, termasuk waktu akses, halaman yang dilihat, dan tindakan yang diambil.
      \n2. Cara BaFiA Menggunakan Informasi Perangkat Anda.\nBaFiA menggunakan informasi perangkat dan data penggunaan di kumpulkan untuk berbagai tujuan, termasuk:\n- Memberikan Layanan: Untuk mengoperasikan dan memelihara aplikasi kami, termasuk menyediakan fitur dan layanan yang Anda minta.\n- Meningkatkan Aplikasi: Untuk memahami bagaimana pengguna berinteraksi dengan aplikasi kami dan membuat perbaikan berdasarkan umpan balik tersebut.\n- Komunikasi: Untuk mengirimkan pemberitahuan, pembaruan, dan informasi lain yang relevan tentang aplikasi kami.\n- Keamanan: Untuk melindungi aplikasi kami dan pengguna dari aktivitas yang tidak sah atau berbahaya.
      \n3. Berbagi Informasi Anda.\nBaFiA hanya membagikan tentang Informasi Perangkat dan Aktivitas Penggunaan Anda dengan pihak ketika dalam keadaan/kondisi berikut:\n- Dengan Persetujuan Anda: BaFiA dapat membagikan informasi Anda jika Anda memberikan persetujuan eksplisit untuk melakukannya.\n- Untuk Mematuhi Hukum: BaFiA dapat mengungkapkan informasi Anda jika diwajibkan oleh hukum atau sebagai tanggapan terhadap permintaan yang sah dari otoritas penegak hukum.\n- Dengan Penyedia Layanan: BaFiA dapat berbagi informasi dengan penyedia layanan pihak ketiga yang membantu kami dalam mengoperasikan aplikasi kami, dengan ketentuan bahwa mereka setuju untuk menjaga kerahasiaan informasi Anda.
      \n4. Keamanan Informasi Anda.\nBaFiA mengambil langkah-langkah yang wajar untuk melindungi informasi pribadi Anda dari akses, penggunaan, atau pengungkapan yang tidak sah. Namun, tidak ada metode transmisi data melalui internet atau metode penyimpanan elektronik yang sepenuhnya aman, sehingga kami tidak dapat menjamin keamanan absolut.
      \n5. Hak Anda.\nAnda memiliki hak untuk mengakses, memperbarui, atau menghapus informasi pribadi Anda yang kami miliki. Jika Anda ingin menggunakan hak-hak ini, silakan hubungi kami situs web dibawah.
      \n6. Perubahan pada Kebijakan Privasi Ini.\nBaFiA dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. BaFiA akan memberi tahu Anda tentang perubahan tersebut dengan memposting kebijakan yang diperbarui di aplikasi kami. Anda disarankan untuk meninjau Kebijakan Privasi ini secara berkala untuk mengetahui perubahan apa pun.
      \n7. Demo Aplikasi.\nJika Anda belum memiliki akses pada aplikasi ini, Anda dapat menggunakan login demo, username dan password sebagai berikut:\n- username : 111111111111111111\n- password : demo
      \n8. Hubungi BaFiA.\nJika Anda memiliki pertanyaan atau kekhawatiran tentang Kebijakan Privasi ini, silakan hubungi kami di:
      \n(https://github.com/UrangBanua/BaFiA/issues)
       ''';

  @override
  void onInit() {
    super.onInit();
    _checkFirstLaunch();
    if (isFirstLaunch.value) {
      listContentOverboard.add(
        const ContentConfig(
          backgroundColor: Colors.blue,
          pathImage: 'assets/images/intro1.png',
          title: 'Selamat Datang',
          description:
              'Selamat datang di\nAplikasi BaFiA\nAsisten Keuangan Keluarga LKPD\nTemukan berbagai fitur menarik di sini.',
          styleTitle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          styleDescription: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );

      listContentOverboard.add(
        const ContentConfig(
          backgroundColor: Colors.green,
          pathImage: 'assets/images/intro2.png',
          title: 'Fitur Unggulan',
          description:
              'Jelajahi fitur-fitur unggulan kami yang dirancang untuk\nmemudahkan `monitoring & control` keuangan Anda dalam tiap proses tahapan LKPD.',
          styleTitle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          styleDescription: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );

      listContentOverboard.add(
        const ContentConfig(
          backgroundColor: Colors.purple,
          pathImage: 'assets/images/intro3.png',
          title: 'Mulai Sekarang',
          description:
              'Ayo mulai petualangan Anda dan nikmati pengalaman MoCo bersama BaFiA.',
          styleTitle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          styleDescription: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );

      listContentOverboard.add(
        ContentConfig(
          backgroundColor: Colors.black,
          pathImage: 'assets/images/privacy_policy.png',
          title: 'Kebijakan Privasi',
          widgetDescription: Column(
            children: [
              const SizedBox(
                child: SingleChildScrollView(
                  child: Text(
                    privacyPolicyText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Obx(() => Checkbox(
                        key: keyAgreed,
                        value: isAgreed.value,
                        onChanged: (bool? value) {
                          isAgreed.value = value ?? false;
                        },
                      )),
                  const Expanded(
                    child: Text(
                      "Saya telah membaca dan menyetujui Kebijakan Privasi dan Ketentuan Layanan.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void _checkFirstLaunch() {
    bool? isOverboard = box.read('isOverboard');
    LoggerService.logger.i('isOverboard (before check): $isOverboard');
    if (isOverboard == null || isOverboard) {
      isFirstLaunch.value = true;
      box.write('isOverboard', false);
      LoggerService.logger.i('isOverboard set to false');
    }
  }

  void onDonePress() {
    if (isAgreed.value) {
      Get.toNamed('/login');
    } else {
      Get.snackbar(
        'Kebijakan Privasi',
        'Anda harus menyetujui kebijakan privasi untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }
}

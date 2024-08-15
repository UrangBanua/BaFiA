import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../controllers/auth_controller.dart';
import '../controllers/connectivity_controller.dart';
import '../services/api_firebase.dart';
import '../services/logger_service.dart';
import '../services/tutorial_service.dart';

class LoginPage extends StatefulWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final AuthController authController = Get.put(AuthController());
  final TutorialService tutorialService = TutorialService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  final RxString username = ''.obs;
  final RxString password = ''.obs;

  bool isLoading = false;
  bool _obscureText = true;
  RxBool isFirebaseInitialed = false.obs;

  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  String _version = '';

  // Create global keys for each widget
  final GlobalKey keyKoneksi = GlobalKey();
  final GlobalKey keyRule = GlobalKey();
  final GlobalKey keyTahun = GlobalKey();
  final GlobalKey keyUsername = GlobalKey();
  final GlobalKey keyPassword = GlobalKey();
  final GlobalKey keyLogin = GlobalKey();
  final GlobalKey keyBiometric = GlobalKey();

  // Setup tutorial Awal frehs install
  void _setupTutorialAwal() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      keyKoneksi,
      'Status koneksi internet anda, sebelum login pastikan koneksi internet anda aktif.',
      title: 'Koneksi',
      align: ContentAlign.bottom,
      icon: Icons.cell_wifi,
    );
    tutorialService.addTarget(
      keyTahun,
      'ini tahun anggaran berjalan.',
      title: 'Tahun Anggaran',
      align: ContentAlign.top,
      icon: Icons.calendar_today_rounded,
      shape: ShapeLightFocus.RRect,
    );
    tutorialService.addTarget(
      keyUsername,
      'Silahkan isi username/nip anda disini.',
      title: 'Username/NIP',
      align: ContentAlign.top,
      icon: Icons.person_pin,
      shape: ShapeLightFocus.RRect,
    );
    tutorialService.showTutorial(context, delayInSeconds: 2);
  }

  // Setup tutorial untuk User yg sudah masuk
  void _setupTutorialUser() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      keyRule,
      'Status Anda sudah login, silahkan langsung masuk lewat verifikasi Biometric',
      title: 'Status',
      align: ContentAlign.bottom,
      icon: Icons.badge,
      shape: ShapeLightFocus.RRect, // Custom shape for this target
    );
    tutorialService.addTarget(
      keyBiometric,
      'Silahkan verifikasi data anda disini.',
      title: 'Login Biometric',
      align: ContentAlign.top,
      icon: Icons.fingerprint,
    );
    tutorialService.showTutorial(context, delayInSeconds: 1);
  }

  @override
  void initState() {
    super.initState();
    yearController.text = DateTime.now().year.toString();
    _loadVersion();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4 * 3.1416,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Add listener for connectivity state
    ever(connectivityController.connectivityState, (bool isConnected) async {
      if (isConnected) {
        await _initFCM();
      }
    });

    // Check initial connectivity state
    if (connectivityController.connectivityState.value) {
      _initFCM();
    }

    // Add listeners to update Rx variables
    usernameController.addListener(() {
      username.value = usernameController.text;
    });
    passwordController.addListener(() {
      password.value = passwordController.text;
    });

    // Add delay before setting up the tutorial
    Future.delayed(const Duration(seconds: 3), () {
      // Set Tutorial based on user status
      if (authController.userData.isEmpty) {
        _setupTutorialAwal();
      } else {
        _setupTutorialUser();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    yearController.dispose();
    super.dispose();
  }

  // fungsi untuk load version
  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  // fungsi untuk inisialisasi FCM
  Future<void> _initFCM() async {
    //Initialize FCM setting
    if (isFirebaseInitialed.value == false &&
        connectivityController.connectivityState.value) {
      await ApiFirebase().initNotifications();
      LoggerService.logger.i('Firebase initialized...');
      isFirebaseInitialed.value = true;
    }
  }

  // fungsi untuk login
  void _login() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Simpan data demo berdasarkan kondisi username
      final box = GetStorage();
      if (usernameController.text == '111111111111111111' &&
          passwordController.text == 'demo') {
        LoggerService.logger.i('Demo mode activated');
        await box.write('demo', true);
        authController.isDemo.value = true;
      } else {
        await box.write('demo', false);
        authController.isDemo.value = false;
      }
    } finally {
      // Panggil fungsi login dari authController
      await authController.login(yearController.text, usernameController.text,
          passwordController.text, '');
    }
    setState(() {
      isLoading = false;
    });
  }

  // fungsi untuk peringatan text form
  void _peringatanTextForm() {
    Get.snackbar('Peringatan', 'Username dan Password tidak boleh kosong');
  }

  // fungsi untuk set demo mode
  Future<void> _setDemoMode() async {
    final box = GetStorage();
    setState(() {
      authController.isDemo.value = box.read('demo') ?? false;
    });
  }

  // fungsi untuk handle logo tap
  void _handleLogoTap() {
    _controller.reset(); // Reset the animation
    _controller.forward(); // Start the animation again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // obx untuk menampilkan Connectivity Caption
              Obx(() {
                return SizedBox(
                  height: 20, // Set a fixed height for the text
                  child: AnimatedTextKit(
                    key: keyKoneksi,
                    animatedTexts: [
                      FadeAnimatedText(
                        connectivityController.connectivityCaption.value,
                        textStyle: TextStyle(
                          fontSize: 10,
                          color: connectivityController.connectivityState.value
                              ? Colors.green
                              : Colors.amber,
                        ),
                        duration: const Duration(milliseconds: 2000),
                      ),
                    ],
                    repeatForever: true,
                  ),
                );
              }),
              // buat gab atau pemisah
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _handleLogoTap, // Add tap listener
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _positionAnimation.value *
                          MediaQuery.of(context).size.width,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  // load images from assets/icons/logo.png
                  child: Image.asset(
                    'assets/icons/logo.png',
                    height: 230, // Adjust the height as needed
                  ),
                ),
              ),
              Obx(() {
                if (authController.userData.isNotEmpty) {
                  return AnimatedTextKit(
                    key: keyRule,
                    animatedTexts: [
                      ColorizeAnimatedText(
                          'HALO ${authController.userData['nama_role']}',
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [Colors.blue, Colors.red, Colors.amber]),
                    ],
                    totalRepeatCount: 3,
                    isRepeatingAnimation: true,
                  );
                } else {
                  return Container();
                }
              }),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Obx(() {
                      return TextField(
                        key: keyTahun,
                        readOnly: false,
                        controller: yearController,
                        decoration: InputDecoration(
                          labelText: 'Tahun',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          enabled: authController.userData.isNotEmpty
                              ? false
                              : connectivityController.connectivityState.value,
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return TextField(
                        key: keyUsername,
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'nip',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          enabled: authController.userData.isNotEmpty
                              ? false
                              : connectivityController.connectivityState.value,
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(18),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return TextField(
                        key: keyPassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          enabled: authController.userData.isNotEmpty
                              ? false
                              : connectivityController.connectivityState.value,
                        ),
                        obscureText: _obscureText,
                        style: const TextStyle(fontSize: 14),
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      final isConnected =
                          connectivityController.connectivityState.value;
                      final isFormValid =
                          username.isNotEmpty && password.isNotEmpty;
                      final isLogin = authController.userData.isNotEmpty;

                      return ElevatedButton(
                        key: keyLogin,
                        onPressed: (isConnected && !isLoading)
                            ? (isFormValid
                                ? _login
                                : (isLogin ? null : _peringatanTextForm))
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Login'),
                      );
                    }),
                    // buat gab atau pemisah
                    const SizedBox(height: 60),
                    Obx(() {
                      if (authController.userData.isNotEmpty &&
                          authController.userToken.isNotEmpty) {
                        return IconButton(
                          key: keyBiometric,
                          iconSize: 30,
                          icon: const Icon(Icons.fingerprint),
                          onPressed: () async {
                            bool authenticated =
                                await authController.authenticate();
                            if (authenticated) {
                              await _setDemoMode();
                              Get.offAllNamed('/dashboard');
                            } else {
                              Get.snackbar('Authentication Failed',
                                  'Unable to authenticate');
                            }
                          },
                        );
                      } else {
                        return Container();
                      }
                    }),
                    // buat gab atau pemisah
                    const SizedBox(height: 20),
                    Obx(() {
                      if (authController.userData.isNotEmpty &&
                          authController.userToken.isNotEmpty) {
                        return AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText(
                                'Langsung Masuk ☝ dengan Biometrics',
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                          totalRepeatCount: 3,
                          isRepeatingAnimation: true,
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ],
                ),
              ),
              // add text version app
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Versi: $_version',
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

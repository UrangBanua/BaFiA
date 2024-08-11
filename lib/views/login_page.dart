import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../controllers/connectivity_controller.dart';
import '../services/api_firebase.dart';
import '../services/logger_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final AuthController authController = Get.put(AuthController());

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
    ever(connectivityController.connectivityState, (bool isConnected) {
      if (isConnected) {
        _initFCM();
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
  void _initFCM() async {
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
      SharedPreferences prefsDemo = await SharedPreferences.getInstance();
      if (usernameController.text == '111111111111111111' &&
          passwordController.text == 'demo') {
        LoggerService.logger.i('Demo mode activated');
        await prefsDemo.setBool('demo', true);
        authController.isDemo.value = true;
      } else {
        await prefsDemo.setBool('demo', false);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authController.isDemo.value = prefs.getBool('demo') ?? false;
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

                      return ElevatedButton(
                        onPressed: (isConnected && !isLoading)
                            ? (isFormValid ? _login : _peringatanTextForm)
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
                      if (authController.userData.isNotEmpty) {
                        return IconButton(
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
                      if (authController.userData.isNotEmpty) {
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

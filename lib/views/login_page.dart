import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/connectivity_controller.dart';
import '../widgets/custom/custom_loading_animation.dart';

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
  final AuthController authController = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    yearController.text = DateTime.now().year.toString();

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
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });
    await authController.login(yearController.text, usernameController.text,
        passwordController.text, '');
    setState(() {
      isLoading = false;
    });
  }

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
                          enabled:
                              connectivityController.connectivityState.value,
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
                          enabled:
                              connectivityController.connectivityState.value,
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
                          enabled:
                              connectivityController.connectivityState.value,
                        ),
                        obscureText: _obscureText,
                        style: const TextStyle(fontSize: 14),
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return ElevatedButton(
                        onPressed:
                            (connectivityController.connectivityState.value &&
                                    !isLoading)
                                ? _login
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        child: isLoading
                            ? const CustomLoadingAnimation()
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
            ],
          ),
        ),
      ),
    );
  }
}

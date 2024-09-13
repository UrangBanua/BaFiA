import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../services/tutorial_service.dart';
import 'custom_overboard_controller.dart';

class CustomOverboard extends StatelessWidget {
  final CustomOverboardController controller =
      Get.put(CustomOverboardController());
  final TutorialService tutorialService = TutorialService();

  CustomOverboard({super.key});

  @override
  Widget build(BuildContext context) {
    _setupTutorialAggrement();
    return Obx(() => controller.isFirstLaunch.value
        ? IntroSlider(
            key: const Key('intro_slider'),
            listContentConfig: controller.listContentOverboard,
            onDonePress: controller.onDonePress,
            isShowSkipBtn: false,
          )
        : Container());
  }

  // Setup tutorial Aggrement
  void _setupTutorialAggrement() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      controller.keyAgreed,
      'Persetujuan Kebijakan Privasi dan Ketentuan Layanan.',
      title: 'Aggrement', // Title for this target
      align: ContentAlign.top,
      icon: Icons.center_focus_strong_sharp,
    );
  }
}

import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  List<TargetFocus> targets = [];
  final GetStorage storage = GetStorage();
  TutorialCoachMark? _tutorialCoachMark; // Tambahkan properti ini

  // Method untuk menambahkan target tutorial
  void addTarget(GlobalKey key, String description,
      {ContentAlign align = ContentAlign.bottom,
      TextStyle? titleTextStyle,
      TextStyle? descriptionTextStyle,
      Color? customColor,
      ShapeLightFocus? shape,
      BorderSide? borderSide,
      IconData? icon,
      String? title}) {
    targets.add(
      TargetFocus(
        identify: key.toString(),
        keyTarget: key,
        color: customColor ??
            Colors.black, // Apply custom color or default to black
        shape: shape,
        borderSide: borderSide,
        contents: [
          TargetContent(
            align: align,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) Icon(icon, color: Colors.white),
                if (title != null)
                  Text(
                    title,
                    style: titleTextStyle ??
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                  ),
                Text(
                  description,
                  style: descriptionTextStyle ??
                      const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk memulai tutorial
  void showTutorial(
    BuildContext context, {
    String? tutorialName, // Make tutorialName optional
    VoidCallback? onFinish,
    Color colorShadow = Colors.black,
    String textSkip = "LEWATI",
    double paddingFocus = 10,
    Function(TargetFocus)? onClickTarget,
    int delayInSeconds = 0, // New parameter for delay
  }) {
    // Check if the tutorial has already been shown
    if (tutorialName != null) {
      bool hasShown = storage.read(tutorialName) ?? false;
      if (hasShown) {
        return;
      }
    }

    Future.delayed(Duration(seconds: delayInSeconds), () {
      _tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        colorShadow: colorShadow,
        textSkip: textSkip,
        paddingFocus: paddingFocus,
        onFinish: () {
          // Mark the tutorial as shown
          if (tutorialName != null) {
            storage.write(tutorialName, true);
            LoggerService.logger
                .i("Tutorial $tutorialName has been shown and marked as done");
          }
          if (onFinish != null) {
            onFinish();
          }
        },
        onClickTarget: onClickTarget ?? (target) {},
      );

      // ignore: use_build_context_synchronously
      _tutorialCoachMark?.show(context: context);
    });
  }

  // Method untuk membersihkan targets (jika ingin mengulang tutorial)
  void clearTargets() {
    targets.clear();
  }

  // Method untuk membatalkan tutorial
  void cancelTutorial() {
    _tutorialCoachMark?.hideSkip;
  }
}

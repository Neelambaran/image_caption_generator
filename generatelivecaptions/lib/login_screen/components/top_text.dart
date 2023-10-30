import 'package:flutter/material.dart';
import 'package:generatelivecaptions/login_screen/animations/change_screen_animation.dart';
import 'package:generatelivecaptions/utils/helper_functions.dart';

import 'login_content.dart';

class TopText extends StatefulWidget {
  const TopText({Key? key}) : super(key: key);

  @override
  State<TopText> createState() => _TopTextState();
}

class _TopTextState extends State<TopText> {
  @override
  void initState() {
    ChangeScreenAnimation.topTextAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HelperFunctions.wrapWithAnimatedBuilder(
      animation: ChangeScreenAnimation.topTextAnimation,
      child: Text(
        ChangeScreenAnimation.currentScreen == Screens.createAccount
            ? '\nWelcome To \nAI Captions'
            : 'Welcome\nBack',
        style: const TextStyle(
          fontSize: 50,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

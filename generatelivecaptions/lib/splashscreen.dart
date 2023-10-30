import 'dart:async';

import 'package:flutter/material.dart';

import 'home.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.run(() {
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => const Home(),
      //   ),
      // );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Text Generator",
            style: TextStyle(fontSize: 20),
          ),
          // image: Image.asset('assets/notepad.png'),
        ],
      ),
    ));
  }
}

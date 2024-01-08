import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/pages/Authentication/login.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // logo
        Padding(
          padding: const EdgeInsets.only(
              left: 40.0, right: 40.0, bottom: 2.0, top: 90.0),
          child: Container(
            height: 210,
            child: Image.asset(
              "lib/images/app_image.png",
              fit: BoxFit.cover,
            ),
          ),
        ),

        // we deliver groceries at your doorstep
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "We deliver groceries at your doorstep",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 36,
            ),
          ),
        ),

        // fresh items everyday
        Text(
          "Fresh items everyday",
          style: TextStyle(color: Colors.grey[600]),
        ),

        const Spacer(),

        // get started button
        GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const LoginScreen();
          })),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(24),
            child: const Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),

        const Spacer(),
        const Spacer()
      ]),
    );
  }
}

// ignore_for_file: sized_box_for_whitespace

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hey_chats/screens/introScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class Four0Four extends StatelessWidget {
  const Four0Four({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('404 page '),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset('assets/images/404.webp'),
              // const SizedBox(height: 5),
              Card(
                margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'it seems that you didn\'t complete with your profile last time, or you are lost somewhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.secondary,
                margin: const EdgeInsets.only(top: 8, left: 25, right: 25),
                elevation: 10,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.5, vertical: 4),
                  child: Text(
                    'please go back to login page and complete your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const IntroScreen(),
                  ));
                },
                child: const Text('Go back to Login page'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// FlutterPhoneDirectCaller.callNumber('+919743176021');
// launch('tel:+918867634725');
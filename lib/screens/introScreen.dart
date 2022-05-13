import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hey_chats/models/userModel.dart';
import 'package:hey_chats/screens/emailLoginScreen.dart';
import 'package:hey_chats/screens/phoneScreen.dart';
import 'package:hey_chats/screens/profileScreen.dart';
import 'package:hey_chats/utilities/showDialogBox.dart';

import '../widgets/signInTile.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserCredential userCred;
    String email;

    Future<void> signInWithGoogle() async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        email = googleUser.email;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCred.user;
        final newUser = UserModel(
          uid: user!.uid,
          fullName: '',
          email: email,
          profilePic: '',
          phone: '',
          about: '',
          success: false,
        );
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap())
            .then((value) => {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      firebaseUser: user,
                      userModel: newUser,
                    ),
                  )),
                });
      } else {
        kshowErrorDialog(
          errorMessage: 'please choose any of your google accounts to proceed.',
          context: context,
        );
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: _controller.value,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 15,
                  margin: const EdgeInsets.all(30),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/images/introImage.webp',
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _controller.value,
                child: SignInTile(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PhoneScreen(),
                    ));
                  },
                  imageName: 'phone.webp',
                  textMessage: 'sign in with phone',
                ),
              ),
              Opacity(
                opacity: _controller.value,
                child: SignInTile(
                  onPressed: () {
                    signInWithGoogle();
                  },
                  imageName: 'google.png',
                  textMessage: 'sign in with google',
                ),
              ),
              Opacity(
                opacity: _controller.value,
                child: SignInTile(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EmailLogin(),
                    ));
                  },
                  imageName: 'email.jpeg',
                  textMessage: 'sign in with e-mail',
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hey_chats/screens/FourOFourScreen.dart';
import 'package:hey_chats/screens/introScreen.dart';
import 'package:hey_chats/utilities/firebaseHelper.dart';
import 'package:uuid/uuid.dart';

import './models/userModel.dart';
import './screens/homeScreen.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FocusManager.instance.primaryFocus?.unfocus();

  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? userModel;

  if (currentUser != null) {
    userModel = await FireBaseHelper.getUserModelByUid(currentUser.uid);
    if (userModel != null) {
      if (userModel.uid != null && userModel.success == true) {
        runApp(MyAppLoggedIn(userModel: userModel, firebaseUser: currentUser));
      } else {
        runApp(MyApp(const Four0Four()));
      }
    } else {
      runApp(MyApp(const IntroScreen()));
    }
  } else {
    runApp(MyApp(const IntroScreen()));
  }
}

class MyApp extends StatelessWidget {
  MyApp(this.screen);
  dynamic screen;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      theme: ThemeData(
        canvasColor: const Color.fromARGB(255, 255, 239, 190),
        primaryColor: Colors.pink,
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(
          secondary: Colors.purple,
        ),
      ),
      home: screen,
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      theme: ThemeData(
        canvasColor: const Color.fromARGB(255, 255, 239, 190),
        primaryColor: Colors.pink,
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(
          secondary: Colors.purple,
        ),
      ),
      home: HomeScreen(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

// drawerScrimColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
//       endDrawer: Container(
//         color: Colors.pink,
//         width: 100,
//         height: 100,
//       ),
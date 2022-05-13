import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_chats/screens/homeScreen.dart';
import 'package:hey_chats/screens/profileScreen.dart';
import 'package:hey_chats/utilities/showDialogBox.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../models/userModel.dart';

class EmailLogin extends StatefulWidget {
  static const String routeName = '/authScreen';
  @override
  State<EmailLogin> createState() => _AuthScreenState();
}

enum AuthMode { login, signUp }

class _AuthScreenState extends State<EmailLogin> {
  AuthMode _authMode = AuthMode.login;
  String _email = '';
  String _confirmPwd1 = '';
  String _confirmPwd2 = '';
  bool _isError = false;
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();

  //======================== save form ===================================
  void _saveForm() async {
    final _auth = FirebaseAuth.instance;
    UserCredential? userCred;

    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      setState(() => _isError = true);
      return;
    }
    setState(() => _isError = false);
    _form.currentState?.save();

    if (_authMode == AuthMode.login) {
      // log user in =============
      try {
        setState(() => _isLoading = true);
        userCred = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _confirmPwd1,
        );
      } on FirebaseAuthException catch (error) {
        setState(() => _isLoading = false);
        kshowErrorDialog(errorMessage: error.code, context: context);
      } catch (err) {
        setState(() => _isLoading = false);
        kshowErrorDialog(
          errorMessage:
              'Something went wrong, please try again after some time.',
          context: context,
        );
      }

      if (userCred != null) {
        String uid = userCred.user!.uid;
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomeScreen(
            firebaseUser: userCred!.user!,
            userModel: userModel,
          ),
        ));
      }
    } else {
      try {
        // signup user =============
        setState(() => _isLoading = true);
        userCred = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _confirmPwd1,
        );
      } on FirebaseAuthException catch (error) {
        setState(() => _isLoading = false);
        kshowErrorDialog(errorMessage: error.code, context: context);
      } catch (err) {
        setState(() => _isLoading = false);
        kshowErrorDialog(
          errorMessage:
              'Something went wrong, please try again after some time.',
          context: context,
        );
      }

      if (userCred != null) {
        String uid = userCred.user!.uid;
        final newUser = UserModel(
          uid: uid,
          fullName: '',
          email: _email,
          profilePic: '',
          phone: '',
          about: '',
          success: false,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(newUser.toMap());
        setState(() => _isLoading = false);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(
            firebaseUser: userCred!.user!,
            userModel: newUser,
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      drawerScrimColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
      endDrawer: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.pink,
        width: 150,
        height: 150,
        child: const SingleChildScrollView(
          child: Text(
            'please make sure that you have entered a valid email bcz your friends make loose track of you and care to remember your password.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('login with email credentials'),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(208, 145, 250, 1),
                  Theme.of(context).primaryColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(17),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 10,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(255, 255, 236, 180),
                        ),
                        child: Text(
                          'please make sure to enter a valid email.',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          color: const Color.fromARGB(132, 255, 251, 251),
                        ),
                        padding: const EdgeInsets.all(13),
                        height: _authMode == AuthMode.signUp
                            ? _isError
                                ? _deviceSize.height * 0.51
                                : _deviceSize.height * 0.42
                            : _isError
                                ? _deviceSize.height * 0.4
                                : _deviceSize.height * 0.345,
                        child: Form(
                          key: _form,
                          child: ListView(
                            //_deviceSize.height * 0.42
                            children: [
                              TextFormField(
                                // ---------------------------------1-------------------
                                validator: (value) {
                                  if (value == null) {
                                    return 'please provide your email.';
                                  } else if (!value.contains('@')) {
                                    return 'please provide a valid email address.';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'email address',
                                  hintText: 'eg:  san.sangamesh96@gmail.com',
                                ),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  _email = value.trim();
                                },
                              ),
                              TextFormField(
                                // ---------------------------------2-------------------
                                validator: (value) {
                                  if (value == null) {
                                    return 'please provide your password.';
                                  } else if (value.length <= 5) {
                                    return 'password should be atleast 6 characters long.';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                  hintText: 'eg:  itsAsecret',
                                ),
                                textInputAction: _authMode == AuthMode.login
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                onChanged: (value) {
                                  _confirmPwd1 = value;
                                },
                                onFieldSubmitted: _authMode == AuthMode.login
                                    ? (_) => _saveForm()
                                    : null,
                              ),
                              if (_authMode == AuthMode.signUp)
                                TextFormField(
                                  // ---------------------------------3-------------------
                                  validator: (value) {
                                    if (value == null) {
                                      return 'please provide your password.';
                                    } else if (value.length <= 5) {
                                      return 'password should be atleast 6 characters long.';
                                    } else if (_confirmPwd1 != _confirmPwd2) {
                                      return 'both passwords should be same.';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'password',
                                    hintText: 'eg:  itsAsecret',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: (value) {
                                    _confirmPwd2 = value;
                                  },
                                  onFieldSubmitted: _authMode == AuthMode.signUp
                                      ? (_) => _saveForm()
                                      : null,
                                ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  //--------------------elevated---------------------------
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      _saveForm();
                                    },
                                    icon: const Icon(Icons.login_rounded),
                                    label: Text(
                                      _authMode == AuthMode.login
                                          ? 'Login'
                                          : 'Sign up',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  //-------------------below row-------------------------
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _authMode == AuthMode.login
                                            ? 'don\'t have an account ?'
                                            : 'i already have an account',
                                      ),
                                      const SizedBox(width: 15),
                                      TextButton(
                                        child: Text(
                                          _authMode == AuthMode.login
                                              ? 'Sign up'
                                              : 'Login',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (_authMode == AuthMode.login) {
                                            setState(() =>
                                                _authMode = AuthMode.signUp);
                                          } else if (_authMode ==
                                              AuthMode.signUp) {
                                            setState(() =>
                                                _authMode = AuthMode.login);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

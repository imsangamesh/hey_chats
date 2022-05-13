import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_chats/screens/profileScreen.dart';
import 'package:hey_chats/utilities/showDialogBox.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../models/userModel.dart';

class PhoneScreen extends StatefulWidget {
  static const String routeName = '/authScreen';
  @override
  State<PhoneScreen> createState() => _AuthScreenState();
}

enum Mode { submit, verify }

class _AuthScreenState extends State<PhoneScreen> {
  Mode _mode = Mode.submit;
  bool _isError = false;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  CountryCode countryCode = CountryCode(code: 'IN', dialCode: '+91');
  final _form = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationIDrec;

  UserCredential? userCredential;
  String finalPhone = '';

  //======================== save form ===================================
  void _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      setState(() => _isError = true);
      return;
    }
    setState(() => _isError = false);
    _form.currentState?.save();
    finalPhone = '$countryCode${_phoneController.text}';

    setState(() => _mode = Mode.verify);
    setState(() => _isLoading = true);

    _auth.verifyPhoneNumber(
      phoneNumber: finalPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() => _isLoading = false);
        // log('-----------login success fullly-------------------');
      },
      verificationFailed: (FirebaseAuthException exception) async {
        setState(() => _mode = Mode.submit);
        setState(() => _isLoading = false);
        kshowErrorDialog(
          errorMessage: exception.code,
          context: context,
          body: exception.toString(),
        );
        // log('-----------exception-----------${exception.code}');
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() => _isLoading = false);
        setState(() => verificationIDrec = verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) async {
        setState(() => _isLoading = false);
        setState(() => verificationIDrec = verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
    // log('$finalPhone ----------------------');
  }

  //======================== verify number ===================================
  void verifyPhoneNumber() async {
    if (_otpController.text == '' || _otpController.text.length != 6) {
      kshowErrorDialog(
        errorMessage: 'please make sure that you have entered otp correctly.',
        context: context,
      );
      return;
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationIDrec,
      smsCode: _otpController.text,
    );
    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      String uid = userCredential.user!.uid;
      final newUser = UserModel(
        uid: uid,
        fullName: '',
        email: '',
        profilePic: '',
        phone: finalPhone,
        about: '',
        success: false,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then(
        (value) {
          setState(() => _isLoading = false);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(
              firebaseUser: userCredential.user!,
              userModel: newUser,
            ),
          ));
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      kshowErrorDialog(
        errorMessage: 'sorry, something went wrong, please try again later.',
        context: context,
      );
      // log('-----------------${e.toString()}');
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('login with phone credentials'),
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
            padding: const EdgeInsets.all(30),
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
                          'please make sure to enter valid country code.',
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 13,
                        ),
                        height: _isError ? 200 : 170,
                        child: Form(
                          key: _form,
                          child: ListView(
                            //_deviceSize.height * 0.42
                            children: [
                              if (_mode == Mode.submit)
                                TextFormField(
                                  // ------------------------------phone---------------
                                  validator: (value) {
                                    if (value == null) {
                                      return 'please provide your phone number.';
                                    } else if (value.length != 10) {
                                      return 'your number must be 10 digits long.';
                                    } else if (double.tryParse(value) == null) {
                                      return 'please provide a valid phone number.';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'phone number',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.phone,
                                ),
                              if (_mode == Mode.verify)
                                TextFormField(
                                  // -------------------------------otp-----------------
                                  validator: (value) {
                                    if (value == null) {
                                      return 'please provide the otp received.';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _otpController,
                                  decoration: const InputDecoration(
                                    labelText: 'otp you received now',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  //--------------------elevated---------------------------
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: CountryCodePicker(
                                          onChanged: (code) {
                                            countryCode = code;
                                          },
                                          initialSelection: '+91',
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          _mode == Mode.submit
                                              ? _saveForm()
                                              : verifyPhoneNumber();
                                        },
                                        icon: const Icon(Icons.login_rounded),
                                        label: Text(
                                          _mode == Mode.submit
                                              ? 'Submit'
                                              : 'Verify',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                  //-------------------below row-------------------------
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('didn\'t receive otp'),
                                      const SizedBox(width: 15),
                                      TextButton(
                                        child: const Text('Resend'),
                                        onPressed: () {},
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

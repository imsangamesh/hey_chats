import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hey_chats/models/userModel.dart';
import 'package:hey_chats/screens/homeScreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../utilities/showDialogBox.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile-screen';

  final User firebaseUser;
  final UserModel userModel;

  const ProfileScreen({
    Key? key,
    required this.firebaseUser,
    required this.userModel,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  File? imageFile;
  bool isImage = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose a photo'),
            onTap: () {
              selectImage(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: const Text('Take a photo'),
            onTap: () {
              selectImage(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressQuality: 20,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (croppedImage != null) {
      isImage = true;
      setState(() => imageFile = croppedImage);
    }
  }

  void checkValues() {
    if (_nameController.text.trim() == '' ||
        _aboutController.text.trim() == '' ||
        _emailController.text.trim() == '' ||
        _phoneController.text.trim() == '' ||
        imageFile == null) {
      kshowErrorDialog(
        errorMessage:
            'please make sure that you have filled all the required fields to proceed.',
        context: context,
      );
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    try {
      setState(() => _isLoading = true);
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('profilePictures')
          .child(widget.userModel.uid!)
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      String imageUrl = await snapshot.ref.getDownloadURL();
      String fullName = _nameController.text.trim();

      widget.userModel.fullName = fullName;
      widget.userModel.about = _aboutController.text.trim();
      widget.userModel.email = _emailController.text.trim();
      widget.userModel.phone = _phoneController.text.trim();
      widget.userModel.profilePic = imageUrl;
      widget.userModel.success = true;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap())
          .then((value) {
        setState(() => _isLoading = false);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            ),
          ),
        );
      });
    } catch (e) {
      setState(() => _isLoading = false);
      kshowErrorDialog(
        errorMessage: e.toString(),
        context: context,
      );
    }
  }

  @override
  void initState() {
    _nameController.text = widget.userModel.fullName!;
    _aboutController.text = widget.userModel.about!;
    _emailController.text = widget.userModel.email!;
    _phoneController.text = widget.userModel.phone!;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('my profile'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                InkWell(
                  // ----------------circle Avatar----------------------
                  customBorder: const CircleBorder(),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    showPhotoOptions();
                  },
                  borderRadius: BorderRadius.circular(60),
                  splashColor: theme.primaryColor.withOpacity(0.5),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.primaryColor.withOpacity(0.25),
                    backgroundImage: isImage ? FileImage(imageFile!) : null,
                    child: imageFile == null
                        ? Icon(
                            Icons.add_a_photo_rounded,
                            size: 50,
                            color: theme.colorScheme.secondary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  // ----------------name----------------------
                  decoration: InputDecoration(
                    labelText: 'name',
                    hintText: 'eg:  Sangamesh',
                    icon: Icon(
                      Icons.person_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  readOnly: _nameController.text == '' ? false : true,
                ),
                TextField(
                  // ----------------about me----------------------
                  decoration: InputDecoration(
                    labelText: 'about me',
                    hintText: 'eg:  just levitating in thin air.',
                    icon: Icon(
                      Icons.notes_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  controller: _aboutController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  readOnly: _aboutController.text == '' ? false : true,
                ),
                TextField(
                  // ----------------e mail----------------------
                  decoration: InputDecoration(
                    labelText: 'e mail',
                    hintText: 'eg:  san@gmail.com.',
                    icon: Icon(
                      Icons.email_outlined,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: _emailController.text == '' ? false : true,
                ),
                TextField(
                  // ----------------phone number----------------------
                  decoration: InputDecoration(
                    labelText: 'phone number',
                    hintText: 'eg:  +91 8867634725',
                    icon: Icon(
                      Icons.phone_in_talk_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  controller: _phoneController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  readOnly: _phoneController.text == '' ? false : true,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  // ----------------elevated button----------------------
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      checkValues();
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

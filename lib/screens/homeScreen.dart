import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hey_chats/models/chatRoomModel.dart';
import 'package:hey_chats/screens/emailLoginScreen.dart';
import 'package:hey_chats/screens/chatScreen.dart';
import 'package:hey_chats/screens/introScreen.dart';
import 'package:hey_chats/screens/searchScreen.dart';
import 'package:hey_chats/utilities/firebaseHelper.dart';
import 'package:hey_chats/utilities/showDialogBox.dart';

import '../models/userModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  final UserModel userModel;
  final User firebaseUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    void confirmLogout(String message) {
      kshowConfirmDialog(
        context: context,
        heading: message,
        leftFun: () async {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const IntroScreen(),
          ));
        },
        li: Icons.check,
        liName: 'YES',
        rightFun: () {
          Navigator.of(context).pop();
        },
        ri: Icons.close,
        riName: 'NO',
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('HeyChats'),
        actions: [
          IconButton(
            onPressed: () => confirmLogout(
              'Hey,  are you leaving already, rather you would have made more friends',
            ),
            icon: const Icon(
              Icons.logout_outlined,
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where('participants.${widget.userModel.uid}', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                if (chatRoomSnapshot.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      List<String> participants =
                          chatRoomModel.participants!.keys.toList();
                      participants.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                            FireBaseHelper.getUserModelByUid(participants[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData != null) {
                              UserModel targetUser = userData.data as UserModel;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withAlpha(100),
                                  backgroundImage:
                                      NetworkImage(targetUser.profilePic!),
                                ),
                                title: Text(
                                  targetUser.fullName.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: chatRoomModel.lastMessage != ''
                                    ? Text(
                                        chatRoomModel.lastMessage!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        'say hi to your new friend.',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        userModel: widget.userModel,
                                        targetUser: targetUser,
                                        firebaseUser: widget.firebaseUser,
                                        chatRoom: chatRoomModel,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                      child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/noUsers.webp'),
                        const SizedBox(height: 15),
                        const Text(
                          'No chats found!',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        const Text(
                          'add some...',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ));
                }
              } else if (snapshot.hasError) {
                return const Center(child: Text('an error occured !'));
              } else {
                return const Center(child: Text('No chats found!'));
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            isScrollControlled: true,
            barrierColor:
                Theme.of(context).colorScheme.secondary.withAlpha(100),
            context: context,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            builder: (context) {
              return SearchScreen(
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser,
              );
            },
          );
        },
        child: const Icon(Icons.person_search_rounded),
      ),
    );
  }
}

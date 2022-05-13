import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hey_chats/main.dart';

import 'package:hey_chats/models/chatRoomModel.dart';
import 'package:hey_chats/models/userModel.dart';
import 'package:hey_chats/screens/chatScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  final UserModel userModel;
  final User firebaseUser;

  @override
  State<SearchScreen> createState() => _HomeScreenState();
}

enum Search { name, email }

class _HomeScreenState extends State<SearchScreen> {
  TextEditingController searchEmailController = TextEditingController();
  TextEditingController searchNameController = TextEditingController();
  Search _searchMode = Search.name;

  @override
  void dispose() {
    super.dispose();
  }

  Future<ChatRoomModel?> getChatRoomModel(
      UserModel targetUser, int index) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      // log('-----------fetched------------'); // fetch the existing chatroom
      var docData = snapshot.docs[0].data() as Map<String, dynamic>;
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData);
      chatRoom = existingChatRoom;
    } else {
      // log('-----------created------------'); // create a new one
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: '',
        participants: {
          widget.userModel.uid!: true,
          targetUser.uid!: true,
        },
      );
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('SearchScreen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            top: 10,
            right: 15,
            bottom: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  //=======================textfield==========================
                  controller: _searchMode == Search.name
                      ? searchNameController
                      : searchEmailController,
                  decoration: InputDecoration(
                    labelText:
                        _searchMode == Search.name ? 'type name' : 'type email',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  //=======================buttons==========================
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchMode == Search.name
                              ? _searchMode = Search.email
                              : _searchMode = Search.name;
                        });
                      },
                      child: Text(
                        _searchMode == Search.name
                            ? 'search by email'
                            : 'search by name',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        FocusScope.of(context).unfocus();
                      },
                      child: const Text('search'),
                    ),
                    const SizedBox(width: 1),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          _searchMode == Search.name ? 'fullName' : 'email',
                          isGreaterThan: _searchMode == Search.name
                              ? searchNameController.text
                              : searchEmailController.text,
                        )
                        .where(
                          _searchMode == Search.name ? 'fullName' : 'email',
                          isNotEqualTo: _searchMode == Search.name
                              ? widget.userModel.fullName
                              : widget.userModel.email,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          if (dataSnapshot.docs.isNotEmpty) {
                            return ListView.builder(
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> userMap =
                                    dataSnapshot.docs[index].data()
                                        as Map<String, dynamic>;
                                UserModel searchedUser =
                                    UserModel.fromMap(userMap);
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withAlpha(100),
                                      radius: 25,
                                      child: Image.network(
                                        searchedUser.profilePic!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            ((context, error, stackTrace) {
                                          return const Icon(
                                              Icons.account_circle_rounded);
                                        }),
                                      ),
                                    ),
                                  ),
                                  title: Text(searchedUser.fullName.toString()),
                                  subtitle: Text(searchedUser.email.toString()),
                                  trailing: const Icon(
                                      Icons.keyboard_arrow_right_rounded),
                                  onTap: () async {
                                    ChatRoomModel? chatRoomModel =
                                        await getChatRoomModel(
                                      searchedUser,
                                      index,
                                    );
                                    if (chatRoomModel != null) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          targetUser: searchedUser,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser,
                                          chatRoom: chatRoomModel,
                                        ),
                                      ));
                                    }
                                  },
                                );
                              },
                            );
                          } else {
                            return Text(
                              'No users found ! search some...',
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return const Text('an error occured !');
                        } else {
                          return const Text('No results found !');
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
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

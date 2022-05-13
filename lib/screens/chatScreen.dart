import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:hey_chats/models/chatRoomModel.dart';
import 'package:hey_chats/models/messageModel.dart';
import 'package:hey_chats/models/userModel.dart';
import 'package:hey_chats/utilities/showDialogBox.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chatScreen';

  final UserModel userModel;
  final UserModel targetUser;
  final User firebaseUser;
  final ChatRoomModel chatRoom;

  const ChatScreen({
    Key? key,
    required this.userModel,
    required this.targetUser,
    required this.firebaseUser,
    required this.chatRoom,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final firestore = FirebaseFirestore.instance;
  TextEditingController msgController = TextEditingController();

  void sendMessage() async {
    String msg = msgController.text.trim();

    if (msg != '') {
      // send message
      MessageModel newMessage = MessageModel(
        msgId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatRoomId)
          .collection('messages')
          .doc(newMessage.msgId)
          .set(newMessage.toMap());
      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatRoomId)
          .set(widget.chatRoom.toMap());
      msgController.clear();
    }
  }

  void showCallConfirmDialog() {
    kshowConfirmDialog(
      context: context,
      heading: 'Hey, you wanna call ${widget.targetUser.fullName}',
      leftFun: () => Navigator.of(context).pop(),
      li: Icons.phone_disabled_rounded,
      liName: 'no',
      rightFun: () =>
          FlutterPhoneDirectCaller.callNumber(widget.targetUser.phone!),
      ri: Icons.phone_enabled_rounded,
      riName: 'call',
      body: 'phone: ${widget.targetUser.phone}',
    );
  }
  // FlutterPhoneDirectCaller.callNumber('+919743176021');
// launch('tel:+918867634725');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          splashColor: Theme.of(context).primaryColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(widget.targetUser.profilePic!),
              ),
              const SizedBox(width: 8),
              Text(widget.userModel.fullName!),
              const SizedBox(width: 13),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showCallConfirmDialog();
            },
            icon: const Icon(
              Icons.phone_in_talk_rounded,
            ),
          )
        ],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.chatRoom.chatRoomId)
                .collection('messages')
                .orderBy('createdOn', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    reverse: true,
                    itemCount: dataSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      final recMsgData = (dataSnapshot.docs[index].data()
                          as Map<String, dynamic>);
                      return messageTile(recMsgData, context);
                    },
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('an  occured !'),
                  );
                } else {
                  return const Center(
                    child: Text('say hi to  new friend !'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 1),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Theme.of(context).primaryColor.withAlpha(50),
          ),
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
            bottom: 4,
            top: 3,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: msgController,
                  decoration: const InputDecoration(
                    hintText: 'message',
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                onPressed: () {
                  sendMessage();
                  // FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget messageTile(Map<String, dynamic> recMsgData, BuildContext context) {
    int seconds = recMsgData['createdOn'].seconds;
    // log(seconds.toString());
    return Row(
      mainAxisAlignment: recMsgData['sender'] == widget.userModel.uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (recMsgData['sender'] == widget.userModel.uid)
          const SizedBox(width: 90),
        Flexible(
            child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 10,
          ),
          margin: const EdgeInsets.only(
            bottom: 2.9,
            left: 11,
            right: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: recMsgData['sender'] == widget.userModel.uid
                ? Theme.of(context).primaryColor.withAlpha(110)
                : Theme.of(context).colorScheme.secondary.withAlpha(120),
          ),
          child: Text(
            recMsgData['text'],
            softWrap: true,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          // ),
        )),
        if (recMsgData['sender'] != widget.userModel.uid)
          const SizedBox(width: 90),
      ],
    );
  }
}

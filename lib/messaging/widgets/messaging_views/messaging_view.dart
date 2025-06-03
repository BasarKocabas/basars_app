import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../message_box.dart';

class MessagingView extends StatelessWidget {


  final ScrollController scrollController;
  final String conversationID;
  final String currentUser;



  const MessagingView({
    super.key,
    required this.scrollController,
    required this.conversationID,
    required this.currentUser,
  });



  ListView buildMessageList(List<QueryDocumentSnapshot> messages) {
    List<Widget> messageBoxes = [];
    String oldSender = "";

    for (var message in messages) {
      var data = message.data() as Map<String, dynamic>;
      String sender = data['sender'];
      bool isCurrentUser = sender == currentUser;

      MainAxisAlignment alignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;

      SizedBox spacer = const SizedBox(height: 0);
      if (oldSender != sender) {
        if (oldSender.isNotEmpty) {
          spacer = const SizedBox(height: 15);
        }
        oldSender = sender;
      }

      messageBoxes.add(
        Column(
          children: [
            spacer,
            Row(
              mainAxisAlignment: alignment,
              children: [
                if (isCurrentUser) const SizedBox(width: 50),
                MessageBox(
                    name: "",
                    content: Text(
                      data['message'],
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                    timeStamp: data['timeStamp'] ?? Timestamp.now(),
                ),
                if (!isCurrentUser) const SizedBox(width: 50),
              ],
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      children: messageBoxes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: conversationID.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("conversations")
            .doc(conversationID)
            .collection("messages")
            .orderBy('timeStamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No messages to display."));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
              }
            });
            return buildMessageList(snapshot.data!.docs);
          }
        },
      )
          : const Center(child: Text("No conversation started.", style: TextStyle(color: Colors.white))),
    );
  }
}

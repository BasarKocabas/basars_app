import 'dart:ffi';

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



  SizedBox isSpacer(String sender, String oldSender){
    if (oldSender != sender && oldSender.isNotEmpty) return const SizedBox(height: 15);
    return SizedBox(height: 0);
  }

  Widget displayDate(String oldDate, String date, String today){
    if(oldDate == "" || oldDate != date){
      String currentDate = date;
      if(date == today) currentDate = "Bugün";
      else if(date == "${today.substring(0,8)}${int.parse(today.substring(8))-1}") currentDate = "Dün";
      return Card(
          color: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentDate,style: TextStyle(color: Colors.grey,fontSize: 16),),
                  SizedBox(width: 5,),
                  Icon(Icons.arrow_downward,size: 15, color: Colors.grey,)
                ],
              ))
      );
    }
    return SizedBox();

  }

  ListView buildMessageList(List<QueryDocumentSnapshot> messages) {
    List<Widget> messageBoxes = [];
    String oldSender = "";

    Timestamp ts;
    String oldDate = "";
    List<String> dateNtime;
    String today = Timestamp.now().toDate().toString().split(" ")[0];

    for (var message in messages) {
      var data = message.data() as Map<String, dynamic>;
      String sender = data['sender'];
      bool isCurrentUser = sender == currentUser;

      MainAxisAlignment alignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;

      SizedBox spacer = isSpacer(sender, oldSender);
      oldSender = sender;

      ts = data['timeStamp'] ?? Timestamp.now();
      dateNtime = ts.toDate().toString().split(" ");

      messageBoxes.add(
        Column(
          children: [
            spacer,
            displayDate(oldDate, dateNtime[0], today),
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
                    time: dateNtime[1],
                ),
                if (!isCurrentUser) const SizedBox(width: 50),
              ],
            ),
          ],
        ),
      );
      oldDate = dateNtime[0];
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

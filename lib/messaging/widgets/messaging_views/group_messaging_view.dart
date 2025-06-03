import 'package:basars_app/messaging/widgets/messaging_views/messaging_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../message_box.dart';

class GroupMessagingView extends MessagingView{


  GroupMessagingView({
    super.key,
    required super.scrollController,
    required super.conversationID,
    required super.currentUser,
  });

  final ValueNotifier<Map<String, String>> usernames = ValueNotifier({});

  Future<void> fetchUsername(String sender) async {
    if (usernames.value.containsKey(sender)) return; // Username already fetched

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(sender).get();
      String name = userDoc.exists ? userDoc['username'] ?? "" : "";

      usernames.value[sender] = name;  // ✅ Directly modify the map
      usernames.notifyListeners();     // ✅ Manually trigger UI update
    } catch (e) {
      usernames.value[sender] = "";    // Handle errors gracefully
      usernames.notifyListeners();
    }
  }


  @override
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
                ValueListenableBuilder<Map<String, String>>(
                  valueListenable: usernames,
                  builder: (context, userMap, child) {
                    String name = "";
                    if(sender != currentUser){
                      name = userMap[sender] ?? "";
                      if (name.isEmpty) {
                        fetchUsername(sender);
                      }
                    }
                    return MessageBox(
                      name: name,
                      content: Text(
                        data['message'],
                        style: const TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                      timeStamp: data['timeStamp'] ?? Timestamp.now(),
                    );
                  },
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


}
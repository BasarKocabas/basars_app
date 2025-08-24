import 'package:basars_app/messaging/widgets/contact_views/group_view.dart';
import 'package:basars_app/messaging/widgets/messaging_views/group_messaging_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/message_input_field.dart';
import 'base_message_page.dart';

class GroupPage extends BaseMessagePage{


  const GroupPage({
    super.key,
    required super.contactName, // Use Dart's super parameters
    required super.contactID,
    required super.conversationID,
  });

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends BaseMessagePageState<GroupPage>{


  @override
  Future<void> incrementNewMessageCount() async{
    QuerySnapshot<Map<String, dynamic>> members = await firebaseFirestore.collection("groups").doc(widget.contactID).collection("members").get();
    firebaseFirestore.runTransaction((transaction) async{
      for(var memberDoc in members.docs){
        if(memberDoc.id != currentUser){
          transaction.update(firebaseFirestore.collection("users").doc(memberDoc.id).collection("groups").doc(widget.contactID), {"newMessageCount":FieldValue.increment(1)});
        }
      }
    });
  }

  @override
  Future<void> resetNewMessageCount() async{
    await firebaseFirestore.collection("users").doc(currentUser).collection("groups").doc(widget.contactID).update({
      "newMessageCount":0
    });
  }

  @override
  Future<void> initOnlineConversationID() async{
    await firebaseFirestore.collection("groups").doc(widget.contactID).update({'conversationID': conversationID});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color:Colors.white)
        ),
        backgroundColor: Colors.black54,
        title: TextButton(
          child: Text(widget.contactName,style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 25),),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupView(groupName: widget.contactName, contactID: widget.contactID)));
          },
        ),
      ),
      body: Column(
        children: [
          GroupMessagingView(scrollController: scrollController, conversationID: conversationID, currentUser: currentUser),
          MessageInputField(messageFieldController: messageFieldController, sendMessage: sendMessage,scrollController: scrollController,),
        ],
      )
    );
  }

}
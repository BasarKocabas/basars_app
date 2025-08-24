import 'package:basars_app/messaging/widgets/contact_views/contact_view.dart';
import 'package:basars_app/messaging/widgets/messaging_views/messaging_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/message_input_field.dart';
import 'base_message_page.dart';


class ContactPage extends BaseMessagePage{


  const ContactPage({
    super.key,
    required super.contactName, // Use Dart's super parameters
    required super.contactID,
    required super.conversationID,
  });

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends BaseMessagePageState<ContactPage>{


  @override
  Future<void> incrementNewMessageCount() async{
    await firebaseFirestore.collection("users").doc(widget.contactID).collection("contacts").doc(currentUser).update({
      "newMessageCount":FieldValue.increment(1)
    });
  }

  @override
  Future<void> resetNewMessageCount() async{
    await firebaseFirestore.collection("users").doc(currentUser).collection("contacts").doc(widget.contactID).update({
      "newMessageCount":0
    });
  }

  @override
  Future<void> initOnlineConversationID() async{
    await firebaseFirestore.runTransaction((transaction) async{
      transaction.update( firebaseFirestore.collection("users").doc(currentUser).collection("contacts").doc(widget.contactID), {'conversationID': conversationID}); // only update the conversationID on current user
      transaction.set(firebaseFirestore.collection("users").doc(widget.contactID).collection("contacts").doc(currentUser), {
        'conversationID': conversationID,
        "newMessageCount":0
      });// set a contact document for the user's contact
    });
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactView(contactName: widget.contactName,)
              ));
            },
        ),
      ),
      body: Column(
        children: [
          MessagingView(scrollController: scrollController, conversationID: conversationID, currentUser: currentUser),
          MessageInputField(messageFieldController: messageFieldController, sendMessage: sendMessage,scrollController: scrollController,),
        ],
      ),
    );
  }


}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




abstract class BaseMessagePage extends StatefulWidget{
  final String contactName;
  final String contactID; //might be the groupID or the contactID
  final String conversationID;

  const BaseMessagePage({
    super.key,
    required this.contactName,
    required this.contactID,
    required this.conversationID,
  });

  @override
  BaseMessagePageState<BaseMessagePage> createState();

}

abstract class BaseMessagePageState<T extends BaseMessagePage> extends State<T>{


  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String _conversationID = "";
  TextEditingController messageFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();


  @protected
  String get currentUser => _currentUser;

  @protected
  FirebaseFirestore get firebaseFirestore => _firebaseFirestore;

  @protected
  String get conversationID => _conversationID;

  @override
  void initState() {
    _conversationID = widget.conversationID;
    super.initState();
  }

  @override
  void dispose() {
    resetNewMessageCount();
    scrollController.dispose();
    super.dispose();
  }


  //stuff that needs to be overwritten in sub-classes
  Future<void> initOnlineConversationID();

  Future<void> incrementNewMessageCount();

  Future<void> resetNewMessageCount();


  Future<void> initConversation() async {
    if (_conversationID == "") {
      // Create a new conversation
      var newConversation = _firebaseFirestore.collection("conversations").doc();
      // Store the conversation ID
      _conversationID = newConversation.id;
      // Update or set conversation ID in users' contacts subcollection
      try{
        await initOnlineConversationID();
        setState(() {});
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating conversation : $e")),
        );
      }
    }
  }


  Future<void> sendMessage(String text) async{
    await initConversation();
    try{
      await _firebaseFirestore.collection("conversations").doc(_conversationID).collection("messages").add(
          {
            'sender':_currentUser, // do we need to hold the id of the sender or just the name?
            'message':text,
            'timeStamp':FieldValue.serverTimestamp(),
          }
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending the message : $e")),
      );
    }
    try{
      await incrementNewMessageCount();
    }catch(e){
      print("Could not Increase newMessageCount");
    }

  }
}
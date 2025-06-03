
import 'package:basars_app/messaging/pages/contact_page.dart';
import 'package:basars_app/messaging/pages/group_page.dart';
import 'package:basars_app/account/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';


enum Options{addContacts,contacts,deleteContacts,createGroup}

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  FlutterSecureStorage storage = FlutterSecureStorage();

  List<PersonBox> contactWidgets = [];
  String username = "";
  Options selectedOption = Options.contacts;
  bool isSelectionMode = false;
  ValueNotifier<List<String>> selectedContacts = ValueNotifier([]);

  TextEditingController groupNameController = TextEditingController();
  TextEditingController addContactsController = TextEditingController();


  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState(){
    fetchInfo();
    super.initState();
  }

  void fetchInfo() async{
    try{
      DocumentSnapshot <Map<String, dynamic>> doc = await _firebaseFirestore.collection("users").doc(_currentUser).get();
      Map<String,dynamic>? data = doc.data();
      setState(() {
        username = data!['username'] ?? "No username";
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching the user info: $e")),
      );
    }
  }

  Future<void> signOut()async{
    try{
      await storage.delete(key: "email");
      await storage.delete(key: "password");
      await FirebaseAuth.instance.signOut();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  Future<void> addContacts(String contactID) async {
    if(contactID.isNotEmpty){
      try {
        DocumentSnapshot<Map<String, dynamic>> contactDoc = await _firebaseFirestore.collection("users").doc(contactID).get(); //if there a person exists in this id
        if (contactDoc.exists) {
          var contactInContactsDoc = await _firebaseFirestore.collection("users").doc(_currentUser).collection("contacts").doc(contactID).get(); // if that person is added to my contacts
          if (!contactInContactsDoc.exists) {
            await _firebaseFirestore.collection("users").doc(_currentUser).collection("contacts").doc(contactID).set({
              "conversationID" : "",
              "newMessageCount":0
            });
          }
        } else {
          // Handle case when the user is not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not found")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error on adding the contact: $e")),
        );
      }
    }
  }

  Future<void> deleteContacts() async {
    return;  // should think about the deleting logic.
  }

  Future<void> createGroup(List<String> members, String groupName) async {
    if(members.length > 1) {
      members.add(_currentUser);
      try{
        await _firebaseFirestore.runTransaction((transaction) async{
          var newGroup = _firebaseFirestore.collection('groups').doc();
          transaction.set(newGroup, {
            "name":groupName,
            "conversationID":"",
          });
          for (String s in members) {
            if(s == _currentUser){
              transaction.set(newGroup.collection("members").doc(s), {'role':'yönetici'});
            }else{
              transaction.set(newGroup.collection("members").doc(s), {'role':'sıradan'});
            }
            transaction.set(_firebaseFirestore.collection("users").doc(s).collection("groups").doc(newGroup.id),
                {'groupID':newGroup.id,"newMessageCount":0});
          }
        });
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gurup kurarken hata oldu: $e")));
      }
    }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("2 kişiden az gurup kuramazsınız.")));
    }
  }

  void turnOffSelectionMode(){
    if(isSelectionMode){
      setState(() {
        selectedOption = Options.contacts;
        selectedContacts.value = [];
        isSelectionMode = false;
      });
    }
  }

  List<Map<String, dynamic>> cachedContactsAndGroups = [];
  Stream<List<Map<String, dynamic>>> fetchContactsAndGroups(){
    final contactsStream = _firebaseFirestore.collection("users").doc(_currentUser).collection("contacts").snapshots().asyncMap((snapshot) async{
      List<Map<String, dynamic>> contacts = [];
      for(var doc in snapshot.docs){
        String contactID = doc.id;
        var contactDoc = await _firebaseFirestore.collection("users").doc(contactID).get();
        contacts.add({
          "id":contactID,
          "name":contactDoc.data()?["username"] ?? "Could not find the name",
          "conversationID":doc["conversationID"],
          "isGroup":false,
          "newMessageCount":doc["newMessageCount"]
        });
      }
      return contacts;
    });

    final groupsStream = _firebaseFirestore.collection("users").doc(_currentUser).collection("groups").snapshots().asyncMap((groupSnapshot) async {
      List<Map<String, dynamic>> groups = [];
      for (var doc in groupSnapshot.docs) {
        String groupID = doc["groupID"];
        DocumentSnapshot<Map<String, dynamic>> groupDoc = await _firebaseFirestore.collection("groups").doc(groupID).get();
        groups.add({
          "id": groupID,
          "name": groupDoc["name"],
          "conversationID": groupDoc["conversationID"],
          "isGroup": true,
          "newMessageCount":doc["newMessageCount"],
        });
      }
      return groups;
    });

    return Rx.combineLatest2(contactsStream, groupsStream, (contacts, groups) {
      cachedContactsAndGroups = [...contacts, ...groups];
      return cachedContactsAndGroups; // Combine both lists
    });
  }

  @override
  Widget build(BuildContext context) {
        return GestureDetector(
          onTap: (){
            turnOffSelectionMode();
          },
          child: Scaffold(
            backgroundColor: Colors.grey.shade800,
            appBar: AppBar(
              backgroundColor: Colors.black54,
              automaticallyImplyLeading: false,
              title: Text("BasarsAPP",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.green.shade400,fontSize: 25),),
              actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedOption = selectedOption == Options.contacts ? Options.addContacts : Options.contacts;
                      });
                    },
                    icon: const Icon(Icons.person_add_alt,size: 30,color: Colors.white,),
                  ),
                  IconButton(
                      onPressed: () async{
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey.shade700,
                              title:Text("Çıkmak istediğinizen emin misiniz?",style: TextStyle(color: Colors.white,fontSize: 20),),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async{
                                      await signOut();
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                    child: Text("Çıkış yap",style:  TextStyle(color: Colors.white),)
                                ),
                              ],
                            )
                        );
                      },
                      icon: Icon(Icons.exit_to_app_rounded,size: 30,color: Colors.white)
                  ),
                  PopupMenuButton<Options>(
                          iconSize: 30,
                          iconColor: Colors.white,
                          color: Colors.teal.shade600,
                          borderRadius: BorderRadius.circular(50),
                          onSelected: (Options option) async{
                            if(isSelectionMode) turnOffSelectionMode();
                            setState(() {
                              selectedOption = option;
                              isSelectionMode = true;
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
                            const PopupMenuItem<Options>(value: Options.deleteContacts, child: Text('Kaldır',style: TextStyle(color: Colors.white),)),
                            const PopupMenuItem<Options>(value: Options.createGroup, child: Text('Gurup Kur',style: TextStyle(color: Colors.white),)),
                          ],
                  ),
              ],
            ),

            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if(selectedOption == Options.addContacts)
                    SizedBox(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Expanded(child: TextField(
                              controller: addContactsController,
                              onSubmitted: (String s) async => await addContacts(s),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder( // Border when TextField is not focused
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder( // Border when TextField is focused
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey, width: 1),
                                ),
                                labelText: "Eklemek istediğiniz kişinin ID sini giriniz.",
                                labelStyle: TextStyle(color: Colors.white)
                              ),
                            )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.green
                                ),
                                onPressed: () {
                                  String s = addContactsController.text.trim();
                                  if(s.isEmpty){
                                    setState(() {
                                      selectedOption = Options.contacts;
                                    });
                                  }else{
                                    addContacts(s);
                                  }
                                }
                                , child: Icon(Icons.arrow_back,color: Colors.white,size: 30,)
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    color: Colors.blueGrey.shade700,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: SelectableText("Kullanıcı ID: $_currentUser",textAlign: TextAlign.center ,style: TextStyle(fontSize: 17,color: Colors.grey.shade400)),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: fetchContactsAndGroups(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && cachedContactsAndGroups.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white,));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Yalnızsın. Git birilerini ekle dostum."));
                      } else {
                        List<Map<String, dynamic>> contactsAndGroups = snapshot.data!;
                        return Expanded(
                          child: ListView.builder(
                              itemCount: contactsAndGroups.length,
                              itemBuilder: (context, int i) {
                                Map<String, dynamic> data = contactsAndGroups[i];
                                return PersonBox(
                                  thisUsername: username,
                                  contactName: data["name"],
                                  contactID: data["id"],
                                  conversationID: data["conversationID"],
                                  turnOffSelectionMode: turnOffSelectionMode,
                                  isSelectionMode: isSelectionMode,
                                  selectedContacts: selectedContacts,
                                  isGroup: data["isGroup"],
                                  newMessageCount: data["newMessageCount"],
                                );
                              }),
                        );
                      }
                    },
                  ),
                  if(selectedOption == Options.createGroup)
                    ElevatedButton(
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.teal,
                              title:Text("Gurup Adı",style: TextStyle(color: Colors.white),),
                              content: TextField(
                                controller: groupNameController,
                                decoration: InputDecoration(
                                    labelText: "Gurup adını giriniz",
                                    labelStyle: TextStyle(color: Colors.white)
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async{
                                        await createGroup(selectedContacts.value, groupNameController.text.trim());
                                        Navigator.of(context).pop();
                                        turnOffSelectionMode();
                                      },
                                      child: Text("Tamam")
                                ),
                              ],
                            )
                        );
                    },
                    child: Text("Gurubu Kur"),
                  ),
                  if(selectedOption == Options.deleteContacts)
                    ElevatedButton(
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.teal,
                              title:Text("Seçilen Kişileri silmek istediğinize emin misiniz?",style: TextStyle(color: Colors.white),),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async{
                                      await deleteContacts();
                                      Navigator.of(context).pop();
                                      turnOffSelectionMode();
                                    },
                                    child: Text("Tamam")
                                ),
                              ],
                            )
                        );
                      },
                      child: Text("Seçilen Kişileri Sil"),
                    ),
                ],
              ),
            ),
          ),
        );
  }
}



class PersonBox extends StatefulWidget {
  final bool isGroup;
  final String contactName;
  final String contactID;
  final String conversationID;
  final bool isSelectionMode;
  final ValueNotifier<List<String>> selectedContacts;
  final String thisUsername;
  final Function turnOffSelectionMode;
  final int newMessageCount;
  //final int newMessageCount;

  const PersonBox({
    super.key,
    required this.turnOffSelectionMode,
    required this.contactName,
    required this.contactID,
    required this.conversationID,
    required this.thisUsername,
    required this.isSelectionMode,
    required this.selectedContacts,
    required this.isGroup,
    required this.newMessageCount,
    //required this.newMessageCount,
  });

  @override
  State<PersonBox> createState() => _PersonBoxState();

}

class _PersonBoxState extends State<PersonBox>{
    bool isSelected = false;

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: (){
          if(widget.isSelectionMode){
            if(!widget.isGroup){
              if (isSelected) {
                widget.selectedContacts.value.remove(widget.contactID);
              } else {
                widget.selectedContacts.value.add(widget.contactID);
              }
              setState(() {
                isSelected = !isSelected;
              });
            }
            if (widget.selectedContacts.value.isEmpty) {
              widget.turnOffSelectionMode();
            }
          }else{
            if(widget.isGroup){
              Navigator.push(context, MaterialPageRoute(builder: (context) => GroupPage(
                contactName: widget.contactName,
                conversationID: widget.conversationID,
                contactID: widget.contactID,
              )
              )
              );
            }else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(
                contactName: widget.contactName,
                conversationID: widget.conversationID,
                contactID: widget.contactID,
              )
              )
              );
            }
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(  // all of the row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(  //user credentials only
                    children: [
                      SizedBox(width: 10,),
                      if(widget.isSelectionMode && !widget.isGroup)
                        Checkbox(value: isSelected, onChanged: null),// Hides checkbox when not in selection mode
                      CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.green,
                          child: widget.isGroup ? Icon(Icons.groups,size: 35,color: Colors.grey.shade200,):Icon(Icons.person,size: 35,color: Colors.grey.shade200,)
                      ),
                      SizedBox(width: 15,),
                      Text(widget.contactName,style: TextStyle(fontSize: 21,color: Colors.white),),
                    ],
                  ),
                  Row(
                    children: [
                      if(widget.newMessageCount != 0)
                        Card(
                          shape: CircleBorder(),
                          color: Colors.green,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${widget.newMessageCount}",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w900),),
                          ),
                        ),
                      SizedBox(width: 12,),
                    ],
                  ),
                ],
              ),
          ),
        ),
      );
    }
  }



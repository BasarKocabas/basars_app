import 'package:flutter/material.dart';

class ContactView extends StatelessWidget{
  final String contactName;


  const ContactView({
    super.key,
    required this.contactName,
  });


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
        backgroundColor: Colors.transparent,
        title: Text("Overview",style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 25)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              CircleAvatar(radius: 40,child: Icon(Icons.person,size: 50,),),
              SizedBox(height: 20,),
              Text(contactName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),)
            ],
          ),
        ),
      ),
    );
  }

}
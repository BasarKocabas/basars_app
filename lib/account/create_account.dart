
import 'package:basars_app/account/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountCreationPage extends StatefulWidget{
  const AccountCreationPage({super.key});

  @override
  State<AccountCreationPage> createState() =>_AccountCreationPageState();


}

class _AccountCreationPageState extends State<AccountCreationPage>{

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> createAccount(String username, String email, String password) async{
    var _firebaseFirestore = FirebaseFirestore.instance;
    try{
      var a = FirebaseAuth.instance;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (a.currentUser != null){
        _firebaseFirestore.collection("users").doc(a.currentUser!.uid).set(
            {
              'username':username,
            }
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating account $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Card(
          color: Color.fromARGB(255, 50, 200, 50),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("BasarSAPP",style: TextStyle(fontSize: 30,fontStyle: FontStyle.italic),),
          ),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.green),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Text("BasarSAPP a hoşgeldiniz! Ucube",style: TextStyle(fontSize: 25),),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                  labelText: "Username",
                  icon: Icon(Icons.person)
              ),
              controller: usernameController,
            ),
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                  labelText: "Email",
                  icon: Icon(Icons.person)
              ),
              controller: emailController,
            ),
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Password",
                icon: Icon(Icons.person),
              ),
              controller: passwordController,
            ),
          ),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async{
                  await createAccount(usernameController.text.trim(),emailController.text.trim(), passwordController.text.trim());
                  Navigator.push(context, MaterialPageRoute(builder:(context) => SignIn()));
                },
                child: Text("Create Account",style: TextStyle(fontSize: 20,decoration: TextDecoration.underline),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'create_account.dart';
import '../messaging/pages/home_page.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  FlutterSecureStorage storage = FlutterSecureStorage();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    loadCredentials(context);
    super.initState();
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'password', value: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in: $e")),
      );
    }
  }

  Future<void> loadCredentials(BuildContext context) async{
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    if(email != null && password != null){
      login(email, password, context);
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade600, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BasarSAPP",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 30,),
                Text(
                  "A simple but convenient messaging app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white,fontSize: 15),
                ),
                Text(
                  "😊",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white,fontSize: 30),
                ),
                SizedBox(height: 40),

                isLoading ? CircularProgressIndicator():Column(
                  children:[
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration("E-Mail", Icons.email_rounded),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration("Password", Icons.lock_rounded),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await login(emailController.text.trim(), passwordController.text.trim(),context);
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountCreationPage()));
                      },
                      child: Text(
                        "Create an account",
                        style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


InputDecoration inputDecoration(String hintText, IconData icon){
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    labelStyle: TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: Colors.white),
    filled: true,
    fillColor: Colors.black45,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Colors.grey,width: 1)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Colors.white,width: 1.5)),
  );
}

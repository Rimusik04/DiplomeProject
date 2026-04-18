import 'package:flutter/material.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class start_page extends StatelessWidget{
  const start_page ({super.key});
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        
      ),
      body:Center(
        child:Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/logo/logo.png"), 
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.only(top: 13 , right:  60, bottom: 13,left: 60),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 4,
            backgroundColor: Color(0xFFF3AB3F),
            textStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
          ),
          child:  const Text("Next"),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenWelcome', true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login_Page()),
            );
            
          }
          
        )
        ])
      ) ,
    
    );
  }
}
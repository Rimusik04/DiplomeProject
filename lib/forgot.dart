import 'package:flutter/material.dart';
// import 'login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Forgot extends StatefulWidget{
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<Forgot> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailcont = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

@override
void dispose() {
  _emailcont.dispose();
  super.dispose();
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      
      body:SafeArea(child:  SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: 
        Center(
          child: 
          Column(children: [
            Form(
              key: _formKey,
              child: 
              TextFormField(
                controller: _emailcont,
                decoration: InputDecoration(
                  filled: true , 
                  fillColor:Color.fromRGBO(233, 238, 242, 100) , 
                  border: OutlineInputBorder( 
                    borderRadius: BorderRadius.circular(14), 
                    borderSide: BorderSide.none 
                  ), 
                  labelText: "Email", 
                  labelStyle: TextStyle(color: const Color(0xFF828282)),            
                ),
                enableSuggestions: false,
                autofocus: false,
                validator: (value) {
                  if(value == null || value.isEmpty) return "Enter email";
                  if(!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) return "Invalid email";
                  return null;
                }
              ),
            ),
              SizedBox(height: 10,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.only(top: 13 , right:  60, bottom: 13,left: 60),
                  foregroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 4,
                  backgroundColor: Color(0xFFF3AB3F),
                  textStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send code'),
                onPressed: _isLoading ? null : () async  {
                  if (_formKey.currentState!.validate()) {
                    final email = _emailcont.text.trim();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      
                      Navigator.pop(context); 
                      _showSnackBar('Код отправлен на $email');
                      _emailcont.clear(); 
                      
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                      
                    } on FirebaseAuthException catch (e) {
                      Navigator.pop(context); 
                      
                      String errorMessage;
                      if (e.code == 'user-not-found') {
                        errorMessage = 'Пользователь с таким email не найден';
                      } else if (e.code == 'invalid-email') {
                        errorMessage = 'Некорректный email';
                      } else {
                        errorMessage = 'Ошибка: ${e.message}';
                      }
                      
                      _showSnackBar(errorMessage, isError: true);
                    }
                  }
                }

                
              ),
          ]
          )
        )
      )
      )
    );
  }
}




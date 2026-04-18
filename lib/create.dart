import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class creat_page extends StatefulWidget{
  const creat_page ({super.key});

  @override
  State<creat_page> createState() => _create_Page();
}

class _create_Page extends State<creat_page>{
  final TextEditingController _name =TextEditingController();
  final TextEditingController _email =TextEditingController();
  final TextEditingController _password =TextEditingController();
  final TextEditingController _confpassword =TextEditingController();
  final _Fkey =GlobalKey<FormState>();
  bool _eye = true;
  bool _eye2 = true;

  @override
  void dispose() {
    _name.dispose(); 
    _email.dispose();
    _password.dispose();
    _confpassword.dispose();
    super.dispose();
  }

  // Future<void> _saveUserToFirestore(User user, String name) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //       'uid': user.uid,
  //       'name': name,
  //       'email': user.email,
  //       'createdAt': FieldValue.serverTimestamp(), 
  //       'lastLogin': FieldValue.serverTimestamp(),
  //       'photoURL': user.photoURL ?? '',
  //     }, SetOptions(merge: true)); 
      
  //     print('Пользователь сохранён в Firestore');
  //   } catch (e) {
  //     print('Ошибка сохранения в Firestore: $e');
  //     // Не показываем ошибку пользователю
  //   }
  // }
Future<void> _saveUserToFirestore(User user,String name ) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': _name.text.trim(),  
      'photoURL': null,            
      'gender': null,              
      'birthDate': null,           
      'phone': null,               
      'bio': null,                 
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Пользователь создан в Firestore');
  } catch (e) {
    print('❌ Ошибка сохранения в Firestore: $e');
  }
}
  Future<void> registerUser() async {
    if (!_Fkey.currentState!.validate()) {
      return;
    }

    String name = _name.text.trim(); 
    String email = _email.text.trim();
    String password = _password.text.trim();
    String confpassword = _confpassword.text.trim();
    
    // Проверка паролей
    if (password != confpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!, name);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account successfully created!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login_Page()),
      );

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      
      String errorMessage = "Registration error";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Email already in use";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, right: 30, bottom: 0, left: 30),
        width: screenwidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 33),
              Center(
                child: Column(
                  children: [
                    Image.asset("assets/logo/amico.png", width: 230),
                    SizedBox(height: 30),
                    Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: Color(0xFF1B384A),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 28),
                    Form(
                      key: _Fkey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(color: Color(0xFF828282)),
                              filled: true,
                              fillColor: Color(0xFFE9EEF2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Name cannot be empty";
                              } else if (value.length < 2) {
                                return "Min 2 characters";
                              }
                              return null;
                            },
                            controller: _name,
                          ),
                          SizedBox(height: 13),
                          
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Color(0xFF828282)),
                              filled: true,
                              fillColor: Color(0xFFE9EEF2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Enter email";
                              if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) 
                                return "Invalid email";
                              return null;
                            },
                            controller: _email,
                          ),
                          SizedBox(height: 13),
                          
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: Color(0xFF828282)),
                              filled: true,
                              fillColor: Color(0xFFE9EEF2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_eye ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _eye = !_eye;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Write Password";
                              } else if (value.length < 6) {
                                return "Min 6 characters";
                              }
                              return null;
                            },
                            controller: _password,
                            obscureText: _eye,
                            enableSuggestions: false,
                            autofocus: false,
                          ),
                          SizedBox(height: 13),
                          
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Confirm password",
                              labelStyle: TextStyle(color: Color(0xFF828282)),
                              filled: true,
                              fillColor: Color(0xFFE9EEF2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_eye2 ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _eye2 = !_eye2;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Repeat Password";
                              } else if (value.length < 6) {
                                return "Min 6 characters";
                              }
                              return null;
                            },
                            obscureText: _eye2,
                            controller: _confpassword,
                            enableSuggestions: false,
                            autofocus: false,
                          ),
                          SizedBox(height: 15),
                          
                          Container(
                            padding: EdgeInsets.only(right: 75, left: 75),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.only(
                                  top: 13,
                                  right: 60,
                                  bottom: 13,
                                  left: 60,
                                ),
                                foregroundColor: Colors.white,
                                shadowColor: Colors.black,
                                elevation: 4,
                                backgroundColor: Color(0xFFF3AB3F),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: registerUser,
                              child: Text("Signup"),
                            ),
                          ),
                          SizedBox(height: 23),
                          
                          Text(
                            "- Or login with -",
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset("assets/svg/Google.svg"),
                              ),
                              SizedBox(width: 19),
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset("assets/svg/FaceBook.svg"),
                              ),
                              SizedBox(width: 19),
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset("assets/svg/Aplle.svg"),
                              ),
                            ],
                          ),
                          SizedBox(height: 22),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(fontSize: 17),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const Login_Page()),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF326789),
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
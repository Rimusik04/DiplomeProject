import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socpet/Privacy.dart';
import 'package:socpet/forgot.dart';
import 'screens/main_page.dart';
// import 'package:login/start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create.dart';
// import 'models/login_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class Login_Page extends StatefulWidget{
  const Login_Page ({super.key});



   @override
  State<Login_Page> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<Login_Page> {
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenWelcome', false);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login error")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body:SingleChildScrollView(
        child: Center(

        child:Column(
        children : [
          Container(
            child: Row(
              children: [
                SizedBox(
                  height: 440,
                  child: 
                Stack(
                  alignment: Alignment.topCenter,
                  
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.black.withOpacity(0.25),
                          //   blurRadius: 70,
                          //   offset: const Offset(0, 8),
                          // ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/Subtract.svg',
                        width: screenwidth,
                        fit: BoxFit.contain,
                      ),
                    ),                    
                    Positioned(
                      bottom: 1,
                      child: 
                      Column (children:[ 
                        SvgPicture.asset(
                          'assets/svg/eye.svg',
                          fit: BoxFit.contain,
                        ),
                        // Image.asset(
                        //   "assets/logo/logo.png",
                        //   width: 85,
                        // ),
                      ]),
                    ),
                    
                  ],
                ),
                )
              ],
            ),
          ),
          Container(
          padding: const EdgeInsets.only(right: 36 , bottom: 16, left: 37 ),

          child: Column (
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
              // SizedBox(height: 20,),
            // Padding(
            //   padding: const EdgeInsets.only(top: -20),
            //   child: Image.asset(
            //     "assets/logo/logo.png",
            //     width: 80,
            //   ),
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[const   Text("HEY! \nLOGIN NOW",style: TextStyle(color:  Color(0xFF1B384A),fontSize: 32,fontWeight: FontWeight.w800),),]
            ),



            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
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
                    validator: (value) {
                      if(value == null || value.isEmpty) return "Enter email";
                      if(!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) return "Invalid email";
                      return null;
                    }

                  ),
                  SizedBox(height: 13,),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      filled: true , 
                      fillColor:Color.fromRGBO(233, 238, 242, 100) , 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(14), 
                        borderSide: BorderSide.none 
                      ), 
                      labelText: "Password", 
                      labelStyle: TextStyle(color: const Color(0xFF828282)),
                      suffixIcon: IconButton(
                        icon:Icon(_obscure ? Icons.visibility : Icons.visibility_off) ,
                        onPressed: (){
                          setState(() {
                            _obscure = ! _obscure;
                          });
                        },
                        
                      ),
                      
                      
                      
                    ),
                    obscureText: _obscure,
                    enableSuggestions: false,
                    autofocus: false,
                    validator: (value){
                      if (value==null||value.isEmpty){
                        return "Write the Password";
                      }
                      if (value.length < 6){
                        return "Min 6 characters";
                      }
                      return null;
                    }

                  ),
                  SizedBox(height: 14,),
                  Container(
                    padding: EdgeInsets.only(right: 75 , left: 75),
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(top: 13 , right:  60, bottom: 13,left: 60),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 4,
                        backgroundColor: Color(0xFFF3AB3F),
                        textStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : loginUser,
                      child:_isLoading ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 7,),
            TextButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Forgot()),
              );
            }, 
            child: Text("Forgote password?",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: const Color(0xFF326789),decoration: TextDecoration.underline),)),
            SizedBox(height: 20,),
            // думаю вид не очень
            // Text("- Or login with -",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
            //     SizedBox(height: 10,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     IconButton(onPressed: () {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (_) => const creat_page()),
            //       );
            //     },
            //     icon: SvgPicture.asset("assets/svg/Google.svg")),
            //     SizedBox(width: 19,),
            //     IconButton(onPressed: () {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (_) => const creat_page()),
            //       );
            //     }, icon: SvgPicture.asset("assets/svg/FaceBook.svg")),
            //     SizedBox(width: 19,),
            //     IconButton(onPressed: () {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (_) => const creat_page()),
            //       );
            //     }, icon: SvgPicture.asset("assets/svg/Aplle.svg")),
            //   ],
            // ),
            // SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?",style: TextStyle(fontSize: 17),),
                TextButton(onPressed: (){
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const creat_page()),
                );
                }, child: Text("Create new",style: TextStyle(fontSize: 17,color: const Color(0xFF326789),fontWeight: FontWeight.w500,decoration: TextDecoration.underline),)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Our policy",style: TextStyle(fontSize: 17),),
                TextButton(onPressed: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const policy()),
                );
                }, child: Text("Privacy Policy",style: TextStyle(fontSize: 17,color: const Color(0xFF326789),fontWeight: FontWeight.w500,decoration: TextDecoration.underline),)),
              ],
            ),
            SizedBox(height: 10,)
            ]
          ),
        ),
        ]
        ),
      ),
      )
    );
  }
}

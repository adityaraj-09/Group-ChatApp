import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/auth_service.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/auth/register.dart';
import 'package:insien_flutter/pages/head_page.dart';
import 'package:insien_flutter/widgets/widgets.dart';

import '../helper/helper_function.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final formkey=GlobalKey<FormState>();
  String email="";
  String password="";
  bool _isloading=false;
  Authservice authservice=Authservice();
  bool obscure=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_isloading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),): SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 50),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget> [
               const  Text("Insien",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),
                const Text("Login back to the insien",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                Image.asset("assets/login.png"),
                TextFormField(
                  decoration: textInputdec.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email,
                      color:Theme.of(context).primaryColor ,
                    )
                  ),
                  onChanged:(val){
                    setState(() {
                      email=val;
                    });
                  },
                  validator: (val){
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!)
                        ?null:"Please Enter a valid Email";
                  },
                ),
                const SizedBox(height: 15,),
                TextFormField(
                  obscureText: obscure,
                  decoration: textInputdec.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock,
                        color:Theme.of(context).primaryColor ,
                      ),
                    suffixIcon: InkWell(
                      onTap: (){
                        setState(() {
                          obscure=!obscure;
                        });
                      },
                      child: obscure?Icon(Icons.visibility,
                        color:Theme.of(context).primaryColor ,
                      ):Icon(Icons.visibility_off,
                        color:Theme.of(context).primaryColor ,
                      ),
                    ),
                  ),
                  validator: (val){
                    if(val!.length<6){
                      return "Password must be 6 characters long";
                    }else{
                      return null;
                    }
                  },
                  onChanged:(val){
                    setState(() {
                      password=val;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ) ,
                      child: const Text("Sign In",style: TextStyle(color:Colors.white,fontSize: 16),
                      ),onPressed: (){
                        login();
                  },
                  ),
                ),
                const SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Dont have an account?",
                  style: const TextStyle(color: Colors.black,fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Register here",
                      style:const TextStyle(color: Colors.black,
                      decoration: TextDecoration.underline) ,
                      recognizer: TapGestureRecognizer()..onTap=(){
                        nextScreenReplace(context,const RegisterPage());
                      }
                    )
                  ],

                ))

               
              ],
            ),
          ),
        ),
      ),
    );
  }
  login() async{
    if(formkey.currentState!.validate()){
      setState(() {
        _isloading=true;
      });
      await authservice.login( email, password).then((value) async{
        if(value==true){
         QuerySnapshot snapshot= await Database(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);
         await Helper.saveUserStatus(true);
         await Helper.saveUserEmail(email);
         await Helper.saveUserName(snapshot.docs[0]['Name']);
         await Helper.saveUserProfile(snapshot.docs[0]['profilePic']);
          nextScreenReplace(context,const HomePage());
        }else{
          showSnakbar(context, Colors.red, value);
          setState(() {
            _isloading=false;
          });
        }
      });
    }
  }
}

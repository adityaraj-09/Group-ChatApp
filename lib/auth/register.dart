
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/auth_service.dart';
import 'package:insien_flutter/auth/login.dart';
import 'package:insien_flutter/helper/helper_function.dart';
import 'package:insien_flutter/pages/home_page.dart';

import '../pages/head_page.dart';
import '../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isloading=false;
  final formkey=GlobalKey<FormState>();
  String email="";
  String password="";
  String name="";
  Authservice authservice=Authservice();
  bool obscure=true;
  String n="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):SingleChildScrollView(
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
                Text("$n Create your account  now to chat and explore  ",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                Image.asset("assets/register.png"),
                TextFormField(
                  decoration: textInputdec.copyWith(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person,
                        color:Theme.of(context).primaryColor ,
                      )
                  ),

                  onChanged:(val){
                    setState(() {
                      name=val;
                      n=val.toUpperCase();
                    });
                  },
                  validator: (val){
                    if(val!.isNotEmpty){
                      return null;
                    }else{
                      return "Name cannot be empty";
                    }
                  },
                ),
                const SizedBox(height: 15,),
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
                  obscureText: true,
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
                      return "Password must be 6 cahrcaters long";
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
                    child: const Text("Register",style: TextStyle(color:Colors.white,fontSize: 16),
                    ),onPressed: (){
                    register();
                  },
                  ),
                ),
                const SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Already have an account?",
                  style: const TextStyle(color: Colors.black,fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Login here",
                        style:const TextStyle(color: Colors.black,
                            decoration: TextDecoration.underline) ,
                        recognizer: TapGestureRecognizer()..onTap=(){
                          nextScreen(context, const LoginPage());
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
  register() async{
    if(formkey.currentState!.validate()){
      setState(() {
        _isloading=true;
      });
      await authservice.registeruser(name, email, password).then((value) async{
        if(value==true){
          await Helper.saveUserStatus(true);
          await Helper.saveUserEmail(email);
          await Helper.saveUserName(name);
          await Helper.saveUserProfile("");
          nextScreenReplace(context,const HeadPage());
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

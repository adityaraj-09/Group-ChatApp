import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insien_flutter/auth/login.dart';
import 'package:insien_flutter/helper/helper_function.dart';
import 'package:insien_flutter/pages/head_page.dart';
import 'package:insien_flutter/pages/home_page.dart';
import 'package:insien_flutter/shared/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebasemsgbg);
  runApp(const MyApp());
}


Future<void>firebasemsgbg(RemoteMessage message)async{
  await Firebase.initializeApp();
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isSigned=false;
  @override
  void initState() {
    super.initState();
    getUserLoggedStatus();
  }
  getUserLoggedStatus() async{
    await Helper.getUserLoggedStatus().then((value) => {
     if(value!=null){
       setState((){
         _isSigned=value;
       })
     }else{
       setState((){
         _isSigned=false;
       })
     }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent
        )
    );
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        primarySwatch:Colors.green,
        scaffoldBackgroundColor: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      home: _isSigned? const HeadPage(): const LoginPage(),
    );
  }
}


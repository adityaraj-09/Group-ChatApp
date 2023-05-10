import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/pages/chatgpt_page.dart';
import 'package:insien_flutter/pages/home_page.dart';
import 'package:insien_flutter/pages/profile_page.dart';
import 'package:insien_flutter/shared/constants.dart';

import '../Services/database_service.dart';
import '../Services/notification_service.dart';
import '../helper/helper_function.dart';

class HeadPage extends StatefulWidget {
  const HeadPage({Key? key}) : super(key: key);

  @override
  State<HeadPage> createState() => _HeadPageState();
}

class _HeadPageState extends State<HeadPage> {
  String email="";
  String userName="";
  int currentPageIndex=0;
  NotificationService notificationService=NotificationService();
  @override
  void initState() {

    super.initState();
    getData();
    notificationService.requestNotification();
    getToken();
    notificationService.isTokenRefresh();
    notificationService.firebaseInit();
  }
  getToken()async{
    notificationService.token().then((value){
      Database(uid: FirebaseAuth.instance.currentUser!.uid)
          .savingToken(value);
    });
  }
  getData()async{
    await Helper.getUserEmail().then((value){
      setState(() {
        email=value!;
      });
    });
    await Helper.getUserName().then((value){
      setState(() {
        userName=value!;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xffe1f5f4),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.groups),
            icon: Icon(Icons.groups_outlined),
            label: 'Groups',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',

          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.chat),
            icon: Icon(Icons.chat_outlined),
            label: 'ChatGPT',
          ),

        ],
      ),
      body: <Widget>[
        const HomePage(),
        ProfilePage(email: email, userName: userName),
        ChatGPT(userName: userName, email: email),
      ][currentPageIndex],
    );
  }
}

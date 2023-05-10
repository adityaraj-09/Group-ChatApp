

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:insien_flutter/Services/auth_service.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/Services/notification_service.dart';
import 'package:insien_flutter/auth/login.dart';
import 'package:insien_flutter/helper/helper_function.dart';
import 'package:insien_flutter/pages/chatgpt_page.dart';
import 'package:insien_flutter/pages/profile_page.dart';
import 'package:insien_flutter/pages/search_page.dart';
import 'package:insien_flutter/shared/constants.dart';
import 'package:insien_flutter/widgets/group_tile.dart';
import 'package:insien_flutter/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName="";
  String email="";
  String groupName="";
  Authservice authservice=Authservice();
  Stream? groups;
   bool _isloading=false;
   bool isvisible=false;
   bool exit=true;


  @override
  void initState() {

    super.initState();
    gettingUserData();


  }


  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }
  gettingUserData() async{
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
await Database(uid: FirebaseAuth.instance.currentUser!.uid)
    .getUserGroups().then((snapshot){
      setState(() {
        groups=snapshot;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       elevation: 1,
       backgroundColor: Colors.white,
       title:appbarTitle(),
     ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          pop(context);
        },
        elevation: 0,
        backgroundColor:Theme.of(context).primaryColor ,
        child: const Icon(Icons.add,color: Colors.white,size: 30,),
      ),
    );
  }

  pop(BuildContext context){
    Future.delayed(Duration.zero,(){
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isloading==true?Center(child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,),)
                    :Material(
                      color: Colors.transparent,
                      child: TextField(
                  onChanged: (val){
                      setState(() {
                        groupName=val;
                      });
                  },
                  style: const TextStyle(color:Colors.black ,fontSize: 25),
                  decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color:Colors.green),
                          borderRadius: BorderRadius.circular(20),
                        )
                  ),
                ),
                    ),
                Visibility(
                    visible:isvisible,
                    child: const Text("Enter group name",style: TextStyle(color: Colors.red),))
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Create"),
              onPressed: () async{
                if(groupName!=""){
                  setState(() {
                    _isloading=true;
                    isvisible=false;
                    Database(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete((){
                      _isloading=false;
                    });
                    Navigator.of(context).pop();
                    showSnakbar(context, Colors.green,"Group created successfully");
                  });
                }else{
                  setState((){
                    isvisible=true;
                  });
                }
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                 Navigator.of(context).pop();
                 setState((){
                   isvisible=false;
                 });
              },
            )
          ],
        ),
      );
    });
  }

  popUpDialog(BuildContext context){
    Future.delayed(Duration.zero,(){
      showDialog(
          barrierDismissible: false,
          context: context, builder: (context){
        return StatefulBuilder(
            builder: ((context,setState){
              return AlertDialog(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                title: const Text("Create a group",
                  textAlign: TextAlign.left,),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isloading==true?Center(child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,),)
                        :TextField(
                      onChanged: (val){
                        setState(() {
                          groupName=val;
                        });
                      },
                      style: const TextStyle(color:Colors.black ,fontSize: 25),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color:Colors.green),
                            borderRadius: BorderRadius.circular(20),
                          )
                      ),
                    ),
                    Visibility(
                      visible:isvisible,
                        child: const Text("Enter group name",style: TextStyle(color: Colors.red),))
                  ],
                ),
                actions: [
                  Row(
                    children: [
                      Padding(
                        padding:const EdgeInsets.only(left:20,),
                        child: ElevatedButton(onPressed: ()=>{
                          Navigator.of(context).pop(),
                          setState((){
                            isvisible=false;
                          })
                        },style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                          child: const Text("cancel"),

                        ),
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding:const EdgeInsets.only(right:20,),
                        child: ElevatedButton(onPressed: ()async{
                          if(groupName!=""){
                            setState(() {
                              _isloading=true;
                              isvisible=false;
                              Database(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName)
                                  .whenComplete((){
                                _isloading=false;
                              });
                              Navigator.of(context).pop();
                              showSnakbar(context, Colors.green,"Group created successfully");
                            });
                          }else{
                           setState((){
                             isvisible=true;
                           });
                          }
                        },style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                          child: const Text("create"),

                        ),
                      )
                    ],
                  ),

                ],
              );
            })
        );
      });
    });

  }
  groupList(){
    return StreamBuilder(
      stream: groups,
      builder: (context,AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['groups']!=null){
            if(snapshot.data['groups'].length!=0){
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context,index){
                    int reverseIndex=snapshot.data['groups'].length-index-1;
                    final item = snapshot.data['groups'][reverseIndex];
                  return Dismissible(
                    key: Key(item),
                    confirmDismiss: (direction) => promptUser(direction,getId(snapshot.data['groups'][reverseIndex]),getName(snapshot.data['groups'][reverseIndex]),snapshot.data['Name']),

                    background: Container(
                      padding: const EdgeInsets.all(10),

                      margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                      decoration: const BoxDecoration(
                          color: const Color(0xffe1f5f4),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30)
                        )
                      ),
                      child:Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 50),
                              child: Text(getName(snapshot.data['groups'][reverseIndex]).toUpperCase(),style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 25))),
                          Expanded(child: Container()),
                          Center(
                            child: Column(
                              children:  [
                                Icon(Icons.delete,color: Theme.of(context).primaryColor,size: 40,),
                                Text("Exit",style: TextStyle(color: Theme.of(context).primaryColor),)
                              ],
                            ),
                          )
                        ],
                      ) ,
                    ) ,
                    child: GroupTile(
                        groupId: getId(snapshot.data['groups'][reverseIndex]), groupName: getName(snapshot.data['groups'][reverseIndex]), userName: snapshot.data['Name']),
                  );
              });
            }else{
              return noGroupWidget();
            }
          }else{
            return noGroupWidget();
          }
        }else{
          return Center(child: CircularProgressIndicator(
            color:Theme.of(context).primaryColor,
          ),);
        }

      },
    );
  }
  Future<bool> promptUser(DismissDirection direction,String gid,String gname,String username) async {
    String action;
    if (direction == DismissDirection.startToEnd) {
      action = "exit the ";
    } else {
      action = "delete";
    }
    String gn=gname.toUpperCase();

    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text("Are you sure you want to exit  $gn?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text("Ok"),
            onPressed: () {
              Database(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroup(gid,username,gname)
                  .whenComplete(() {
              });
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              // Dismiss the dialog but don't
              // dismiss the swiped item
              return Navigator.of(context).pop(false);
            },
          )
        ],
      ),
    ) ??
        false; // In case the user dismisses the dialog by clicking away from it
  }
  noGroupWidget(){
    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 25) ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: popUpDialog(context),
              child: Icon(Icons.add_circle,color: Colors.grey[700],size: 75,)),
          const SizedBox(
            height: 20,
          ),
          const Text("You've not joined any group.tap on add icon to create a group or also search from top",
          textAlign: TextAlign.center,)

        ],
      ),
    );
  }
  appbarTitle(){
    return  Container(
      width: 230,
      height: 40,
      padding: const EdgeInsets.only(left: 5),
      decoration: const BoxDecoration(
        color: Color(0xffe1f5f4),
        borderRadius: BorderRadius.all(Radius.circular(30)),

      ),
      child: Row(
        children:  [
          GestureDetector(
            onTap: (){
              nextScreen(context,const SearchPage());
            },
              child:  Icon(Icons.search,color: Theme.of(context).primaryColor,)),
          const SizedBox(width: 5,),
          GestureDetector(
              onTap: (){
                nextScreen(context,const SearchPage());
              },
              child: const Text("Search groups and..",style: TextStyle(color: Colors.black54,fontSize:18),)),
          const SizedBox(width: 5,),
           Icon(Icons.mic,color: Theme.of(context).primaryColor,),
        ],
      ),
    );
  }
}
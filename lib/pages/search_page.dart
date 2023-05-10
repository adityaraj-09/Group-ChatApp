import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/helper/helper_function.dart';
import 'package:insien_flutter/pages/chat_page.dart';
import 'package:insien_flutter/widgets/widgets.dart';

import '../widgets/group_tile.dart';
import 'group_info.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller=TextEditingController();
  bool isloading=false;
  QuerySnapshot? searchSnapshot;
  Stream<QuerySnapshot>? groups;
  bool hasUserSearched=false;
  String username="";
  User? user;
  bool isJoined=false;
  @override
  void initState() {
    super.initState();
    getCurrentuid();
    getGroups();
  }
  getCurrentuid() async{
    await Helper.getUserName().then((value){
      setState(() {
        username=value!;
      });
    });
    user=FirebaseAuth.instance.currentUser;
  }

  getGroups() {
    Database().getGroup().then((val){
      setState(() {
        groups=val;
      });
    });
  }
  String getName(String t){
    return t.substring(t.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       centerTitle: true,
       elevation: 0,
       leading: IconButton(
           onPressed: (){
             Navigator.of(context).pop();
           },
           icon: const Icon(Icons.arrow_back_ios)),
       backgroundColor: Theme.of(context).primaryColor,
       title: const Text("Search",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Colors.white),),
     ),
      body:SingleChildScrollView(
        child: Column(
                children: [
                  Container(
                    height: 80,
                    color: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          controller: searchcontroller,
                          style: const TextStyle(
                              color: Colors.white
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search Groups...",
                            hintStyle: TextStyle(color: Colors.white,fontSize: 16),

                          ),
                        ),
                        ),
                        GestureDetector(
                          onTap:(){
                            initiateSearch();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(Icons.search,
                              color: Colors.white,),
                          ),
                        )
                      ],
                    ),
                  ),
                  isloading? Center(child: CircularProgressIndicator(
                    color:Theme.of(context).primaryColor ,),):groupList(),
                  const SizedBox(height: 10,),
                  const Text("Groups",style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:Colors.black,
                  ),textAlign: TextAlign.start,),
                  allGroups()

                ],
              ),
      ),

    );
  }
  initiateSearch() async{
    if(searchcontroller.text.isNotEmpty){
     setState(() {
       isloading=true;
     });
     await Database().search(searchcontroller.text).then((snapshot){
       setState(() {
         searchSnapshot=snapshot;
         isloading=false;
         hasUserSearched=true;
       });
     });
    }

  }
  allGroups(){
    return StreamBuilder(
        stream: groups,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data.docs.length!=0){
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)
                  )
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context,Index){
                      int index=snapshot.data.docs.length-Index-1;
                      return groupTile1(username, snapshot.data.docs[index]['groupId'], getName(snapshot.data.docs[index]['groupname']), snapshot.data.docs[index]['admin']);
                    }),
              );
            }else{
              return  Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    const Text("No message send in this group",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,),
                    Image.asset("assets/login.png"),
                  ],
                ),
              );
            }

          }else{
            return Container();
          }
    });
  }
  noGroupWidget(){
    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 25) ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text("You've not joined any group.tap on add icon to create a group or also search from top",
            textAlign: TextAlign.center,)
        ],
      ),
    );
  }
  groupList(){
    return hasUserSearched? ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context,index){
          return groupTile(
           username,
            searchSnapshot!.docs[index]['groupId'],
            searchSnapshot!.docs[index]['groupname'],
              searchSnapshot!.docs[index]['admin']
          );
        })
        :Container();
  }

  joined(String username,String gid,String groupname,String admin) async{
    await Database(uid: user!.uid).isUserJoined(groupname, gid, username).then((value){
      setState(() {
        isJoined=value;
      });
    });
  }


  Widget groupTile(String userName,String groupId,groupName,String admin){
    joined(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      leading: GestureDetector(
        onTap: (){
          nextScreen(context,GroupInfoPage(
            groupId: groupId,
            groupName:groupName,
            adminName: admin,
          ));
        },
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(groupName.substring(0,1).toUpperCase(),textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold),),
        ),
      ),
      title: Text(groupName,
        style: const TextStyle(fontWeight: FontWeight.w600),),
      subtitle: Text("Admin:${getName(admin)}"),
      trailing: InkWell(
        onTap: () async{
         await Database(uid: user!.uid).toggleGroup(groupId, userName, groupName);
         if(isJoined){
           setState(() {
             isJoined=!isJoined;
           });
           showSnakbar(context, Colors.green, "Joined the group");
           Future.delayed(const Duration(seconds: 2),(){
             nextScreen(context,ChatPage(groupId: groupId, groupName: groupName, userName: userName));
           });
         }else{
           setState(() {
             isJoined=!isJoined;
           });
           showSnakbar(context, Colors.red, " left the group $groupName");
         }
        },
        child: isJoined? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white,width: 1),
          ),
          padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
          child: const Text("Joined", style: TextStyle(color: Colors.white),),
        ) :Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Colors.white,width: 1),
          ),
          padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
          child: const Text("Join Now", style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
  Widget groupTile1(String userName,String groupId,groupName,String admin){

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      leading: GestureDetector(
        onTap: (){
          nextScreen(context,GroupInfoPage(
            groupId: groupId,
            groupName:groupName,
            adminName: admin,
          ));
        },
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(groupName.substring(0,1).toUpperCase(),textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold),),
        ),
      ),
      title: Text(groupName,
        style: const TextStyle(fontWeight: FontWeight.w600),),
      subtitle: Text("Admin:${getName(admin)}"),
    );
  }
}

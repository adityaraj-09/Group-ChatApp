import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/pages/home_page.dart';
import 'package:insien_flutter/pages/member_view.dart';
import 'package:insien_flutter/widgets/member_tile.dart';
import 'package:insien_flutter/widgets/widgets.dart';

import '../helper/helper_function.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfoPage({Key? key,required this.adminName,required this.groupName,required this.groupId}) : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Stream? members;
  String email="";
  String id="";
  String photo="";
  String mphoto="";
  String userName="";
  @override
  void initState() {
    super.initState();
    getMember();
    getGroupData();
    getData1();

  }
  getData1()async{
    await Helper.getUserName().then((value){
      setState(() {
        userName=value!;
      });
    });
  }
  getGroupData()async{
    await Database().getGroupData(widget.groupId).then((val){
      setState(() {
        photo=val['groupIcon'];
      });
    });
  }
  getMember() async{
    Database(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val){
          setState(() {
            members=val;
          });
    });
  }

  getData(String id)async{
    await Database().getData(id).then((value){
      setState(() {
        email=value["email"];
        mphoto=value['profilePic'];
      });
      return email;

    });


  }




  String getName(String t){
    return t.substring(t.indexOf("_")+1);
  }
  String adminId(String id){
    return id.substring(0,id.indexOf("_"));
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       centerTitle: true,
       backgroundColor: Theme.of(context).primaryColor,
       leading: IconButton(
           onPressed: (){
             Navigator.of(context).pop();
           },
           icon: const Icon(Icons.arrow_back_ios)),
       elevation: 0,
       title: Text(widget.groupName),
       actions: [
         IconButton(onPressed: (){
           showDialog(
               barrierDismissible: false,
               context: context, builder: (context){
             return AlertDialog(
               backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
               shape: const RoundedRectangleBorder(
                   borderRadius: BorderRadius.all(Radius.circular(20.0))),
               icon:const Icon(Icons.outbox_outlined,color: Colors.white,size: 50,),
               content: const Text("Are you share to exit the group?",style: TextStyle(color: Colors.white),),
               actions: [
                 IconButton(onPressed: (){
                   Navigator.pop(context);
                 }, icon: const Icon(Icons.cancel,color:Colors.red ,size: 40,)),
                 IconButton(onPressed: () async{
                   Database(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroup(widget.groupId,userName,widget.groupName)
                   .whenComplete(() {
                    nextScreenReplace(context,const HomePage());
                   });
                 }, icon: const Icon(Icons.done,color:Colors.green ,size: 40,)),
               ],
             );
           });
         }, icon:const Icon(Icons.exit_to_app))
       ],
     ),
      body: Container(
       padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [

            photo==""?CircleAvatar(
              radius: 75,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(widget.groupName.substring(0,1).toUpperCase()
                ,style:const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color:Colors.white
                ),),
            ): ClipOval(
              child: Image.network(photo,height: 150,width: 150,fit: BoxFit.cover,),
            ),
            const SizedBox(height: 10,),
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: Container(
                padding:const EdgeInsets.only(
                  left: 20,
                  top: 10,
                  bottom: 10,
                  right: 10
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(widget.groupName.substring(0,1).toUpperCase()
                      ,style:const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color:Colors.white
                        ),),
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.groupName.toUpperCase(),
                        style:const TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 15)),
                        const SizedBox(height: 10,),
                        Text("Admin: ${getName(widget.adminName)}",
                            style:const TextStyle(color: Colors.black,fontWeight: FontWeight.w500)),
                      ],
                    )
                  ],
                ),
              ),
            ),
             const SizedBox(height: 10,),
             const Text("Group Members",style: TextStyle(
               fontSize: 22,
               fontWeight: FontWeight.bold,
               color:Colors.black,
             ),textAlign: TextAlign.start,),
             memberList()

          ],
        ),
      ),

    );
  }
  memberList(){
    return StreamBuilder(
      stream: members,
        builder:(context,AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['members']!=null){
            if(snapshot.data['members'].length!=0){
              return Container(

                child: Column(

                  children: [
                    SizedBox(height: 10,),
                   Row(
                     children: [

                        const Text("Total Participants: ",style: TextStyle(
                         fontSize: 15,
                         color:Colors.black,
                       ),textAlign: TextAlign.start,),
                       Text(snapshot.data['members'].length.toString(),style: const TextStyle(
                         fontSize: 15,
                         fontWeight: FontWeight.bold,
                         color:Colors.black,
                       ),textAlign: TextAlign.start,),
                     ],
                   ),
                    SizedBox(height: 10,),
                    ListView.builder(
                        itemCount:snapshot.data['members'].length ,
                        shrinkWrap: true,
                        itemBuilder:(context,index) {
                          return MemberTile(id: getId(snapshot.data['members'][index]), name: getName(snapshot.data['members'][index]),adminid:adminId(widget.adminName),);

                        }),
                  ]
                ),
              );
            }else{
              return const Center(child: Text("No members"),);
            }

          }else{
            return const Center(child: Text("No members"),);
          }
        }else{
          return  Center(child: CircularProgressIndicator(color:Theme.of(context).primaryColor),);
        }
    },
    );
  }
}

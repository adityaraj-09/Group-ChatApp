import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/pages/chat_page.dart';
import 'package:insien_flutter/widgets/widgets.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile({Key? key,required this.groupId,required this.groupName,required this.userName}) : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  String recentMessage="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecentMessage();
  }

  getRecentMessage(){
    Database(uid: FirebaseAuth.instance.currentUser!.uid)
        .getRecentMessage(widget.groupId).then((value){
         setState(() {
           recentMessage=value;
         });
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        nextScreen(context,  ChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          userName: widget.userName,
        ));
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(left: 8,right: 8,top: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal:5 ,vertical: 10),
          child:ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(widget.groupName.substring(0,1).toUpperCase(),textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 25),),
            ),
            title: Text(widget.groupName,
              style: const TextStyle(fontWeight: FontWeight.bold),),
            subtitle:recentMessage==""? Text("Join the conversation as ${widget.userName}",style: const TextStyle(fontSize: 13),)
                :Text(recentMessage,style: const TextStyle(fontSize: 13),)
          ) ,
        ),
      ),
    );
  }
}

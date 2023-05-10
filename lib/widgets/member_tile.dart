
import 'package:flutter/material.dart';
import 'package:insien_flutter/widgets/widgets.dart';

import '../Services/database_service.dart';
import '../pages/member_view.dart';

class MemberTile extends StatefulWidget {
  String name;
  String id;
  String adminid;
   MemberTile({Key? key,required this.id,required this.name,required this.adminid}) : super(key: key);

  @override
  State<MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> {

  String email="";
  String photo="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  getData()async{
    await Database().getData(widget.id).then((value){
      setState(() {
        email=value["email"];
        photo=value['profilePic'];
      });
    });


  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: (){

        nextScreen(context,MemberPage(id:widget.id, name: widget.name));
      },
      child: Container(

        child:ListTile(
          leading:photo==""? CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xff488381),
            child: Text(widget.name.substring(0,1).toUpperCase(),textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
          ):ClipOval(
            child: Image.network(photo,height: 60,width: 55,fit: BoxFit.cover,),
          ),
          title: Text(widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(email
            ,style: const TextStyle(fontSize: 13,color: Colors.black),),
          trailing:widget.id==widget.adminid? Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
                color:Color(0xff488381) ,
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            height: 30,

            child: const Text("Admin",style: TextStyle(color: Colors.white),),
          ):Container(),
        ),
      ),
    );
  }
}

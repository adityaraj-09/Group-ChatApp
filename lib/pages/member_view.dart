import 'package:flutter/material.dart';

import '../Services/database_service.dart';


class MemberPage extends StatefulWidget {
  String id;
  String name;
   MemberPage({Key? key,required this.id,required this.name}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  String email="";
  String photo="";
  Stream? groups;

  @override
  void initState() {
    super.initState();

   getGroups();
   getData();
  }

  getGroups()async{
    await Database().getGroupsFromid(widget.id).then((snapshot){
      setState(() {
        groups=snapshot;
      });
    });
  }
  getData()async{
    await Database().getData(widget.id).then((value){
      setState(() {
        email=value["email"];
        photo=value['profilePic'];
      });


    });
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        title: Text(widget.name,
          style: const TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            photo==""?Icon(Icons.account_circle,color: Colors.grey[700],size: 150,): ClipOval(
              child: Image.network(photo,height: 150,width: 150,fit: BoxFit.cover,),
            ),
            const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Name",
                    style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(widget.name,style: const TextStyle(fontSize: 17),),
                ],
              ),
            ),
            const Divider(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Email",
                    style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(email,style: const TextStyle(fontSize: 17),),
                ],
              ),
            ),
            Text("Groups Joined by ${widget.name}",style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
            groupList()


          ],
        ),
      ),
    );
  }
  groupList(){
    return StreamBuilder(
      stream: groups,
      builder: (context,AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['groups']!=null){
            if(snapshot.data['groups'].length!=0){
              return Container(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context,index){
                      int reverseIndex=snapshot.data['groups'].length-index-1;
                      return Padding(
                        padding: const EdgeInsets.only(left: 5,right: 5),
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                          child: Container(
                            padding:const EdgeInsets.only(
                                left: 20,
                                top: 5,
                                bottom: 5,
                                right: 10
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xff488381).withOpacity(0.2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xff488381),
                                  child: Text(getName(snapshot.data['groups'][reverseIndex]).substring(0,1).toUpperCase()
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
                                    Text(getName(snapshot.data['groups'][reverseIndex]).toUpperCase(),
                                        style:const TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 15)),
                                    const SizedBox(height: 10,),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ); ;
                    }),
              );
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
  noGroupWidget(){
    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 25) ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
            height: 20,
          ),
          Text("You've not joined any group.tap on add icon to create a group or also search from top",
            textAlign: TextAlign.center,)

        ],
      ),
    );
  }
}

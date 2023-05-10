import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/database_service.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByme;
  final String id;
  final String groupId;
  final int time;
  final String mid;
  const MessageTile({Key? key,required this.message,required this.sender,required this.sentByme,required this.id,required this.groupId,required this.time,required this.mid}) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return widget.sentByme?senderTile():receiverTile();
  }
 Widget receiverTile(){

    return GestureDetector(
      onLongPress: (){
        showDialog(
            barrierDismissible: false,
            barrierColor: Colors.white.withOpacity(0.5),
            context: context, builder: (context){
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            icon:const Icon(Icons.delete,color: Colors.green,size: 50,),
            content: const Text("Are you share to delete?"),
            actions: [

              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.cancel,color:Colors.red ,size: 40,)),
              IconButton(onPressed: () async{
                await Database().deletemsg(widget.groupId,widget.id).then({
                  Navigator.pop(context)
                });

              }, icon: const Icon(Icons.done,color:Colors.green,size: 40)),
            ],
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left:15,right:0,

        ),
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
          margin:const EdgeInsets.only(right: 10,),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft:Radius.circular(10) ,
                  topRight: Radius.circular(10) ,
                  bottomRight: Radius.circular(10)

              ),
              color:Colors.grey[700]
          ),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 8,
              ),
              Text(widget.message,textAlign:TextAlign.center,style: const TextStyle(fontSize: 16,color: Colors.white)),


            ],
          ),

        ),
      ),
    );
  }
  Widget senderTile(){
    return GestureDetector(
      onLongPress: (){
        showDialog(
            barrierDismissible: false,
            barrierColor: Colors.white.withOpacity(0.5),
            context: context, builder: (context){
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            icon:const Icon(Icons.delete,color: Colors.green,size: 50,),
            content: const Text("Are you share to delete?"),
            actions: [

              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.cancel,color:Colors.red ,size: 40,)),
              IconButton(onPressed: () async{
                await Database().deletemsg(widget.groupId,widget.id).then({
                  Navigator.pop(context)
                });

              }, icon: const Icon(Icons.done,color:Colors.green,size: 40)),
            ],
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: 0,right:15,

        ),
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
          margin:const EdgeInsets.only(left: 10,),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft:Radius.circular(10) ,
                  topRight: Radius.circular(10) ,
                  bottomLeft: Radius.circular(10)


              ),
              color: Theme.of(context).primaryColor
          ),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 8,
              ),
              Text(widget.message,textAlign:TextAlign.center,style: const TextStyle(fontSize: 16,color: Colors.white)),


            ],
          ),

        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/Services/notification_service.dart';
import 'package:insien_flutter/pages/group_info.dart';
import 'package:insien_flutter/widgets/messgae_tile.dart';
import 'package:insien_flutter/widgets/widgets.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key,required this.groupId,required this.groupName,required this.userName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

 Stream<QuerySnapshot>? chats;
  String admin="";
 final speechToText=SpeechToText();
  TextEditingController textEditingController=TextEditingController();
  bool visibleMic=true;
  bool visibleSend=false;
 String lastwords="";
 NotificationService notificationService=NotificationService();
  @override
  void initState() {
    super.initState();
    getChatandAdmin();
    speechtext();
    notificationService.token();
  }

 Future<void>speechtext() async{
   await speechToText.initialize();
   setState(() {});
 }

 Future<void> startListening() async {
   await speechToText.listen(onResult: onSpeechResult);
   setState(() {});
 }

 Future<void> stopListening() async {
   await speechToText.stop();
 }


 void onSpeechResult(SpeechRecognitionResult result) {
   setState(() {
     lastwords = result.recognizedWords;
   });
 }
  getChatandAdmin(){
    Database().getChats(widget.groupId).then((val){
      setState(() {
        chats=val;
      });
    });
    Database().getGroupAdmin(widget.groupId).then((value){
      admin=value;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
     appBar: AppBar(
       centerTitle: true,
       elevation: 0,
       title: Text(widget.groupName),
       leading: IconButton(
         onPressed: (){
           Navigator.of(context).pop();
         },
           icon: const Icon(Icons.arrow_back_ios)),
       backgroundColor: Theme.of(context).primaryColor,
       actions: [
         IconButton(onPressed: (){
           nextScreen(context,GroupInfoPage(
             groupId: widget.groupId,
             groupName: widget.groupName,
             adminName: admin,
           ));
         }, icon:const Icon(Icons.info_outline))
       ],

     ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
              width:MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(child:TextFormField(
                    controller: textEditingController,
                    onChanged: (String value) async{
                      if(value.isNotEmpty){
                        setState(() {
                          visibleMic=false;
                          visibleSend=true;

                        });
                      }else{
                        setState(() {
                          visibleMic=true;
                          visibleSend=false;
                        });
                      }
                    },
                    style:const TextStyle(
                      color: Colors.white
                    ),
                    decoration:const InputDecoration(
                      hintText: "send message",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 20),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(width: 12,),
                  Visibility(
                    visible: visibleMic,
                    child: GestureDetector(
                      onTap:()async{
                          if(await speechToText.hasPermission &&
                          speechToText.isNotListening){

                            await speechtext();

                            setState(() {

                            });

                          }else if(speechToText.isListening){

                          }else{
                            speechtext();
                          }

                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child:  const Center(child: Icon(Icons.mic,color: Colors.white,),),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: visibleSend,
                    child: GestureDetector(
                      onTap:(){
                        sendMessage();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child:  const Center(child: Icon(Icons.send,color: Colors.white,),),
                      ),
                    ),
                  )
                ],
              ),

            ),

          )
        ],
      ),
    );
  }
 chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder:(context,AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data.docs.length!=0){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder:(context,index){
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByme:widget.userName==snapshot.data.docs[index]['sender'],
                  id: snapshot.data.docs[index].id,
                  groupId: widget.groupId,
                  time: snapshot.data.docs[index]['time'],
                  mid: snapshot.data.docs[index].id,);
                });
          }else{
            return  Container(
              width: MediaQuery.of(context).size.width,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:  [
                  const Text("No message sent in this group",
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
          return Center(
            child: CircularProgressIndicator(
            color:Theme.of(context).primaryColor,
          ),);
        }

      },
    );
 }
 sendMessage()async{
    if(textEditingController.text.isNotEmpty){
     Map<String,dynamic> msg={
       "message":textEditingController.text,
       "sender": widget.userName,
       "time":DateTime.now().microsecondsSinceEpoch,
       "read":"",
       "sentBy":FirebaseAuth.instance.currentUser!.uid
     };
     Database().sendMessage(widget.groupId, msg);
     var data={
       'to':notificationService.token().toString(),
       'priority':'high',
       'notification':{
         'title':widget.groupName,
         'body':textEditingController.text
       }
     };
     await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
         body:jsonEncode(data) ,
     headers: {
       'Content-Type':'application/json; charset=UTF-8',
       'Authorization':'key=AAAAPFN1_to:APA91bG4OdK_ZxoKiH3mnA4c0MV9bNTzBudZX2ImdpiV0WWueJsoaPUFFQwMuEg9U3dTtaHbR6SqMWKrzj_i8YJV34tq_lcrsbxZ4qL_M6mkT707h0fQBwb8bEeW491mBEroOJbFY53r'
     });
     setState(() {
       textEditingController.clear();
       visibleSend=false;
       visibleMic=true;
     });
    }else{
      showSnakbar(context,Colors.red,"Enter message to send");
    }
 }

 sendVoiceMessage(String text){
   if(text.isNotEmpty){
     Map<String,dynamic> msg={
       "message":text,
       "sender": widget.userName,
       "time":DateTime.now().microsecondsSinceEpoch,
       "read":"",
     };
     Database().sendMessage(widget.groupId, msg);

   }else{
     showSnakbar(context,Colors.red,"Enter message to send");
   }
 }
}

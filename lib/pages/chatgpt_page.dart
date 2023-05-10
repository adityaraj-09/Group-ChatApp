

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:insien_flutter/Services/auth_service.dart';
import 'package:insien_flutter/helper/openai_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


import '../shared/constants.dart';

class ChatGPT extends StatefulWidget {
  final String userName;
  final String email;
   const ChatGPT({Key? key,required this.userName,required this.email}) : super(key: key);

  @override
  State<ChatGPT> createState() => _ChatGPTState();
}

class _ChatGPTState extends State<ChatGPT> {
  final speechToText=SpeechToText();
  final flutterTts = FlutterTts();
  String lastwords="";
  Authservice authservice=Authservice();
  final OpenAi openAi=OpenAi();
  String? generatedContent;
  String? generatedImageUrl;


  @override
  void initState() {
    super.initState();
    speechTotext();
  }

  Future<void>speechTotext() async{
   await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }


  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastwords = result.recognizedWords;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  Future<void>systemSpeak(String content )async{
    await flutterTts.speak(content);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("ChatGpt",
          style: TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                   height: 120,
                   width: 120,
                    margin: const EdgeInsets.only(top: 5),
                    decoration:const  BoxDecoration(
                      color:Constants.assistantCircleColor,
                      shape: BoxShape.circle
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 123,
                    width: 120,
                    decoration:const BoxDecoration(
                     shape: BoxShape.circle,
                     image:DecorationImage(
                       image: AssetImage('assets/images/virtualAssistant.png')
                     )
                    ),

                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              margin:const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight:Radius.circular(20),
                  bottomLeft:Radius.circular(20) ,
                  bottomRight: Radius.circular(20)

                ),
                border:Border.all(
                  color: Colors.black
                )
              ),
              child:Text(generatedContent==null? "Good morning,what task can I do for you?":generatedContent!,
                style:TextStyle(
                  color:Constants.mainFontColor,
                  fontSize:generatedContent==null? 25:18,
                  fontFamily:'Cera Pro'
                ),
              ),

            ),
            Visibility(
              visible: generatedContent==null,
              child: const Align(
                alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                      child: Text("Here are few commands",style: TextStyle(color: Colors.black,fontSize: 23,fontFamily:'Cera Pro' ,fontWeight: FontWeight.bold),))),
            ),
            Visibility(
              visible: generatedContent==null,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10).copyWith(right: 10),
                    margin:const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10
                    ),
                    decoration:const BoxDecoration(
                      color: Constants.thirdSuggestionBoxColor,
                      borderRadius: BorderRadius.only(
                          topLeft:Radius.circular(20) ,
                          topRight:Radius.circular(20),
                          bottomLeft:Radius.circular(20) ,
                          bottomRight: Radius.circular(20)

                      ),

                    ),
                    child: Column(
                        children:const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "ChatGPT",
                              style:TextStyle(
                                  color:Constants.mainFontColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "A smarter way to stay organized and informed with chatGpt",
                            style:TextStyle(
                                color:Constants.blackColor,
                                fontSize: 20,
                                fontFamily: 'Cera Pro'
                            ),
                          ),

                        ]
                    ),

                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10).copyWith(right: 10),
                    margin:const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10
                    ),
                    decoration:const BoxDecoration(
                      color: Constants.secondSuggestionBoxColor,
                      borderRadius: BorderRadius.only(
                          topLeft:Radius.circular(20) ,
                          topRight:Radius.circular(20),
                          bottomLeft:Radius.circular(20) ,
                          bottomRight: Radius.circular(20)

                      ),

                    ),
                    child: Column(
                        children:const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Dall-E",
                              style:TextStyle(
                                  color:Constants.mainFontColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "Get inspired and stay creative with you own personal assistant powered by Dall-E",
                            style:TextStyle(
                                color:Constants.blackColor,
                                fontSize: 20,
                                fontFamily: 'Cera Pro'
                            ),
                          ),
                        ]
                    ),

                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10).copyWith(right: 10),
                    margin:const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom:10
                    ),
                    decoration:const BoxDecoration(
                      color: Constants.assistantCircleColor,
                      borderRadius: BorderRadius.only(
                          topLeft:Radius.circular(20) ,
                          topRight:Radius.circular(20),
                          bottomLeft:Radius.circular(20) ,
                          bottomRight: Radius.circular(20)
                      ),

                    ),
                    child: Column(
                        children:const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Smart Voice Assistant",
                              style:TextStyle(
                                  color:Constants.mainFontColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          SizedBox(height:12,),
                          Text(
                            "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGpt ",
                            style:TextStyle(
                                color:Constants.blackColor,
                                fontSize: 20,
                                fontFamily: 'Cera Pro'
                            ),
                          ),

                        ]
                    ),

                  ),
                ],
              ),
            ),
           



          ],
        ),
      ),
      floatingActionButton:FloatingActionButton(
        backgroundColor:Constants.firstSuggestionBoxColor,
        onPressed: () async{
          if(await speechToText.hasPermission &&
              speechToText.isNotListening){
            await startListening();

          }else if(speechToText.isListening){
           final speech= await openAi.isArtPrompt(lastwords);
           if(speech.contains('https')){
             generatedImageUrl=speech;
             generatedContent=null;
             setState(() {});
           }else{
             generatedImageUrl=null;
             generatedContent=speech;
             setState(() {});
             await systemSpeak(speech);
           }
            await stopListening();
          }else{
            speechTotext();
          }
        },
        child: const Icon(Icons.mic,color: Colors.black,),
      ) ,
    );
  }
}

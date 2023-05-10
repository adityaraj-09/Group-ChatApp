
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insien_flutter/Services/auth_service.dart';
import 'package:insien_flutter/Services/database_service.dart';
import 'package:insien_flutter/helper/helper_function.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../auth/login.dart';
import '../widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
   ProfilePage({Key? key,required this.email,required this.userName}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImagePicker picker =ImagePicker();
   File? _image;
  bool _isloading=false;
  String photo="";
  late XFile pickedimage;
  Authservice authservice=Authservice();
  String name="";
  String realTimeName="";

  upload()async{
    await Database(uid: FirebaseAuth.instance.currentUser?.uid).uploadImage(_image).then((value){
      Database(uid: FirebaseAuth.instance.currentUser?.uid).putImage(value);
      Helper.saveUserProfile(value);
    });
  }

  changeName()async{
    await Database(uid: FirebaseAuth.instance.currentUser?.uid).putName(name).whenComplete((){
      Helper.saveUserName(name);
    });
  }
  @override
  void initState() {
    super.initState();
    get();
  }
  get()async{
    await Helper.getUserPrrofile().then((value){
      setState(() {
        photo=value!;
      });
    });
    await Helper.getUserName().then((value) {
      setState(() {
        realTimeName=value!;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile",
          style: TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold),),
        actions: [
          Center(
            child: CupertinoContextMenu(
              actions: <Widget>[
                CupertinoContextMenuAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        content: const Text("Are you sure you want to logout?"),
                        actions: <Widget>[
                          CupertinoDialogAction(

                            child: const Text("Log out"),
                            onPressed: () {
                              authservice.signOut();
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                  builder: (context) => const LoginPage()), (Route route) => false);
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
                    );
                  },
                  isDefaultAction: true,
                  trailingIcon: Icons.logout,
                  child: const Text('Log out'),
                ),
                CupertinoContextMenuAction(
                  onPressed: () async {
                    final uri=Uri.parse(photo);
                    final res=await http.get(uri);
                    final bytes=res.bodyBytes;
                    final temp=await getTemporaryDirectory();
                    final path='${temp.path}/image.jpg';
                    File(path).writeAsBytesSync(bytes);
                    await Share.shareFiles([path]);
                  },
                  trailingIcon: CupertinoIcons.share,
                  child: const Text('Share Profile'),
                ),
                CupertinoContextMenuAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  trailingIcon: CupertinoIcons.heart,
                  child: const Text('Favorite'),
                ),
                CupertinoContextMenuAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.delete,
                  child: const Text('Delete'),
                ),
              ],
              child: const Icon(Icons.more_vert,size: 30,color: Colors.white,),
            ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Stack(
                children: [
                  profile(),
                   Positioned(
                    left: 100,
                    top: 100,
                    child: GestureDetector(
                      onTap: (){
                        showModalBottomSheet<void>(context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)
                                )
                            ),
                            builder:(BuildContext context){
                              return Container(
                                height: 180,
                                child: Column(
                                  children:[
                                     Text("Choose an option ):",style: TextStyle(color:Theme.of(context).primaryColor,fontSize: 25,fontWeight: FontWeight.bold),),
                                    Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap:()async{
                                          Navigator.pop(context);
                                          pickedimage = (await picker.pickImage(source: ImageSource.gallery))!;
                                          setState(() {
                                            if(pickedimage!=null){
                                              _image=File(pickedimage!.path);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 25,top: 20,bottom: 10,right: 20),
                                          padding: const EdgeInsets.only(bottom: 5),
                                          height: 120,
                                          width: 120,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Color(0xff488381),
                                          ),
                                          child: Stack(
                                              children: const [
                                                Center(child: Icon(Icons.browse_gallery,size: 50,color: Colors.white,)),
                                                Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: Text("Gallery",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),))
                                              ]),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:()async{
                                          Navigator.pop(context);
                                          pickedimage = (await picker.pickImage(source: ImageSource.camera))!;
                                          setState(() {
                                            if(pickedimage!=null){
                                              _image=File(pickedimage!.path);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 15,top: 20,bottom: 10,right: 20),
                                          padding: const EdgeInsets.only(bottom: 5),
                                          height: 120,
                                          width: 120,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Color(0xff488381),
                                          ),
                                          child: Stack(
                                              children: const [
                                                Center(child: Icon(Icons.camera,size: 50,color: Colors.white,)),
                                                Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: Text("Camera",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),))
                                              ]),
                                        ),
                                      ),

                                    ],
                                  ),

                                  ]
                                ),
                              );
                            });

                      },
                      child:  CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Center(
                          child: Icon(Icons.edit,color: Colors.white,),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40,),
              TextFormField(
                decoration: textInputdec.copyWith(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person,
                      color:Theme.of(context).primaryColor ,
                      size: 20,
                    )
                ),
                initialValue: realTimeName==""?widget.userName:realTimeName,
                onChanged:(val){
                  setState(() {
                    name=val;
                  });
                },

              ),
              const Divider(height: 30,),
              TextFormField(
                decoration: textInputdec.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email,
                      color:Theme.of(context).primaryColor ,
                    )
                ),
                initialValue: widget.email,
              ),
              const SizedBox(height: 75,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      )
                  ) ,
                  child: const Text("Update Profile",style: TextStyle(color:Colors.white,fontSize: 16),
                  ),onPressed: (){
                  if(_image!=null && name.isNotEmpty){
                    setState(() {
                      _isloading=true;
                    });
                    upload().whenComplete((){
                      changeName().whenComplete((){
                        setState(() {
                          _isloading=false;
                          get();
                        });
                      });
                    });
                  }else if(_image==null && name.isNotEmpty){
                    setState(() {
                      _isloading=true;
                    });
                    changeName().whenComplete((){
                      setState(() {
                        _isloading=false;
                        get();
                      });
                    });
                  }else if(_image!=null && name.isEmpty){
                    setState(() {
                      _isloading=true;
                    });
                    upload().whenComplete((){
                      setState(() {
                        _isloading=false;
                        get();
                      });
                    });
                  }
                },
                ),
              ),
              Container(
                height: 100,
                width: 100,
                child: _isloading?const CircularProgressIndicator(
                  color: Colors.red,
                ):Container(),
              )

            ],
          ),
        ),
      ),
    );
  }
  profile(){
    if(_image!=null || photo==""){
      return _image!=null?ClipOval(
        child: Image.file(_image!,fit: BoxFit.cover,
          height: 150,width: 150,),
      ):Icon(Icons.account_circle,size: 150,color: Colors.grey[700],);
    }else {
      return ClipOval(
        child: Image.network(photo,height: 150,width: 150,fit: BoxFit.cover,),
      );
    }
  }
}

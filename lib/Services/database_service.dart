
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class Database{
  final String? uid;
  Database({this.uid});
  final CollectionReference usercollection=FirebaseFirestore.instance.collection("users");

  final CollectionReference groupcollection=FirebaseFirestore.instance.collection("groups");


  Future savingData(String name,String email) async{
    return await usercollection.doc(uid).set({
      "Name": name,
      "email":email,
      "groups":[],
      "profilePic":"",
      "uid":uid,
      "Token":"",

    });
  }
  Future savingToken(String token) async{
    return await usercollection.doc(uid).update({
      "Token": token,
    });
  }

  Future gettingUserData(String email) async{
    QuerySnapshot snapshot=await usercollection.where("email",isEqualTo: email).get();
    return snapshot;
  }

   gettingUserfromid(String id) async{
     DocumentReference d=usercollection.doc(id);
     DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot['email'];
  }
  getProfileFromid(String id)async{
    DocumentReference d=usercollection.doc(id);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot['profilePic'];
  }
  getData(String id)async{
    DocumentReference d=usercollection.doc(id);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot;
  }


  getUserGroups() async{
    return usercollection.doc(uid).snapshots();
  }
  getGroupsFromid(String id)async{
    return usercollection.doc(id).snapshots();
  }

  deletemsg(String groupId,String id) async{
    groupcollection.doc(groupId).collection('messages').doc(id).delete();
    groupcollection.doc(groupId).update({
      "recentMessage":"",
    }
    );
  }

  Future createGroup(String userName,String id,String groupName) async{
    DocumentReference documentReference=await groupcollection.add({
      "groupname":groupName,
      "timeCreated":DateTime.now().microsecondsSinceEpoch,
      "groupIcon":"",
      "admin":"${id}_$userName",
      "members":[],
      "groupId":"",
      "recentMessage":"",
      "recentMessageSender":"",
      "recentMessageTime":"",

    });

    await documentReference.update({
      "members":FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId":documentReference.id,

    });
    DocumentReference userReference=await usercollection.doc(uid);
    return await userReference.update({
      "groups":FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
  }

  getChats(String groupId) async{
    return groupcollection.doc(groupId).collection("messages").orderBy("time").snapshots();
  }

  getGroup()async{
    return groupcollection.orderBy('timeCreated').snapshots();
  }

  Future getGroupAdmin(String groupId) async{
    DocumentReference d=groupcollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot['admin'];
  }
  getGroupData(String groupId)async{
    DocumentReference d=groupcollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot;
  }


  Future getRecentMessage(String groupId) async{
    DocumentReference d=groupcollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot['recentMessage'];
  }

  getGroupMembers(String groupId) async{
    return groupcollection.doc(groupId).snapshots();
  }

  search(String groupName){
    return groupcollection.where("groupname",isEqualTo:groupName ).get();
  }
  Future<bool> isUserJoined(String groupName,String gid,String username) async{
    DocumentReference userDocumentReference=usercollection.doc(uid);
    DocumentSnapshot documentSnapshot=await userDocumentReference.get();
    List<dynamic> groups=await documentSnapshot['groups'];
    if(groups.contains("${gid}_$groupName")){
      return true;
    }else{
      return false;
    }
  }
  Future toggleGroup(String gid,String userName,String groupName) async{
    DocumentReference documentReference=usercollection.doc(uid);
    DocumentReference groupReference=groupcollection.doc(gid);

    DocumentSnapshot documentSnapshot=await documentReference.get();
    List<dynamic> groups=await documentSnapshot['groups'];
    if(groups.contains("${gid}_$groupName")){
      await documentReference.update({
        "groups": FieldValue.arrayRemove(["${gid}_$groupName"])
      });
      await groupReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    }else{
      await documentReference.update({
        "groups": FieldValue.arrayUnion(["${gid}_$groupName"])
      });
      await groupReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }


  }

  sendMessage(String groupId,Map<String,dynamic> msg) async{
    groupcollection.doc(groupId).collection("messages").add(msg);
    groupcollection.doc(groupId).update({
    "recentMessage":msg['message'],
      "recentMessageSender":msg['sender'],
      "recentMessageTime":msg['time'].toString()
    }
    );
  }
  uploadImage(File? file) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    final storgeRef=FirebaseStorage.instance.ref().child(DateTime.now().microsecondsSinceEpoch.toString());
    UploadTask uploadTask = storgeRef.putFile(file!);
    final snapshot=await uploadTask.whenComplete((){});
    final urlDownload=await snapshot.ref.getDownloadURL();
    return urlDownload;
}
  putImage(String uri) async{
    usercollection.doc(uid).update({
      "profilePic":uri,

    }
    );
  }
  putName(String name) async{
    usercollection.doc(uid).update({
     "Name":name

    }
    );
  }
  updateRead(String id,String groupId)async{
    groupcollection.doc(groupId).collection("messages").doc(id).update({
      "read":DateTime.now().microsecondsSinceEpoch.toString()
    });
  }
}

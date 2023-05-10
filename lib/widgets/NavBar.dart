import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selected=0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 15),
      color: Color(0xff017575),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              setState(() {
                selected=0;
              });
            },
            child: Column(
              children: [
              Container(
                height: 4,
                width: 20,
                decoration:  BoxDecoration(
                    color:selected==0? Colors.white:Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),),
                SizedBox(height: 8,),
                Icon(Icons.home_outlined,color: Colors.white,size: 30,),
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                selected=1;
              });
            },
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 20,
                  decoration:  BoxDecoration(
                      color:selected==1? Colors.white:Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(10))),),
                SizedBox(height: 8,),
                Icon(Icons.bookmark_add_outlined,color: Colors.white,size: 30,),
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                selected=2;
              });
            },
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 20,
                  decoration:  BoxDecoration(
                      color:selected==2? Colors.white:Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(10))),),
                SizedBox(height: 8,),
                Icon(Icons.play_circle_outline,color: Colors.white,size: 30,),
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                selected=3;
              });
            },
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 20,
                  decoration:  BoxDecoration(
                      color:selected==3? Colors.white:Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(10))),),
                SizedBox(height: 8,),
                Icon(Icons.group_outlined,color: Colors.white,size: 30,),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
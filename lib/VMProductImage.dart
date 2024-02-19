import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const VMProductImage(path: '',));
// }

class VMProductImage extends StatefulWidget {
  const VMProductImage({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<VMProductImage> createState() => _VMProductImageState();
}

class _VMProductImageState extends State<VMProductImage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // @override
  // dispose() {
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      // MaterialApp with debugShowCheckedModeBanner false and home
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.purple
      ),
      home: Scaffold(
        // Scaffold with appbar ans body.
        appBar: AppBar(
          title: const Text("VM Compliance",style:TextStyle(fontSize: 16)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          backgroundColor: Colors.black,
          // flexibleSpace: Container(
          //
          //   decoration: const BoxDecoration(
          //
          //     // borderRadius: BorderRadius.only(
          //     //     bottomRight: Radius.circular(35),
          //     //      bottomLeft: Radius.circular(35),
          //     // ),
          //
          //   ),
          // ),
          elevation: 0.00,
        ),
        body:
        SingleChildScrollView(
            scrollDirection: Axis.vertical,

            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child:Container(
                    width: 250,
                    height: 250,

                    margin: const EdgeInsets.only(top: 5,left: 0,right: 0,bottom: 0),
                    child: Image.memory(base64Decode(widget.path),width: 40,),),
                  ),



              ],

            )
        ),
      ),
    );
  }
}



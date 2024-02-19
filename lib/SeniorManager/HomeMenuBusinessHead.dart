import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Menu/Login.dart';
import '../Menu/VMGuidline.dart';
import 'Feedback/seniorBillingBarChart.dart';
import 'SeniorManagerCompliance/VMComplianceSeniorManager.dart';
import 'StockQuery.dart';



class HomeMenuBusinessHead  extends StatefulWidget {
  const HomeMenuBusinessHead ({Key? key, required this.username, required this. fname, required this. lname}) : super(key: key);
  final String username;
  final String fname;
  final String lname;


  @override
  State<HomeMenuBusinessHead> createState() => _HomeMenuBusinessHeadState();
}
class _HomeMenuBusinessHeadState extends State<HomeMenuBusinessHead > {


  int currentPage = 0;
  String address = '';
  String city = '';
  String storeCode = '';

  @override
  void initState()  {
    super.initState();

  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{
        final value = await  showDialog<bool>(context: context, builder: (context){
          return AlertDialog(
            title: const Text("Exit"),
            content: const Text("Do you want to exit"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(70, 35), //////// HERE
                ),
                child:const Text('No'),/// HERE
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,

                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(70, 35), //////// HERE
                ),
                //return false when click on "NO"

                child:const Text('Yes'),/// HERE
              ),
            ],
          );
        });
        if(value!=null){
          return Future.value(value);
        }
        else{
          return Future.value(false);
        }
      },
      child:Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .45,
              decoration:  BoxDecoration(
                  color: Colors.grey.shade300
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {

                            if (value == 'option2') {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              signOut();

                            }
                            else{
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => buildExitDialog(context),
                              );
                            }

                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'option1',
                                child: Row(
                                  children: [
                                    Icon(Icons.exit_to_app,color: Colors.black,),
                                    SizedBox(width: 8), // Add some space between icon and text
                                    Text('Exit',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'option2',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout,color: Colors.black,),
                                    SizedBox(width: 8), // Add some space between icon and text
                                    Text('Logout',style:TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),

                            ];
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            height: 52,
                            width: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset("assets/menu.svg", color: Colors.black),
                          ),
                        ),
                      ),
                    ),


                    const Text("Senior Manager",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(height: 5,),
                    Text("${widget.fname} ${widget.lname}",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),),

                    const SizedBox(height: 35,),


                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.all(5),
                        crossAxisCount: 1,
                        childAspectRatio: 5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 10,
                        children: <Widget>[
                          GestureDetector(
                            onTap:(){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return VMGuideline(stid:'');
                                  },
                                ),
                              );

                            },
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,  // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/vm_guidline.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VM GUIDELINE",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),





                          GestureDetector(

                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return VMComplianceSeniormanager(username:widget.username.toString());
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,   // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VM COMPLIANCE",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),


                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return  StockQuerySenior(username: widget.username,);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,   // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/stockcheck.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("STOCK CHECK",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),




                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return SeniorBillingBar(username: widget.username,);
                                  },
                                ),
                              );
                            },
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,  // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/customer_feedback.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VOICE OF CUSTOMER",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Function to handle sign-out
  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('usernameValue');
    await prefs.remove('LoggedSenior');

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const AuthPage(); // Replace SignInScreen with your actual sign-in screen
        },
      ),
    );
  }
}





Widget buildExitDialog(context) {
  return  AlertDialog(
      title: const Text("Exit App", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      content: const Text('Do you want to exit an App?'),
      actions:[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            onPrimary: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(70, 35), //////// HERE
          ),
          //return false when click on "NO"
          child:const Text('No'),/// HERE
        ),

        ElevatedButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            onPrimary: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(70, 35), //////// HERE
          ),
          child:const Text('Yes'),/// HERE
        )
      ]
  );
}













// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/material.dart';
// import 'package:sample/SeniorManager/StockQuery.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../AppColors.dart';
// import '../DrawHorizontalLine.dart';
// import '../Menu/Login.dart';
// import '../Menu/StockQuery.dart';
// import '../Menu/VMGuidline.dart';
// import 'SeniorManagerCompliance/VMComplianceSeniorManager.dart';
// import 'Feedback/seniorBillingBarChart.dart';
//
//
//
// class HomeMenuBusinessHead  extends StatefulWidget {
//   const HomeMenuBusinessHead ({Key? key, required this.username, required this. fname, required this. lname}) : super(key: key);
//   final String username;
//   final String fname;
//   final String lname;
//
//
//   @override
//   State<HomeMenuBusinessHead > createState() => _RootPageState();
// }
//
// class _RootPageState extends State<HomeMenuBusinessHead > {
//   int currentPage = 0;
//
//   String get username => widget.username;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop:() async{
//       final value = await  showDialog<bool>(context: context, builder: (context){
//         return AlertDialog(
//           title: const Text("Exit"),
//           content: const Text("Do you want to exit"),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.black,
//                 onPrimary: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5.0)),
//                 minimumSize: const Size(70, 35), //////// HERE
//               ),
//               child:const Text('No'),/// HERE
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               //return false when click on "NO"
//
//               child:Text('Yes'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.black,
//                 onPrimary: Colors.white,
//
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5.0)),
//                 minimumSize: Size(70, 35), //////// HERE
//               ),/// HERE
//             ),
//           ],
//         );
//       });
//       if(value!=null){
//         return Future.value(value);
//       }
//       else{
//         return Future.value(false);
//       }
//     },
//
//
//       child:Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               showMenu(
//                 context: context,
//                 position: RelativeRect.fromLTRB(0, 50, 10, 0), // Adjust the position as needed
//                 items: [
//                   PopupMenuItem<String>(
//                     value: 'item1',
//                     child: const ListTile(
//                       leading: Icon(Icons.exit_to_app),
//                       title: Text(
//                         'Logout',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () async {
//                       // Call your logout function or any other action here
//                       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//                       // Clear stored user information
//                       await prefs.remove('first_name');
//                       await prefs.remove('last_name');
//                       await prefs.remove('usernameValue');
//                       await prefs.remove('LoggedSenior');
//
//                       // Navigate back to the login or sign-in screen
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (BuildContext context) {
//                             return AuthPage(); // Replace SignInScreen with your actual sign-in screen
//                           },
//                         ),
//                       ); // Example: call the signOut function
//                     },
//                   ),
//
//
//
//                   // Add more menu items as needed
//                 ],
//               );
//             },
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.exit_to_app),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) =>
//                       buildExitDialog(context),
//                 );
//               },
//             ),
//           ],
//
//
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Text("Senior Manager",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               Text(
//                 '${widget.fname} ${widget.lname}',
//                 style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white),
//               ),
//             ],
//           ),
//           titleSpacing: 00.0,
//           centerTitle: true,
//           toolbarHeight: 100.2,
//           toolbarOpacity: 0.8,
//           backgroundColor: Colors.black,
//           elevation: 0.00,
//
//         ),
//         body:SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           scrollDirection: Axis.vertical,
//
//           child:Column(
//             children: [
//               Container(
//                 height: 400,
//                 margin: const EdgeInsets.only(top: 50,left: 0,right: 0,bottom: 0),
//                 child: Stack(
//                   children:[
//                     Row(
//                       children: <Widget>[
//                         Expanded(
//                             flex: 80,
//                             child: Container (
//                             )
//                         ),
//                         Expanded(
//                           flex: 10,
//                           child: CustomPaint(
//                             foregroundPainter: DrawHorizontalLines( context, 20.0, 4.0, 8.0, 8.0, AppColors.DrawHorizontalin ),
//                             child: Container( color: Colors.transparent ),
//                           ),
//                         ),
//                         Expanded(
//                             flex: 10,
//                             child: Container (
//                             )
//                         ),
//                       ],
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: <Widget>[
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Expanded(
//                                   flex: 8,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 15,
//                                 child : ClipRRect(
//                                   borderRadius: BorderRadius.circular(7.0),
//                                   child: InkWell(
//                                     child: Container(
//                                         height: 40,
//                                         width: 30,
//                                         child:  SvgPicture.asset("assets/images/vm_guidline.svg",color: Colors.black,)),
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return const VMGuideline(stid: '',);
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 2,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 62,
//                                 child: GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       // _dashboardPressed = !_dashboardPressed;
//                                     });
//                                     // Navigator.push( context, MaterialPageRoute(builder: ( context ) => PlayerMasterActivity()));
//                                     Future.delayed(const Duration(milliseconds: 200), () {
//                                       setState(() {
//                                         Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                             builder: (BuildContext context) {
//                                               return const VMGuideline(stid: '',);
//                                             },
//                                           ),
//                                         );
//
//                                       });
//                                     });
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     // padding: EdgeInsets.only(left: 15.0),
//                                     height: 40,
//                                     width: 300,
//                                     decoration: const BoxDecoration(
//                                         color: Colors.black,
//                                         borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: const Text('VM GUIDELINE',textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12.0),),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 13,
//                                   child: Container()
//                               ),
//                             ]
//                         ),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Expanded(
//                                   flex: 8,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 15,
//                                 child : ClipRRect(
//                                   borderRadius: BorderRadius.circular(7.0),
//                                   child: InkWell(
//                                     child: Container(
//                                         height: 40,
//                                         width: 40,
//                                         child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.black)),
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return VMComplianceSeniormanager(username:widget.username.toString());
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 2,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 62,
//                                 child: GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return VMComplianceSeniormanager(username:widget.username.toString());
//                                           },
//                                         ),
//                                       );
//                                     });
//
//                                     Future.delayed(const Duration(milliseconds: 200), () {
//                                       setState(() {
//                                         // _dietPlannerPressed = !_dietPlannerPressed;
//                                       });
//                                     });
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     // padding: EdgeInsets.only(left: 25.0),
//                                     height: 40,
//                                     width: 300,
//                                     decoration: BoxDecoration(
//                                         color: Colors.black,
//                                       // gradient: const LinearGradient(
//                                       //     colors: [Colors.pink, Colors.blue],
//                                       //     begin: Alignment.centerLeft,
//                                       //     end: Alignment.centerRight),
//                                       borderRadius: new BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: const Text('COMPLIANCE REPORT', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 13,
//                                   child: Container()
//                               ),
//                             ]
//                         ),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Expanded(
//                                   flex: 8,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 15,
//                                 child : ClipRRect(
//                                   borderRadius: BorderRadius.circular(7.0),
//                                   child: InkWell(
//                                     child: SizedBox(
//                                         height: 40,
//                                         width: 40,
//                                         child: SvgPicture.asset("assets/images/stockcheck.svg",color: Colors.black)),
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return  StockQuerySenior(username: widget.username,);
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 2,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 62,
//                                 child: GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return   StockQuerySenior(username: widget.username,);
//                                           },
//                                         ),
//                                       );
//                                     });
//                                     // Navigator.push( context,  MaterialPageRoute(builder: ( context ) => KnowledgeBaseActivity()));
//                                     Future.delayed(const Duration(milliseconds: 200), () {
//                                       setState(() {
//                                         // _knowledgeBasePressed = !_knowledgeBasePressed;
//                                       });
//                                     });
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     // padding: EdgeInsets.only(left: 25.0),
//                                     height: 40,
//                                     width: 300,
//                                     decoration: const BoxDecoration(
//                                         color: Colors.black,
//                                       borderRadius:  BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: const Text('STOCK CHECK', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 13,
//                                   child: Container()
//                               ),
//                             ]
//                         ),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Expanded(
//                                   flex: 8,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 15,
//                                 child : ClipRRect(
//                                   borderRadius: BorderRadius.circular(7.0),
//                                   child: InkWell(
//                                     child: Container(
//                                         height: 40,
//                                         width: 40,
//                                         child: SvgPicture.asset("assets/images/customer_feedback.svg",color: Colors.black)),
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return SeniorBillingBar(username: username,);
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 2,
//                                   child: Container()
//                               ),
//                               Expanded(
//                                 flex: 62,
//                                 child: GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return SeniorBillingBar(username: username,);
//                                           },
//                                         ),
//                                       );
//                                     });
//                                     // Navigator.push(context, MaterialPageRoute(builder: ( context )
//                                     // => ChatMembers(fromCoach: true, currentUserId: globals.firebaseUid)));
//                                     Future.delayed(const Duration(milliseconds: 200), () {
//                                       setState(() {
//                                         // _messengerPressed = !_messengerPressed;
//                                       });
//                                     });
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     // padding: EdgeInsets.only(left: 25.0),
//                                     height: 40,
//                                     width: 300,
//                                     decoration: const BoxDecoration(
//                                         color: Colors.black,
//                                       borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: const Text('VOICE OF CUSTOMER', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   flex: 13,
//                                   child: Container()
//                               ),
//                             ]
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//
//
//           ),
//         )
//       )
//     );
//   }
// }
//
//
//
//
// Widget buildExitDialog(context) {
//   return  AlertDialog(
//       title: const Text("Exit App", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//       content: const Text('Do you want to exit an App?'),
//       actions:[
//
//         ElevatedButton(
//           onPressed: () => Navigator.of(context).pop(false),
//           //return false when click on "NO"
//
//           child:Text('No'),
//           style: ElevatedButton.styleFrom(
//             primary: Colors.black,
//             onPrimary: Colors.white,
//             shadowColor: Colors.greenAccent,
//             elevation: 3,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(32.0)),
//             minimumSize: Size(80, 40), //////// HERE
//           ),/// HERE
//         ),
//
//
//         ElevatedButton(
//           onPressed: () {SystemNavigator.pop();
//           },
//           //return true when click on "Yes"
//           child:Text('Yes'),
//           style: ElevatedButton.styleFrom(
//             primary: Colors.black,
//             onPrimary: Colors.white,
//             shadowColor: Colors.greenAccent,
//             elevation: 3,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(32.0)),
//             minimumSize: const Size(80, 40), //////// HERE
//           ),/// HERE
//         )
//       ]
//   );
//
// }

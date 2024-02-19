//ComplianceReportHomeMenu

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'StoreManagerCompliance/VMComplianceFirstAttempt.dart';
import 'StoreManagerCompliance/VMComplianceSecondAttempt.dart';



class ComplianceReportHomeMenu extends StatefulWidget {
  const  ComplianceReportHomeMenu ({Key? key,required this.stid, }) : super(key: key);
  final String stid;


  @override
  State<ComplianceReportHomeMenu> createState() => _homeClassState();
}
class _homeClassState extends State<ComplianceReportHomeMenu> {


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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .30,
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

                  SizedBox(height: 100,),

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
                                  return VMComplianceFirstAttempt(stid:widget.stid.toString());
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
                                    child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                const Text("FIRST ATTEMPT",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                              ],
                            ),
                          ),
                        ),



                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return  VMComplianceSecondAttempt(stid:widget.stid.toString());
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
                                    color: Colors.black,   // Set the color of the left box
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child:  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                const Text("SECOND ATTEMPT",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
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

    );
  }
}












//
// import 'package:flutter/services.dart';
// import 'package:sample/HomeMenu.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/material.dart';
// import '../AppColors.dart';
// import '../DrawHorizontalLine.dart';
// import 'StoreManagerCompliance/VMComplianceFirstAttempt.dart';
// import 'StoreManagerCompliance/VMComplianceSecondAttempt.dart';
//
// class ComplianceReportHomeMenu extends StatefulWidget {
//   const ComplianceReportHomeMenu({Key? key, required this. stid}) : super(key: key);
//   final String stid;
//
//   @override
//   State<ComplianceReportHomeMenu> createState() => _ComplianceReportHomeMenuState();
// }
//
// class _ComplianceReportHomeMenuState extends State<ComplianceReportHomeMenu> {
//   int currentPage = 0;
//   String _scanBarcode='';
//
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () {
//          Navigator.of(context).pop();
//               },
//               icon: const Icon(Icons.arrow_back_ios)),
//
//
//           title: const Text("Store Manager"),
//           titleSpacing: 00.0,
//           centerTitle: true,
//           toolbarHeight: 70.2,
//           toolbarOpacity: 0.8,
//           backgroundColor: Colors.black,
//
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
//                 height: 200,
//                 margin: const EdgeInsets.only(top: 5,left: 0,right: 0,bottom: 0),
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
//                           child: Container(
//                             child: CustomPaint(
//                               child: Container( color: Colors.transparent ),
//                               foregroundPainter: DrawHorizontalLines( context, 20.0, 4.0, 8.0, 8.0, AppColors.DrawHorizont ),
//                             ),
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
//                                         child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.black)),
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return VMComplianceFirstAttempt(stid:widget.stid.toString());
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
//                                               return VMComplianceFirstAttempt(stid:widget.stid.toString());
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
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                           colors: [Colors.black, Colors.black],
//                                           begin: Alignment.bottomRight,
//                                           end: Alignment.topLeft),
//                                       borderRadius: new BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: Text('FIRST ATTEMPT',textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12.0),),
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
//                                         width: 30,
//                                         child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.black)),
//                                     onTap: () {
//
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return VMComplianceSecondAttempt(stid:widget.stid.toString());
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
//                                     print(widget.stid);
//                                     setState(() {
//
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (BuildContext context) {
//                                             return  VMComplianceSecondAttempt(stid:widget.stid.toString());
//                                           },
//                                         ),
//                                       );
//
//                                     });
//
//
//                                     Future.delayed(const Duration(milliseconds: 200), () {
//                                       setState(() {
//                                         // _trainingPlannerPressed = !_trainingPlannerPressed;
//                                       });
//                                     });
//                                   },
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     // padding: EdgeInsets.only(left: 25.0),
//                                     height: 40,
//                                     width: 300,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                           colors: [Colors.black, Colors.black],
//                                           begin: Alignment.bottomRight,
//                                           end: Alignment.topLeft),
//                                       borderRadius: new BorderRadius.all(Radius.elliptical(50, 50)),
//                                     ),
//                                     child: const Text('SECOND ATTEMPT', style: TextStyle(color: Colors.white, fontSize: 12.0)),
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
//           ),
//         )
//     );
//   }
// }
//
//
//
//
// Widget buildExitDialog(context) {
//   return  AlertDialog(
//     // content: new Column(
//     //   mainAxisSize: MainAxisSize.min,
//     //   crossAxisAlignment: CrossAxisAlignment.start,
//     //   children: <Widget>[
//     //
//     //   ],
//     // ),
//     // MaterialApp with debugShowCheckedModeBanner false and home
//       title: const Text("Exit App", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//
//
//       content: const Text('Do you want to exit an App?'),
//       actions:[
//
//         ElevatedButton(
//           onPressed: () => Navigator.of(context).pop(false),
//           //return false when click on "NO"
//
//           child:Text('No'),
//           style: ElevatedButton.styleFrom(
//             primary: Colors.pink,
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
//             primary: Colors.blue,
//             onPrimary: Colors.white,
//             shadowColor: Colors.greenAccent,
//             elevation: 3,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(32.0)),
//             minimumSize: Size(80, 40), //////// HERE
//           ),/// HERE
//         )
//
//       ]
//   );
//
//
//
// }
//
//

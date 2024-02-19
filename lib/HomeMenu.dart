// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:http/io_client.dart';
// import 'package:sample/CustomerFeedback/billingBarChart.dart';
// import 'package:sample/StoreManager/ComplianceReportHomemenu.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/material.dart';
// import 'package:sample/Menu/VMGuidline.dart';
// import 'package:sample/temporary.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'AppColors.dart';
// import 'Camera/CameraEquipmentDropdown.dart';
// import 'DrawHorizontalLine.dart';
// import 'Menu/Login.dart';
// import 'Menu/StockQuery.dart';
// import 'Menu/QRCodeGenerator.dart';
// import 'homeclass.dart';
//
//
// class HomeMenu extends StatefulWidget {
//
//   const HomeMenu({Key? key, required this.stid,}) : super(key: key);
//   final String stid;
//
//   @override
//   State<HomeMenu> createState() => _HomeMenuState();
// }
//
// class _HomeMenuState extends State<HomeMenu> {
//
//   int currentPage = 0;
//   String address = '';
//   String city = '';
//   String storeCode = '';
//
//   @override
//   void initState() {
//     fetchaddress();
//     super.initState();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//     onWillPop:() async{
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
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.black,
//                 onPrimary: Colors.white,
//
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//                 minimumSize: const Size(70, 35), //////// HERE
//               ),
//               //return false when click on "NO"
//
//               child:const Text('Yes'),/// HERE
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
//       child: Scaffold(
//           appBar: AppBar(
//             leading: PopupMenuButton<String>(
//
//               onSelected: (value) {
//                 print("Selected: $value");
//                 if (value == 'option1') {
//                 signOut();
//                 }
//               },
//               itemBuilder: (BuildContext context) {
//                 return <PopupMenuEntry<String>>[
//                   const PopupMenuItem<String>(
//                     value: 'option1',
//                     child: Row(
//                       children: [
//                         Icon(Icons.logout,color: Colors.black,),
//                         SizedBox(width: 8),
//                         Text('Logout'),
//                       ],
//                     ),
//                   ),
//                 ];
//               },
//             ),
//             actions: [
//               const Align(
//                 alignment: Alignment.center,
//                 child: Text("version 1.0.2",style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: Colors.white)),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.exit_to_app),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => buildExitDialog(context),
//                   );
//                 },
//               ),
//             ],
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text("Store Manager",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//                 Text('$address $city',
//                   style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white),
//                 ),
//               ],
//             ), // Empty to leave space for the second title
//             titleSpacing: 0.0,
//             centerTitle: true,
//             toolbarHeight: 100.2,
//             toolbarOpacity: 0.8,
//             backgroundColor: Colors.black,
//             elevation: 0.00,
//           ),
//         body:SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         scrollDirection: Axis.vertical,
//
//       child:Column(
//         children: [
//           Container(
//             // color: Colors.yellow,
//              height: 450,
//              margin: const EdgeInsets.only(top: 50,left: 0,right: 0,bottom: 0),
//
//             child: Stack(
//               children:[
//                 Row(
//                   children: <Widget>[
//                     Expanded(
//                         flex: 80,
//                         child: Container (
//                         )
//                     ),
//                     Expanded(
//                       flex: 10,
//                       child: CustomPaint(
//                         foregroundPainter: DrawHorizontalLines( context, 20.0, 4.0, 8.0, 8.0, AppColors.DrawHorizont ),
//                         child: Container( color: Colors.transparent ),
//                       ),
//                     ),
//                     Expanded(
//                         flex: 10,
//                         child: Container (
//                         )
//                     ),
//                   ],
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: SizedBox(
//                                     height: 40,
//                                     width: 30,
//                                     child: SvgPicture.asset("assets/images/vm_guidline.svg",color: Colors.black,)),
//                                 onTap: () {
//                                   //print(widget.stid);
//                                   Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                       builder: (BuildContext context) {
//                                                         return
//                                                           //  CameraTextRecognition();
//                                                           //  VMGuideline(stid:widget.stid.toString());
//                                                             homeClass(stid: widget.stid,);
//
//                                                       },
//                                                     ),
//                                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                 setState(() {
//
//                                 });
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                     Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                         builder: (BuildContext context) {
//                                                           return VMGuideline(stid:widget.stid.toString());
//                                                         },
//                                                       ),
//                                                     );
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 height: 40,
//                                 width: 300,
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.bottomRight,
//                                       end: Alignment.topLeft),
//                                   borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('VM GUIDELINE',textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12.0),),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                     ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: const SizedBox(
//                                     height: 45,
//                                     width: 45,
//                                     child: Image(image: AssetImage("assets/images/camera.png",))),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return
//                                           //VMQRView(stid:widget.stid.toString());
//                                           CameraEquipmentDropdown(stid:widget.stid.toString(),StCode:storeCode.toString());
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                 setState(() {
//
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return
//                                            //VMQRView(stid:widget.stid.toString());
//                                           CameraEquipmentDropdown(stid:widget.stid.toString(),StCode:storeCode.toString());
//                                       },
//                                     ),
//                                   );
//                                 });
//
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                     // _trainingPlannerPressed = !_trainingPlannerPressed;
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 // padding: EdgeInsets.only(left: 25.0),
//                                 height: 40,
//                                 width: 300,
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.bottomRight,
//                                       end: Alignment.topLeft),
//                                   borderRadius:  BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('CAPTURE IMAGE', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                     ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: SizedBox(
//                                     height: 40,
//                                     width: 40,
//                                     child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.black)),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                       builder: (BuildContext context) {
//                                                         return ComplianceReportHomeMenu(stid:widget.stid.toString());
//                                                       },
//                                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                 setState(() {
//                                   Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                       builder: (BuildContext context) {
//                                                         return ComplianceReportHomeMenu(stid:widget.stid.toString());
//                                                       },
//                                                     ),
//                                                   );
//                                 });
//
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 height: 40,
//                                 width: 300,
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.centerLeft,
//                                       end: Alignment.centerRight),
//                                   borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('COMPLIANCE REPORT', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                     ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: SizedBox(
//                                     height: 40,
//                                     width: 40,
//                                     child: SvgPicture.asset("assets/images/stockcheck.svg",color: Colors.black)),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                                     MaterialPageRoute(
//                                                       builder: (BuildContext context) {
//                                                         return StockQuery(stid:widget.stid.toString());
//                                                       },
//                                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                   setState(() {
//                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                       builder: (BuildContext context) {
//                                                         return StockQuery(stid:widget.stid.toString());
//                                                       },
//                                                     ),
//                                                   );
//                                 });
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 height: 40,
//                                 width: 300,
//                                 decoration: const BoxDecoration(
//                                   gradient:  LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.centerLeft,
//                                       end: Alignment.centerRight),
//                                   borderRadius:  BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('STOCK CHECK', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                       ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: SizedBox(
//                                     height: 40,
//                                     width: 40,
//                                     child:  SvgPicture.asset("assets/images/customer_feedback.svg",color: Colors.black)),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return BillingBar(stid:widget.stid.toString());
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                 setState(() {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return BillingBar(stid:widget.stid.toString());
//                                       },
//                                     ),
//                                   );
//                                 });
//                                 // Navigator.push(context, MaterialPageRoute(builder: ( context )
//                                 // => ChatMembers(fromCoach: true, currentUserId: globals.firebaseUid)));
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                     // _messengerPressed = !_messengerPressed;
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                   height: 40,
//                                   width: 300,
//                                   decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.centerLeft,
//                                       end: Alignment.centerRight),
//                                   borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('VOICE OF CUSTOMER', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                     ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Expanded(
//                               flex: 8,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 15,
//                             child : ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: InkWell(
//                                 child: const SizedBox(
//                                     height: 40,
//                                     width: 40,
//                                     child: Icon(Icons.qr_code,color: Colors.black,size: 40,)),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return MydropdownApp(stid:widget.stid.toString());
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 2,
//                               child: Container()
//                           ),
//                           Expanded(
//                             flex: 62,
//                             child: GestureDetector(
//                               onTap: (){
//                                 setState(() {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                         return MydropdownApp(stid:widget.stid.toString());
//                                       },
//                                     ),
//                                   );
//                                 });
//                                 // Navigator.push(context, MaterialPageRoute(builder: ( context )
//                                 // => ChatMembers(fromCoach: true, currentUserId: globals.firebaseUid)));
//                                 Future.delayed(const Duration(milliseconds: 200), () {
//                                   setState(() {
//                                     // _messengerPressed = !_messengerPressed;
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 // padding: EdgeInsets.only(left: 25.0),
//                                 height: 40,
//                                 width: 300,
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [Colors.black, Colors.black],
//                                       begin: Alignment.centerLeft,
//                                       end: Alignment.centerRight),
//                                   borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
//                                 ),
//                                 child: const Text('QR CODE GENERATION', style: TextStyle(color: Colors.white, fontSize: 12.0)),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 13,
//                               child: Container()
//                           ),
//                         ]
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const Align(
//             alignment: Alignment.center,
//             child: Text("version 1.0.2",style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.black)),
//           ),
//         ],
//
//         ),
//         )
//         ),
//     );
//   }
//
//
//   // Function to handle sign-out
//   void signOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     await prefs.remove('store');
//     await prefs.remove('Logged');
//
//     // ignore: use_build_context_synchronously
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (BuildContext context) {
//           return AuthPage(); // Replace SignInScreen with your actual sign-in screen
//         },
//       ),
//     );
//   }
//
//   Future<void> fetchaddress() async{
//     HttpClient client = HttpClient(context: await globalContext);
//     client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
//     IOClient ioClient = IOClient(client);
//     final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_store_address_latest/${widget.stid}'));
//
//     var addressCityList = json.decode(response.body);
//     String Address = addressCityList[0]['address'];
//     String City = addressCityList[0]['city'];
//     String StoreCode = addressCityList[0]['code'];
//     setState(() {
//
//       address = Address;
//       city = City;
//       storeCode = StoreCode;
//     });
//
//   }
//   Future<SecurityContext> get globalContext async {
//     final sslCert1 = await rootBundle.load('assets/starttrent.pem');
//     SecurityContext sc = SecurityContext(withTrustedRoots: false);
//     sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
//     return sc;
//   }
// }
//
//
//
// Widget buildExitDialog(context) {
//   return  AlertDialog(
//       title: const Text("Exit App", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//       content: const Text('Do you want to exit an App?'),
//       actions:[
//         ElevatedButton(
//         onPressed: () => Navigator.of(context).pop(false),
//         style: ElevatedButton.styleFrom(
//         primary: Colors.black,
//         onPrimary: Colors.white,
//
//         elevation: 3,
//         shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(5.0)),
//         minimumSize: const Size(70, 35), //////// HERE
//         ),
//         //return false when click on "NO"
//         child:const Text('No'),/// HERE
//         ),
//
//         ElevatedButton(
//         onPressed: () {
//           SystemNavigator.pop();
//           },
//         style: ElevatedButton.styleFrom(
//           primary: Colors.black,
//           onPrimary: Colors.white,
//           elevation: 3,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//           minimumSize: const Size(70, 35), //////// HERE
//         ),
//         //return true when click on "Yes"
//         child:const Text('Yes'),/// HERE
//       )
//
//     ]
//   );
// }
//
//
//

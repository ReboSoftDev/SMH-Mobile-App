// import 'dart:convert';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/io_client.dart';
// import '../../model.dart';
// import 'EquipmentWiseSeniorManager.dart';
//
//
// void main() {
//   runApp(const StoreWiseSeniormanager());
// }
//
// class StoreWiseSeniormanager extends StatefulWidget {
//   const StoreWiseSeniormanager({Key? key, this.storeId,this.date}) : super(key: key);
//   final String? storeId;
//   final String? date;
//
//   @override
//   State<StoreWiseSeniormanager> createState() => _HomePageState();
// }
// // DateTime currentDate = DateTime.now();
// class _HomePageState extends State<StoreWiseSeniormanager> {
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//   }
//
//   @override
//   dispose() {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     super.dispose();
//   }
//   // String pickdate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // MaterialApp with debugShowCheckedModeBanner false and home
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//           primarySwatch: Colors.purple
//       ),
//       home: Scaffold(
//         // Scaffold with appbar ans body.
//         appBar: AppBar(
//           title: const Text("VM Compliance - Senior Manager",style:TextStyle(fontSize: 16)),
//           automaticallyImplyLeading: false,
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               icon: const Icon(Icons.arrow_back_ios)),
//           backgroundColor: Colors.black,
//           actions: [
//             // IconButton(
//             //   icon: const Icon(Icons.calendar_today),
//             //   onPressed: () {
//             //     _showDatePicker(context);
//             //   },
//             // ),
//           ],
//           elevation: 0.00,
//         ),
//         body: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             scrollDirection: Axis.vertical,
//             child:Column(
//               children: [
//                 FutureBuilder<List<SeniorManager>>(
//                   initialData: const <SeniorManager>[],
//                   future:fetchResults(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError ||
//                         snapshot.data == null ||
//                         snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: Text("Loading..."));
//                     }
//
//                     List<Map<String, dynamic>> tableData = [];
//
//                     if (snapshot.data != null) {
//                       for (SeniorManager seniorManager in snapshot.data!) {
//                         var Amber = seniorManager.amber;
//                          var Red = seniorManager.red! ;
//                         var totalImages = seniorManager.total_images;
//                         double percentage;
//                         ///calculate percentage
//                         totalImages == 0 ? percentage = 0 : percentage = (Amber! / totalImages! ) *100;
//                         /// percentage Rounding
//                         String inString1 = percentage.toStringAsFixed(2); // '2.35'
//                         double Percentage = double.parse(inString1);
//                         String statusFirst;
//                         String statusSecond;
//                         Percentage > 85 ?  statusFirst = 'Approved': statusFirst = 'Not Approved';
//                         var Diff = Percentage - 85 ;
//
//
//                         tableData.add({
//                           'cluster': seniorManager.cluster,
//                           'storeCode' : seniorManager.store_code,
//                           'total_picture': seniorManager.total_images,
//                           'total_amber'  : Amber,
//                           'total_red'    : Red,
//                           'percent'      : '$Percentage %',
//                           'status'       : statusFirst,
//                           'BenchMark'    : '85%',
//                           'Difference'   :  Diff,
//                           'store_id'     : seniorManager.store_id
//                         });
//                       }
//                     }
//
//                     return FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: DataTable(
//
//                         dataRowHeight: 100,
//                         headingRowHeight: 120,
//                         headingRowColor:
//                         MaterialStateColor.resolveWith((states) =>
//                         Colors.black45),
//                         columns: const [
//                           DataColumn(label: Center(child:Text('Cluster',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('Store\nCode',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('Pictures',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('#Eqpt\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('#Eqpt Not\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('% Compliance',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('Company\nBenchmark',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                           DataColumn(label: Center(child:Text('Difference',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
//                         ],
//                         rows: tableData.map((data) {
//                           Color? rowColor;
//                           return DataRow(
//                             color: MaterialStateColor.resolveWith((states) => rowColor ?? Colors.transparent),
//                             cells: [
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child:Text(data['cluster'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//                                       },
//                                   )
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center( child:  Text(data['storeCode'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//                                       },)
//                               ),
//
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center( child: Text(data['total_picture']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//
//                                     },)
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child: Text(data['total_amber']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//
//                                     },)
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child: Text(data['total_red']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 30,color: Colors.red,))),
//                                     onTap: (){
//                                       String stId = data['store_id'].toString();
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => EquipmentWiseSeniormanager(storeId:stId ,date: widget.date.toString() ),
//
//                                         ),
//                                       );
//                                       print("press");
//                                     },)
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child:Text(data['percent']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//
//                                     },)
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child: Text(data['BenchMark']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//
//                                     },)
//                               ),
//                               DataCell(
//                                   GestureDetector(
//                                     child:Center(child: Text(data['Difference']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
//                                     onTap: (){
//
//                                     },)
//                               )
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                     );
//
//                   },
//                 ),
//               ],
//             )
//         ),
//       ),
//     );
//   }
//
//
//   Future<List<SeniorManager>> fetchResults() async {
//
//     HttpClient client = HttpClient(context: await globalContext);
//     client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
//     IOClient ioClient = IOClient(client);
//     final response = await ioClient.post(
//         Uri.parse("https://smh-app.trent-tata.com/flask/get_senior_manager_store_wise"),
//         body: json.encode({"date":widget.date.toString(),"cluster":widget.storeId.toString()}),
//         headers: {
//           "content-type": "application/json",
//         });
//     print("successAPI");
//     var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//
//     print('storewise...........$resultsJson');
//     List<SeniorManager> emplist = await resultsJson
//         .map<SeniorManager>((json) => SeniorManager.fromJson(json))
//         .toList();
//     return emplist;
//   }
//   Future<SecurityContext> get globalContext async {
//     final sslCert1 = await
//     rootBundle.load('assets/starttrent.pem');
//     SecurityContext sc = SecurityContext(withTrustedRoots: false);
//     sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
//     return sc;
//   }
//
//
// }
//
//
//
//

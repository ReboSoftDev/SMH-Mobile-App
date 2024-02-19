import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:vibration/vibration.dart';
import '../../model.dart';
import 'EquipmentWiseSeniorManager.dart';


class VMComplianceSeniormanager extends StatefulWidget {
  const VMComplianceSeniormanager({Key? key, required this. username}) : super(key: key);
  final String username;

  @override
  State<VMComplianceSeniormanager> createState() => _HomePageState();
}
DateTime currentDate = DateTime.now();
class _HomePageState extends State<VMComplianceSeniormanager> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
  String pickdate = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        // Scaffold with appbar ans body.
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.00,
          toolbarHeight: 0,
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child:Column(
              children: [
                FutureBuilder<List<SeniorManager>>(
                  initialData: const <SeniorManager>[],
                  future:fetchResults(pickdate),
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    }
                   // print(pickdate);
                    List<Map<String, dynamic>> tableData = [];


                    if (snapshot.data != null) {
                      for (SeniorManager seniorManager in snapshot.data!) {
                        int Amber = int.parse(seniorManager.first_amber.toString()) + int.parse(seniorManager.second_amber.toString());
                        int Red = int.parse(seniorManager.first_red.toString()) + int.parse(seniorManager.second_red.toString());
                        var totalImages = seniorManager.total_images;
                        double percentage;
                        ///calculate percentage
                        totalImages == 0 ? percentage = 0 : percentage = (Amber! / totalImages! ) *100;
                        /// percentage Rounding
                        String inString1 = percentage.toStringAsFixed(2); // '2.35'
                        double Percentage = double.parse(inString1);
                        String statusFirst;
                        String statusSecond;
                        Percentage > 85 ?  statusFirst = 'Approved': statusFirst = 'Not Approved';
                        var Diff = Percentage - 85 ;


                        tableData.add({
                          'city': seniorManager.city,
                          'storeCode' : seniorManager.store_code,
                          'total_picture': seniorManager.total_images,
                          'total_amber'  : Amber,
                          'total_red'    : Red,
                          'percent'      : '$Percentage %',
                          'status'       : statusFirst,
                          'BenchMark'    : '85%',
                          'Difference'   :  Diff,
                          'store_id'     : seniorManager.store_id
                        });
                      }
                    }
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: DataTable(

                        dataRowHeight: 120,
                        headingRowHeight: 150,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) =>
                        Colors.grey.shade200),
                        columns: const [
                          DataColumn(label: Center(child:Text('City',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Store\nCode',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Pictures',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('#Eqpt\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('#Eqpt Not\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('% Compliance',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Company\nBenchmark',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Difference',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black,))),),
                        ],
                        rows: tableData.map((data) {
                          Color? rowColor;
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) => rowColor ?? Colors.transparent),
                            cells: [
                              DataCell(
                                  GestureDetector(
                                    child:Center(child:Text(data['city'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 40,fontWeight: FontWeight.bold),)),
                                    onTap: (){
                                    },
                                  )
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center( child:  Text(data['storeCode'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50),)),
                                    onTap: (){
                                    },)
                              ),

                              DataCell(
                                  GestureDetector(
                                    child:Center( child: Text(data['total_picture']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Container(
                                      width:200,
                                        color:Colors.grey.shade300,

                                        child:Center(child: Text(data['total_amber']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50,fontWeight: FontWeight.bold),))),
                                       onTap: () async{
                                        String stId = data['store_id'].toString();
                                        if (await Vibration.hasVibrator() ?? false) {
                                          Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                        }
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EquipmentWiseSeniormanager(storeId:stId ,date: pickdate.toString(),compliant:'AMBER' ),

                                          ),
                                        );
                                      },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Container(
                                      width:200,
                                        color:Colors.grey.shade300,
                                    child:Center(child: Text(data['total_red']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 50,color: Colors.red,)))),
                                    onTap: () async{
                                      String stId = data['store_id'].toString();
                                      if (await Vibration.hasVibrator() ?? false) {
                                      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                      }
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EquipmentWiseSeniormanager(storeId:stId ,date: pickdate.toString(),compliant:'RED' ),

                                        ),
                                      );
                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center(child:Text(data['percent']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center(child: Text(data['BenchMark']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(

                                    child:Center(child: Text(data['Difference']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 50),)),
                                    onTap: (){

                                    },)
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    );
                    },
                ),
              ],
            )
        ),
    );
  }
  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black87, // change header background color
              onPrimary: Colors.white, // change header text color
              surface: Colors.black54, // change background color
              onSurface: Colors.black, // change text color
            ),
            dialogBackgroundColor: Colors.white, // change dialog background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        pickdate = formattedDate;
      });
      print('Selected date: $formattedDate');
    }
  }

  Future<List<SeniorManager>> fetchResults(String date) async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_senior_manager"),
        body: json.encode({"date":date,"user_name":widget.username.toString()}),
        headers: {
          "content-type": "application/json",
        });
    print("successAPI");
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<SeniorManager> emplist = await resultsJson
        .map<SeniorManager>((json) => SeniorManager.fromJson(json))
        .toList();
    return emplist;
  }
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
}





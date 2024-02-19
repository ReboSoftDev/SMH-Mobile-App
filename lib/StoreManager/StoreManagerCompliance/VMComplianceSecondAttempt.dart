import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:sample/model.dart';
import 'package:vibration/vibration.dart';
import 'EquipmentWiseStoreManager.dart';




class VMComplianceSecondAttempt extends StatefulWidget {
  const VMComplianceSecondAttempt({Key? key, required this. stid}) : super(key: key);
  final String  stid;

  @override
  State<VMComplianceSecondAttempt> createState() => _HomePageState();
}
// DateTime currentDate = DateTime.now();
class _HomePageState extends State<VMComplianceSecondAttempt> {


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
  // String pickdate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        // Scaffold with appbar ans body.
        appBar: AppBar(
          title: const Text("VM Compliance - Second Attempt",style:TextStyle(fontSize: 16)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          backgroundColor: Colors.black,

          elevation: 0.00,
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child:Column(
              children: [
                FutureBuilder<List<StoreManager>>(
                  initialData: const <StoreManager>[],
                  future:fetchResults(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    }

                    List<Map<String, dynamic>> tableData = [];

                    if (snapshot.data != null) {
                      for (StoreManager storeManager in snapshot.data!) {
                        var firstAmber = storeManager.first_amber;
                        var totalImageFirst= storeManager.total_image_first;
                        double percentFirst;
                        ///calculate percentage
                        totalImageFirst == 0 ? percentFirst = 0 : percentFirst = (firstAmber! / totalImageFirst! ) *100;
                        /// percentage Rounding
                        String inString1 = percentFirst.toStringAsFixed(2); // '2.35'
                        double firstPercent = double.parse(inString1);
                        String statusFirst;
                        String statusSecond;
                        firstPercent > 85 ?  statusFirst = 'Approved': statusFirst = 'Not Approved';
                        var secondAmber = storeManager.second_amber;
                        var totalImageSecond= storeManager.total_image_second;
                        double percentSecond;
                        totalImageSecond == 0 ? percentSecond = 0 : percentSecond = (secondAmber! / totalImageSecond! ) *100;
                        /// percentage Rounding
                        String inString2 = percentSecond.toStringAsFixed(2); // '2.35'
                        double secondPercent = double.parse(inString2);
                        secondPercent > 85 ? statusSecond = 'Approved': statusSecond ='Not Approved';
                        if(storeManager.store_code != null) {
                          tableData.add({
                            'storeCode': storeManager.store_code,
                            'location': storeManager.s_address,
                            'attempt': 'First',
                            'total_picture': storeManager.total_image_first,
                            'total_amber': storeManager.first_amber,
                            'total_red': storeManager.first_red,
                            'percent': '$firstPercent %',
                            'status': statusFirst,
                            'storeId': storeManager.store_id,
                            'date': storeManager.inserted_date
                          });

                          tableData.add({
                            'storeCode': "",
                            'location': storeManager.s_address,
                            'attempt': 'Second',
                            'total_picture': storeManager.total_image_second,
                            'total_amber': storeManager.second_amber,
                            'total_red': storeManager.second_red,
                            'percent': '$secondPercent %',
                            'status': statusSecond,
                            'storeId': storeManager.store_id,
                            'date': storeManager.inserted_date
                          });
                        }
                      }
                    }

                    return FittedBox(
                      fit: BoxFit.scaleDown,

                      child: DataTable(

                        dataRowHeight: 100,
                        headingRowHeight: 120,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) =>
                        Colors.grey.shade200),
                        columns: const [
                          DataColumn(label: Center(child:Text('Store',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Location',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Attempt',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Pictures',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('#Pic\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('#Pic Not\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('% Compliance',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                          DataColumn(label: Center(child:Text('Status',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,))),),
                        ],
                        rows: tableData.map((data) {
                          Color? rowColor;
                          if (data['attempt'] == 'First') {
                            rowColor = Colors.white;
                          } else if (data['attempt'] == 'Second') {
                            rowColor = Colors.white.withOpacity(0.2);
                          }
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) => rowColor ?? Colors.transparent),
                            cells: [
                              DataCell(
                                  GestureDetector(
                                    child:Center(child:Text(data['storeCode'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
                                    onTap: (){

                                    },
                                  )
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center( child:  Text(data['location'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center(child: Text(data['attempt'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center( child: Text(data['total_picture']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Container(
                                        color:Colors.grey.shade300,

                                    child:Center(child: Text(data['total_amber']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 40),))),
                                    onTap: ()async{
                                      String stId =data['storeId'].toString();
                                      String attempt = data['attempt'].toString();
                                      String date = data['date'].toString();
                                      DateTime dateTime = DateFormat('E, d MMM yyyy HH:mm:ss z').parse(date.toString());
                                      String Date = DateFormat('yyyy-MM-dd').format(dateTime);
                                      if (await Vibration.hasVibrator() ?? false) {
                                      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                     }
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EquipmentWiseStoremanager(storeId:stId,date:Date,attempt:attempt,compliant:"AMBER"),
                                        ),
                                      );

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Container(
                                     color:Colors.grey.shade300,
                                     child:Center(child: Text(data['total_red']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 40,color: Colors.red,)))),
                                     onTap: () async{
                                      String stId =data['storeId'].toString();
                                      String attempt = data['attempt'].toString();
                                      String date = data['date'].toString();
                                      DateTime dateTime = DateFormat('E, d MMM yyyy HH:mm:ss z').parse(date.toString());
                                      String Date = DateFormat('yyyy-MM-dd').format(dateTime);
                                      print('........date.........$Date');
                                      if (await Vibration.hasVibrator() ?? false) {
                                        Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                      }
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EquipmentWiseStoremanager(storeId:stId,date:Date,attempt:attempt,compliant:"RED"),
                                        ),
                                      );
                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center(child:Text(data['percent']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
                                    onTap: (){

                                    },)
                              ),
                              DataCell(
                                  GestureDetector(
                                    child:Center(child: Text(data['status']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),)),
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


  Future<List<StoreManager>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_store_manager_second"),
        body: json.encode({"store_id":widget.stid.toString()}),
        headers: {
          "content-type": "application/json",
        });
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<StoreManager> emplist = await resultsJson
        .map<StoreManager>((json) => StoreManager.fromJson(json))
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





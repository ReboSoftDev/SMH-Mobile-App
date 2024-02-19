import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:vibration/vibration.dart';

import '../../model.dart';
import 'EquipmentWiseCityManager.dart';




class VMComplianceCitymanager extends StatefulWidget {
  const VMComplianceCitymanager({Key? key, required this. username}) : super(key: key);
final String username;
  @override
  State<VMComplianceCitymanager> createState() => _HomePageState();
}
DateTime currentDate = DateTime.now();
class _HomePageState extends State<VMComplianceCitymanager> {

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
          title: const Text("VM Compliance - City Manager",style:TextStyle(fontSize: 16)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
              _showDatePicker(context);
              },
            ),
          ],
          elevation: 0.00,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child:Column(
            children: [
              FutureBuilder<List<CityManager>>(
                initialData: const <CityManager>[],
                future:fetchResults(pickdate),
                builder: (context, snapshot) {
                  print(snapshot.data);
                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text("Loading..."));
                  }
                  print(pickdate);
                  List<Map<String, dynamic>> tableData = [];

                  if (snapshot.data != null) {
                    for (CityManager cityManager in snapshot.data!) {
                      var firstAmber = cityManager.first_amber;
                      var totalImageFirst= int.parse(cityManager.total_image_first.toString());
                      double percentFirst;
                      ///calculate percentage
                      totalImageFirst == 0 ? percentFirst = 0 : percentFirst = (firstAmber! / totalImageFirst! ) *100;
                      /// percentage Rounding
                      String inString1 = percentFirst.toStringAsFixed(2); // '2.35'
                      double firstPercent = double.parse(inString1);
                      String statusFirst;
                      String statusSecond;
                      firstPercent > 85 ?  statusFirst = 'Approved': statusFirst = 'Not Approved';
                      var secondAmber = cityManager.second_amber;
                      var totalImageSecond= int.parse(cityManager.total_image_second.toString());
                      double percentSecond;
                      totalImageSecond == 0 ? percentSecond = 0 : percentSecond = (secondAmber! / totalImageSecond! ) *100;
                      /// percentage Rounding
                      String inString2 = percentSecond.toStringAsFixed(2); // '2.35'
                      double secondPercent = double.parse(inString2);
                      secondPercent > 85 ? statusSecond = 'Approved': statusSecond ='Not Approved';
                      tableData.add({
                        'storeCode': cityManager.store_code,
                        'location' : cityManager.s_address,
                        'attempt'  : 'First',
                        'total_picture': cityManager.total_image_first,
                        'total_amber'  : cityManager.first_amber,
                        'total_red'    : cityManager.first_red,
                        'percent'      : '$firstPercent %',
                        'status'       : statusFirst,
                        'storeId'      : cityManager.store_id

                      });

                      tableData.add({
                        'storeCode': "",
                        'location' : cityManager.s_address,
                        'attempt'  : 'Second',
                        'total_picture' : cityManager.total_image_second,
                        'total_amber'   : cityManager.second_amber,
                        'total_red'     : cityManager.second_red,
                        'percent'       : '$secondPercent %',
                        'status'        : statusSecond,
                        'storeId'      : cityManager.store_id
                      });
                      print(tableData);
                    }
                  }

                  return FittedBox(
                    fit: BoxFit.scaleDown,

                        child: DataTable(

                      dataRowHeight: 100,
                      headingRowHeight: 120,
                      headingRowColor:
                      MaterialStateColor.resolveWith((states) =>
                      Colors.black45),
                      columns: const [
                          DataColumn(label: Center(child:Text('Store',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Location',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Attempt',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Pictures',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('#Pic\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('#Pic Not\nCompliant',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('% Compliance',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Status',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white,))),),
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
                                  child:Center(child: Text(data['total_amber']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30),))),
                                  onTap: () async{
                                    String stId =data['storeId'].toString();
                                    String attempt = data['attempt'].toString();
                                    if (await Vibration.hasVibrator() ?? false) {
                                    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                    }
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EquipmentWiseCitymanager(storeId:stId ,date: pickdate.toString(),attempt:attempt,compliant:"AMBER" ),
                                      ),
                                    );
                                  },)
                                ),
                            DataCell(
                              GestureDetector(
                                child:Container(
                                    color:Colors.grey.shade300,
                                child:Center(child: Text(data['total_red']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 35,color: Colors.red,)))),
                                onTap: ()async{
                                  String stId =data['storeId'].toString();
                                  String attempt = data['attempt'].toString();
                                  if (await Vibration.hasVibrator() ?? false) {
                                  Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                  }
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EquipmentWiseCitymanager(storeId:stId ,date: pickdate.toString(),attempt:attempt,compliant:"RED" ),
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

  Future<List<CityManager>> fetchResults(String date) async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_city_manager"),
        body: json.encode({"date":date,"user_name":widget.username}),
        headers: {
          "content-type": "application/json",
        });
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
     print(resultsJson);
    List<CityManager> emplist = await resultsJson
        .map<CityManager>((json) => CityManager.fromJson(json))
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





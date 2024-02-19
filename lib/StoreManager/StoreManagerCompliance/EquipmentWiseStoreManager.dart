import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

import 'package:sample/model.dart';
import 'package:vibration/vibration.dart';

import 'ProductWiseStoreManager.dart';


class EquipmentWiseStoremanager extends StatefulWidget {
  const EquipmentWiseStoremanager({Key? key, this.date, this.storeId, required this. attempt, required this. compliant}) : super(key: key);
  final String? date;
  final String? storeId;
  final String? attempt;
  final String? compliant;
  @override
  State<EquipmentWiseStoremanager> createState() => _HomePageState();
}

class _HomePageState extends State<EquipmentWiseStoremanager> {

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
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  DateTime parseDate(String dateString) {
    // Define the date format to parse the input string
    final DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
    // Parse the input string into a DateTime object
    return inputFormat.parse(dateString);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                FutureBuilder<List<CityManagerEquipmentWise>>(
                  initialData: const <CityManagerEquipmentWise>[],
                  future:fetchResults(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    }
                    return FittedBox(
                      fit: BoxFit.scaleDown,

                      child: DataTable(

                        dataRowHeight: 50,
                        headingRowHeight: 50,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) =>
                        Colors.black45),
                        columns: const [
                          DataColumn(label: Center(child:Text('Store',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Location',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Equipment',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,))),),
                          DataColumn(label: Center(child:Text('Time',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,))),),

                        ],
                        rows: List.generate(
                          snapshot.data!.length,
                              (index) {
                            var data = snapshot.data![index];

                            return DataRow(

                                color: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.selected)) {
                                        return Theme
                                            .of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08);
                                      }
                                      // Even rows will have a grey color.
                                      if (index % 2 == 0) {
                                        return Colors.white;
                                      }
                                      return Colors.white.withOpacity(0.2);
                                    }),

                                cells: [
                                  DataCell(
                                    GestureDetector(

                                      child:  Center(
                                        child: Text(data.store_code.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                      ),

                                      onTap: () {
                                        DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                        String time = DateFormat("HH:mm:ss").format(dateTime);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductWiseStoremanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                                detected_id:data.detected_table_id,  time:time,),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                      GestureDetector(
                                        child:  Center(
                                          child: Text(data.location.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                        ),
                                        onTap: () {
                                          DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                          String time = DateFormat("HH:mm:ss").format(dateTime);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductWiseStoremanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                                  detected_id:data.detected_table_id,  time:time,),
                                            ),
                                          );
                                        },
                                      )
                                  ),
                                  DataCell(
                                      GestureDetector(
                                        child:Container(
                                            color:Colors.grey.shade300,

                                        child:  Center(
                                          child: Text(data.equipment_name.toString(),style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 15,color: Colors.red,)),
                                        )),
                                        // width:40,
                                        onTap: () async {
                                          DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                          String time = DateFormat("HH:mm:ss").format(dateTime);
                                          if (await Vibration.hasVibrator() ?? false) {
                                            Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductWiseStoremanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                              detected_id:data.detected_table_id,  time:time,),
                                            ),
                                          );
                                        },
                                      )
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      child: Center(
                                        // Convert the string to DateTime and extract the time part
                                        child: Text(
                                          DateFormat('HH:mm:ss').format(parseDate(data.inserted_on.toString())),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      onTap: () {
                                        DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                        String time = DateFormat("HH:mm:ss").format(dateTime);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductWiseStoremanager(
                                              storeId: widget.storeId,
                                              date: widget.date,
                                              equipId: data.equipment_id.toString(),
                                              detected_id: data.detected_table_id,
                                              time:time,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ]);
                          },
                        ).toList(),

                      ),
                    );

                  },
                ),
              ],
            )
        ),
    );
  }


  Future<List<CityManagerEquipmentWise>> fetchResults() async {
    print(widget.storeId);
    print(widget.date);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_citymanager_equipment_wise"),
        body: json.encode({"date":widget.date.toString(),"store_id":widget.storeId.toString(),"attempt":widget.attempt,"compliant":widget.compliant}),
        headers: {
          "content-type": "application/json",
        });
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<CityManagerEquipmentWise> emplist = await resultsJson
        .map<CityManagerEquipmentWise>((json) => CityManagerEquipmentWise.fromJson(json))
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





import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:vibration/vibration.dart';


import '../../model.dart';
import 'ProductWiseClusterManager.dart';


class EquipmentWiseClustermanager extends StatefulWidget {
  const EquipmentWiseClustermanager({Key? key, this.date, this.storeId, required this. compliant}) : super(key: key);
  final String? date;
  final String? storeId;
  final String? compliant;
  @override
  State<EquipmentWiseClustermanager> createState() => _HomePageState();
}

class _HomePageState extends State<EquipmentWiseClustermanager> {

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


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        // Scaffold with appbar ans body.
        appBar: AppBar(
          title: const Text("VM Compliance - Cluster Manager",style:TextStyle(fontSize: 16)),
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
                FutureBuilder<List<ClusterManagerEquipmentWise>>(
                  initialData: const <ClusterManagerEquipmentWise>[],
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
                          DataColumn(label: Center(child:Text('Date',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,))),),

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
                                        child: Text(data.city.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                      ),

                                      onTap: () {
                                        DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                        String time = DateFormat("HH:mm:ss").format(dateTime);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductWiseClustermanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                                detection_id:data.detected_table_id,time:time),
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
                                              builder: (context) => ProductWiseClustermanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                                  detection_id:data.detected_table_id,time:time),
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
                                          child: Text(data.equipment_name.toString(),style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 15,color: Colors.red,))),
                                        ),
                                        // width:40,
                                        onTap: ()async {
                                          DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                          String time = DateFormat("HH:mm:ss").format(dateTime);
                                          String StId = data.store_id.toString();
                                          if (await Vibration.hasVibrator() ?? false) {
                                          Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductWiseClustermanager(storeId: StId,date: widget.date ,equipId: data.equipment_id.toString(),
                                              detection_id:data.detected_table_id,time:time),
                                            ),
                                          );
                                        },
                                      )
                                  ),
                                  DataCell(
                                      GestureDetector(
                                        child:  Center(
                                          child: Text( data.inserted_on.toString().substring(0, data.inserted_on.toString().length - 3), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                        ),
                                        onTap: () {
                                          DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(data.inserted_on.toString());
                                          String time = DateFormat("HH:mm:ss").format(dateTime);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductWiseClustermanager(storeId: widget.storeId,date: widget.date ,equipId: data.equipment_id.toString(),
                                                  detection_id:data.detected_table_id,time:time),
                                            ),
                                          );
                                        },
                                      )
                                  ),
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


  Future<List<ClusterManagerEquipmentWise>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_clustermanager_equipment_wise"),
        body: json.encode({"date":widget.date.toString(),"store_id":widget.storeId.toString(),"compliant":widget.compliant.toString()}),
        headers: {
          "content-type": "application/json",
        });
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<ClusterManagerEquipmentWise> emplist = await resultsJson
        .map<ClusterManagerEquipmentWise>((json) => ClusterManagerEquipmentWise.fromJson(json))
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





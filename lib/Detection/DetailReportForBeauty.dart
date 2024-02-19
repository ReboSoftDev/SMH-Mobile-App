import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:sample/HomeMenu.dart';
import 'package:flutter/services.dart';
import 'package:sample/apimanager.dart';
import 'dart:convert';
import 'package:sample/model.dart';
import 'package:http/http.dart' as http;
class DetailedReportForBeauty extends StatefulWidget {
  const DetailedReportForBeauty({Key? key, required this.eqpt, required this.stid})
      : super(key: key);
  final String? eqpt;
  final String? stid;

  @override
  State<DetailedReportForBeauty> createState() => _DetailedReportForBeautyState();
}

class _DetailedReportForBeautyState extends State<DetailedReportForBeauty> {
  String? dropdownValue;
  String? productcode;
  int currentIndex = 0;

  final _formKey = GlobalKey<FormState>();

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Detailed Report', style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 50.2,
            toolbarOpacity: 0.8,
            backgroundColor: Colors.black,
            elevation: 0.00,
          ),
          body: Column(children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
            child:Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columnSpacing: 30,
                headingRowHeight: 80,

                headingRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                columns: const [
                  DataColumn(
                      label: Center(
                          child: Text('Tray', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)))),
                  DataColumn(
                      label: Center(child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)))),
                  DataColumn(
                      label: Center(child: Text('  Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)))),
                  DataColumn(
                      label: Center(child: Text('                   Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)))),
                  DataColumn(
                      label: Center(child: Text('Missing\nQuantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)))),
                  DataColumn(
                      label: Center(child: Text('No.of\nTester\nAvailable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)))),
                  DataColumn(
                      label: Center(child: Text('No.of\nTester\nOpen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)))),
                  DataColumn(
                      label: Center(child: Text('No.of\nTester\nClose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)))),
                ],
                rows: [],
              ),
            ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child:
                        /// Beauty Tray Details
                        Container(

                          child: FutureBuilder<List<beautyCompliance>>(
                            initialData: const <beautyCompliance>[],
                            future: fetchResults(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError ||
                                  snapshot.data == null ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return Container(
                                    alignment: Alignment.center,
                                    height: 150,
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                        )));
                              }

                              return FittedBox(
                                // width: double.infinity,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columnSpacing: 20,
                                        headingRowHeight: 0,
                                        dataRowHeight: 60,
                                        headingRowColor: MaterialStateColor.resolveWith(
                                                (states) => Colors.black45),
                                        columns: const [
                                          DataColumn(
                                            label: Center(
                                              child: Text('Tray', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Missing\nQuantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))),
                                          ),
                                          DataColumn(
                                              label: Center(child: Text('No.of Tester\nAvailable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)))),
                                          DataColumn(
                                              label: Center(child: Text('No.of Tester\nOpen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)))),
                                          DataColumn(
                                              label: Center(child: Text('No.of Tester\nClose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)))),
                                        ],
                                        rows: List.generate(
                                          snapshot.data!.length,
                                              (index) {
                                            var data = snapshot.data![index];
                                            return DataRow(
                                              color: MaterialStateProperty.resolveWith<Color>(
                                                    (Set<MaterialState> states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                                                  }

                                                  // Even rows will have a grey color.
                                                  if (index % 2 == 0) {
                                                    return Colors.white;
                                                  }
                                                  return Colors.white.withOpacity(0.2);
                                                },
                                              ),
                                              cells: [
                                                DataCell(
                                                  Container(
                                                    width:30,

                                                      child: Text(
                                                        data.vm_position.toString(),
                                                        textAlign: TextAlign.right,
                                                        style: const TextStyle(fontSize: 18),
                                                      ),

                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width:100,
                                                    child: Center(
                                                      child: Text(
                                                        data.product_code.toString(),
                                                        textAlign: TextAlign.right,
                                                        style: const TextStyle(fontSize: 18),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width:200,

                                                      child: Text(
                                                        data.vm_colour.toString(),
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18),
                                                      ),


                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width:30,
                                                      child: Text(
                                                        data.detected_quantity.toString(),
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18),
                                                      ),

                                                  ),
                                                ),
                                                DataCell(
                                                  GestureDetector(
                                                    child: Center(
                                                      child: Text(
                                                        data.missing_quantity.toString(),
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18),
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                  ),
                                                ),
                                                DataCell(
                                                  GestureDetector(
                                                    child: Center(
                                                      child: Text(
                                                        index == 0 ? data.tester_not_present.toString(): '',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // Handle onTap event if needed
                                                    },
                                                  ),
                                                ),
                                                DataCell(
                                                  GestureDetector(
                                                    child: Center(
                                                      child: Text(
                                                        index == 0 ?  data.tester_present_not_empty.toString() : '',

                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // Handle onTap event if needed
                                                    },
                                                  ),
                                                ),
                                                DataCell(
                                                  GestureDetector(
                                                    child: Center(
                                                      child: Text(
                                                        index == 0 ?  data.tester_present_empty.toString(): '',
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // Handle onTap event if needed
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList(),
                                      )
                                  ));
                            },
                          ),
                        ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          ]),
        );
  }

  Future<List<beautyCompliance>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);

    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_beauty_compliance/${widget.stid}/${widget.eqpt!}");
    var response = await ioClient.get(url);
    var resultsJsonfirst = json.decode(response.body).cast<Map<String, dynamic>>();
    List<beautyCompliance> emplist = await resultsJsonfirst
        .map<beautyCompliance>((json) => beautyCompliance.fromJson(json))
        .toList();
    return emplist;
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
}



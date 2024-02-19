import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

import '../../model.dart';

class SeniorGoogleReviews extends StatefulWidget {
  final String username;

  const SeniorGoogleReviews({Key? key, required this. storeCode,required this. year,required this.month, required this. rating, required this.username}) : super(key: key);
  final String storeCode;
  final String year;
  final String month;
  final String rating;

  @override
  State<SeniorGoogleReviews> createState() => _HomePageState();
}
class _HomePageState extends State<SeniorGoogleReviews> {
  // with TickerProviderStateMixin
  int Nodata = 0;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchResults();
  }

  @override
  dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(title: const Text(
              'Google Feedback', style: TextStyle(fontSize: 16,color: Colors.white)),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),

            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 50.2,
            toolbarOpacity: 0.8,
            backgroundColor: Colors.black,
            elevation: 0.00,
          ),
          body:Column(
            children:  [
              Container(
                width: 2500,
                color: Colors.black45,
                child: Row(
                  children: [
                    FittedBox(
                        fit: BoxFit.fill,
                        child: DataTable(
                          dataRowHeight: 50,
                          headingRowHeight: 50,

                          // headingRowColor:
                          // MaterialStateColor.resolveWith((states) =>
                          // Colors.black45),
                          columns: const [
                            DataColumn(label: Text('                   Bad Reviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                            DataColumn(label: Text('                                                        Feedback Buckets',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                          ], rows: const [],
                        )
                    ),
                  ],
                ),
              ),


              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<List<googleReviews>>(
                    initialData: const <googleReviews>[],
                    future:  fetchResults(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            alignment: Alignment.center,
                            height: 150,

                            child:const Center(child:CircularProgressIndicator(color: Colors.black,))
                        ) ;
                      }
                      return
                        Nodata == 1?
                        Container(
                            height: 200,
                            child: const Center(child:Text('Empty Data',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),))):
                        FittedBox(
                          child: DataTable(
                            dataRowHeight: 50,
                            headingRowHeight: 0,
                            columnSpacing: 100,
                            // headingRowColor:
                            // MaterialStateColor.resolveWith((states) =>
                            // Colors.black45),
                            columns: const [
                              DataColumn(label: Text('Bad Reviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),)),
                              DataColumn(label: Text('Feedback Buckets',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),)),
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
                                            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                                          }
                                          // Even rows will have a grey color.
                                          if (index % 2 == 0) {
                                            return Colors.white;
                                          }
                                          return Colors.white.withOpacity(0.2);
                                        }),
                                    cells: [
                                      DataCell(
                                          Container(
                                            width: 0.5 *  MediaQuery.of(context).size.width,

                                            child: Text(data.badReviews.toString(), textAlign: TextAlign.left, style: const TextStyle(fontSize: 15),),

                                          )
                                      ),
                                      DataCell(
                                        Container(
                                          // color:Colors.yellow,
                                          // width: 0.5 *  MediaQuery.of(context).size.width,
                                          child: Text(data.feedbackBuckets.toString(), textAlign: TextAlign.left, style: const TextStyle(fontSize: 15),),
                                        ),)

                                    ]);
                              },
                            ).toList(),
                          ),
                        );
                    },
                  ),
                ),
              )
            ],
          )
    );
  }
  Future<List<googleReviews>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/getGoogleReviews/${widget.storeCode}/${widget.year}/${widget.month}/${widget.rating}");
    var response = await ioClient.get(url);
    print("successAPI");
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<googleReviews> emplist = await resultsJson
        .map<googleReviews>((json) => googleReviews.fromJson(json))
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


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:sample/model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AlternateProductCompliance extends StatefulWidget {
  const AlternateProductCompliance({Key? key, required this. storeCode,required this. materialGroup,required this. season, this. equipType}) : super(key: key);
  final String storeCode;
  final String materialGroup;
  final String season;
  final String? equipType;

  @override
  State<AlternateProductCompliance> createState() => _HomePageState();
}
class _HomePageState extends State<AlternateProductCompliance> {
  // with TickerProviderStateMixin

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
    super.dispose();
  }
  double? sitQty;
int Nodata = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: const Text(
            'Alternate Products', style: TextStyle(fontSize: 16,color: Colors.white)),
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
              FittedBox(
                fit: BoxFit.fill,
                  child: DataTable(
            headingRowHeight: 60,
             columnSpacing: 90,
            headingRowColor:
            MaterialStateColor.resolveWith((states) =>
            Colors.black45),
            columns: const [
              DataColumn(label: Text('Product Code',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
              DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
              DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
              DataColumn(label: Text('Colour',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
              DataColumn(label: Text('SAP Qty ',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white,),)),
              DataColumn(label: Text('SIT Qty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white,),)),


            ], rows: const [],
                )
              ),

                Expanded(
                child: SingleChildScrollView(
                child:
                FutureBuilder<List<alternateProduct>>(
                  initialData: const <alternateProduct>[],
                  future:  fetchResults(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                       return Container(
                          alignment: Alignment.center,
                          height: 200,

                          child:Center(child:CircularProgressIndicator(color: Colors.black,))
                      ) ;


                    }
                    List<Map<String, dynamic>> tableData = [];
                    if (snapshot.data != null) {
                      for (alternateProduct alternate in snapshot.data!) {
                        var articleNo = alternate.material_no.toString();
                        String extractedArticleNo = articleNo.substring(articleNo.length - 12);
                        String productCode = extractedArticleNo.substring(0, extractedArticleNo.length - 3);
                        sitQty = alternate.transQty?.toDouble();
                        if(alternate.sap != 0 ){
                          tableData.add({
                            'productCode':productCode.toString(),
                            'articleNumber':extractedArticleNo.toString(),
                            'size':alternate.size.toString(),
                            'color':alternate.colour.toString(),
                            'sap':alternate.sap.toString(),
                            'transQty':sitQty.toString(),

                          });
                        }


                      }
                    }




                    return
                    Nodata == 1?
                        Container(
                          height: 200,
                          child: Center(child:Text('No Alternate Products',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),))):
                      FittedBox(
                        child: DataTable(
                        dataRowHeight: 50,
                        headingRowHeight: 0,
                        columnSpacing: 100,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) =>
                        Colors.black45),
                        columns: const [
                          DataColumn(label: Text('Product Code',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),)),
                          DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),)),
                          DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),)),
                          DataColumn(label: Text('Colour',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),)),
                          DataColumn(label: Text('SAP Qty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),),
                          DataColumn(label: Text('Transit Qty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),)

                        ],
                          rows: tableData.map((data) {


                            return DataRow(
                                color: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.selected)) {
                                        return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                                      }
                                      // Even rows will have a grey color.
                                      // if (index % 2 == 0) {
                                      //   return Colors.white;
                                      // }
                                      return Colors.white.withOpacity(0.2);
                                    }),
                                cells: [
                                  DataCell(
                                    Center(
                                      child: Text(data['productCode'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['articleNumber'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['size'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['color'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['sap'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['transQty'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
                                    ),
                                  ),
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
  Future<List<alternateProduct>> fetchResults() async {
    print(widget.storeCode);
    print(widget.materialGroup);
    print(widget.season);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    DateTime startTime = DateTime.now();
    // Record the start time
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_material_master"),
        body: json.encode({
          "storeCode": widget.storeCode.toString(),
          "materialGroup": widget.materialGroup.toString(),
          "season": widget.season.toString()
        }),
        headers: {
          "content-type": "application/json",
        });
    DateTime endTime = DateTime.now(); // Record the end time
    Duration fetchTime = endTime.difference(startTime); // Calculate the duration between start and end time

    print("Fetch time: ${fetchTime.inMilliseconds} milliseconds");
    print(response.statusCode);
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
 // Calculate the duration between start and end time
    print("Fetch time: ${fetchTime.inMilliseconds} milliseconds");
    var resultJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultJson);
    if (resultJson.isEmpty) {
      print('No data');
      Nodata = 1;
    } else {
      // Process the data when it is not empty
      // ...
    }
    List<alternateProduct> emplist = await resultJson
        .map<alternateProduct>((json) => alternateProduct.fromJson(json))
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


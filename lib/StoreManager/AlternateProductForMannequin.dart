import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:sample/model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AlternateProductForMannequin extends StatefulWidget {
  const AlternateProductForMannequin({Key? key, required this. storeCode, this. equipType, required this. eqId}) : super(key: key);
  final String storeCode;
  final String? equipType;
  final String? eqId;

  @override
  State<AlternateProductForMannequin> createState() => _AlternateProductForMannequinState();
}
class _AlternateProductForMannequinState extends State<AlternateProductForMannequin> {
  // with TickerProviderStateMixin
  List<Map<String, dynamic>> codeSumList = [];
  @override
  void initState() {
    super.initState();
    fetchResults();
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
  int Nodata = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text(
            'Alternate Products',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          titleSpacing: 0.0,
          centerTitle: true,
          toolbarHeight: 50.2,
          toolbarOpacity: 0.8,
          backgroundColor: Colors.black,
          elevation: 0.00,
        ),
        body: Column(
            children: [
              FittedBox(
                child: DataTable(
                  dataRowHeight: 50,
                  headingRowHeight: 50,
                  // columnSpacing: 100,
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.black45),
                  columns: const [
                    DataColumn(
                      label: Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(label: Text('Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(label: Text('SAP Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Material Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                      ),
                      ),
                    ),
                  ],
                  rows:[]
                ),
              ),



              Expanded(
              child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
             scrollDirection: Axis.vertical,

            child: Column(
               children: [

                Container(
                child: DataTable(
                  dataRowHeight: 40,
                  headingRowHeight: 0,
                  columnSpacing: 50,
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.black45),
                  columns: const [
                    DataColumn(
                      label: Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(label: Text('Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SAP Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Material Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  rows: codeSumList.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(
                        item['code'],
                        style: const TextStyle(fontSize: 15, color: Colors.black),
                      )),
                      DataCell(Text(item['color'])),
                      DataCell(Text(item['sumSystemQty'].toString())),
                      DataCell(Text(item['materialGroup'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
              ],
             ),
              ),
              ),
              if (codeSumList.isEmpty)
                const Center(
                  // child:Container (
                  //   padding: const EdgeInsets.only(left:0, bottom: 0, right: 0, top:10),
                    child: CircularProgressIndicator(color: Colors.black,),
                 //) ,// Display circular progress indicator in center
                ),
               // Display circular progress indicator if codeSumList is empty
            ],
          ),

      );
  }


  Future<void> fetchResults() async {
    print("api ...........fetching...........");
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);

    if(widget.eqId.toString() == '251' || widget.eqId.toString() == '232')
      {
        Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_trendywall_codes_for_alternate_Mens");
        var response = await ioClient.get(url);
        var trendywallJson = json.decode(response.body);

        List<String> codes = trendywallJson['codes'].toString().split(', ');
        for (String code in codes) {
          final secondResponse = await ioClient.post(
            Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
            body: json.encode({
              "storeCode": widget.storeCode.toString(),
              "code": code.trim(),
            }),
            headers: {
              "content-type": "application/json",
            },
          );
          var codeResponse = json.decode(secondResponse.body);
          double sumSystemQty = 0.0;
          String color = "Nil"; // Default color when data is empty
          String materialGroup = "Nil"; // Default color when data is empty

          if (codeResponse.isNotEmpty) {
            for (var item in codeResponse) {
              sumSystemQty += item['systemQty'];
            }
            color = codeResponse[0]['color'];
            materialGroup = codeResponse[0]['materialGroup'];
          }

          codeSumList.add({
            'code': code.trim(),
            'color': color,
            'sumSystemQty': sumSystemQty,
            'materialGroup': materialGroup,
          });
        }
        setState(() {
          codeSumList.sort((a, b) => b['sumSystemQty'].compareTo(a['sumSystemQty']));
        });
      }
    else{
      Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_trendywall_codes_for_alternate_Womens");
      var response = await ioClient.get(url);
      var trendywallJson = json.decode(response.body);

      List<String> codes = trendywallJson['codes'].toString().split(', ');
      for (String code in codes) {
        final secondResponse = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
          body: json.encode({
            "storeCode": widget.storeCode.toString(),
            "code": code.trim(),
          }),
          headers: {
            "content-type": "application/json",
          },
        );

        var codeResponse = json.decode(secondResponse.body);
        double sumSystemQty = 0.0;
        String color = "Nil"; // Default color when data is empty
        String materialGroup = "Nil"; // Default color when data is empty

        if (codeResponse.isNotEmpty) {
          for (var item in codeResponse) {
            sumSystemQty += item['systemQty'];
          }
          color = codeResponse[0]['color'];
          materialGroup = codeResponse[0]['materialGroup'];
        }

        codeSumList.add({
          'code': code.trim(),
          'color': color,
          'sumSystemQty': sumSystemQty,
          'materialGroup': materialGroup,
        });
      }

      setState(() {
        codeSumList.sort((a, b) => b['sumSystemQty'].compareTo(a['sumSystemQty']));
      });

      print(codeSumList);

    }

  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
}


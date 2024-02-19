import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/io_client.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:sample/Menu/StockQuery.dart';
import '../StoreManager/AlternateProductCompliance.dart';
import '../StoreManager/AlternateProductForMannequin.dart';
import '../VMProductImage.dart';
import 'package:flutter/services.dart';
import 'package:sample/apimanager.dart';
import 'dart:convert';
import 'package:sample/model.dart';
import 'package:http/http.dart' as http;


class FirstDetailedReport extends StatefulWidget {
  const FirstDetailedReport({Key? key,required this.eqpt,required this.stid, this. equipType, required this. orientation}) : super(key: key);
  final String? eqpt;
  final String? stid;
  final String? equipType;
  final String? orientation;

  @override
  State<FirstDetailedReport> createState() => _FirstDetailedReportState();
}

class _FirstDetailedReportState extends State<FirstDetailedReport> {
  String? dropdownValue;
  String? productcode ;
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
    if(widget.orientation == 'landscape')
      {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    else{
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: const Text('Detailed Report', style: TextStyle(fontSize: 16,color: Colors.white),),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios,color:Colors.white)),

          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 50.2,
          toolbarOpacity: 0.8,
          backgroundColor: Colors.black,
          elevation: 0.00,
        ),
        body: Column(
          children:  [
            FittedBox(
              child:DataTable(
                headingRowHeight: 60,
                dataRowHeight: 60,
                headingRowColor:
                MaterialStateColor.resolveWith((states) =>
                Colors.black45),
                columns: [
                  const DataColumn(label: Center(child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                  const DataColumn(label: Center(child: Text('          Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                  const DataColumn(label: Center(child: Text('       Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                  if(widget.equipType.toString() == 'Table')
                    const DataColumn(label: Center(child: Text('Size Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    const DataColumn(label: Center(child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                  if (widget.equipType.toString() == 'Table' || widget.equipType.toString() == 'R4' || widget.equipType.toString() == 'WallTable' )
                    const DataColumn(label: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    const DataColumn(label: Center(child: Text('Signage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                ], rows: [],
              ),
            ),

           Expanded(

             child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,

               child: Column(
                 children: [

                 Container(
                  // snapshot.hasError ||
                   child: FutureBuilder<List<Compliance>>(
                  initialData: const <Compliance>[],
                  future:fetchResults(),
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

                    return FittedBox(
                      // width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowHeight: 0,
                              dataRowHeight: 60,
                              headingRowColor:
                              MaterialStateColor.resolveWith((states) =>
                              Colors.black45),
                              columns:  [
                                const DataColumn(label: Center(child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white,)))),
                                const DataColumn(label: Center(child: Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                                const DataColumn(label: Center(child: Text('Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                                if(widget.equipType.toString() == 'Table')
                                  const DataColumn(label: Center(child: Text('Size Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                                  const DataColumn(label: Center(child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                                if (widget.equipType.toString() == 'Table' || widget.equipType.toString() == 'R4' || widget.equipType.toString() == 'WallTable' )
                                  const DataColumn(label: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                                  const DataColumn(label: Center(child: Text('Signage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
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
                                            child: data.fileContents.toString() == null ?
                                            const Center(child:Text("No Image")):
                                            Image.memory(base64Decode(data.fileContents.toString()),width: 40,),

                                            onTap: () {
                                              String imagePath = data.fileContents.toString();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VMProductImage(path: imagePath),),);

                                            },
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            child: Center(child:Text(data.productcode.toString(), textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),)),
                                            onTap: () {
                                              print("${data.productcode}:product");
                                            },
                                          ),
                                        ),
                                        DataCell(
                                            GestureDetector(
                                              child: data.color.toString() == "0" ?
                                              const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                              const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)),

                                              onTap: () {
                                                if (data.color.toString() == "0" || data.color.toString() == "1" ) {
                                                  String productcode = data.productcode.toString();
                                                  String dpValue = widget.eqpt.toString();
                                                  String stValue = widget.stid.toString();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => ColourScreen(title: productcode,dp: dpValue,st: stValue ),
                                                  );
                                                }

                                              },
                                            )
                                        ),
                                        if (widget.equipType.toString() == 'Table')
                                          DataCell(
                                              GestureDetector(
                                              child: data.sizeratio.toString() == "0" ?
                                              const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                              const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)),
                                              onTap: () {
                                                if (data.sizeratio.toString() == "0" || data.sizeratio.toString() == "1") {
                                                  String productcode3 = data.productcode.toString();
                                                  String dpValue = widget.eqpt.toString();
                                                  String stValue = widget.stid.toString();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => SizeratioScreen(title: productcode3,dp: dpValue ,st: stValue),
                                                  );
                                                }

                                              },
                                            )
                                        ),
                                        DataCell(
                                            GestureDetector(
                                              child: data.product.toString() == "0" ?
                                              const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                              const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)),
                                              onTap: () {

                                                if (data.product.toString() == "0" || data.product.toString() == "1" ) {
                                                  String productcode4 = data.productcode.toString();
                                                  String dpValue = widget.eqpt.toString();
                                                  String stValue = widget.stid.toString();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => ProductScreen(title: productcode4,dp: dpValue,st: stValue,equipType:widget.equipType ),
                                                  );
                                                }
                                                print("${data.productcode}:product");
                                              },
                                            )
                                        ),
                                        if (widget.equipType.toString() == 'Table' || widget.equipType.toString() == 'R4' || widget.equipType.toString() == 'WallTable' )
                                        DataCell(

                                          data.quantity.toString() == "2" ?
                                          const Center(child:Icon(Icons.circle, color: Colors.orange,size: 25,)):
                                          data.quantity.toString() == "0" ?
                                          const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                          const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)),
                                              onTap: () {
                                                if (data.quantity.toString() == "0" || data.quantity.toString() == "1" || data.quantity.toString() == "2" ) {
                                                  String productcode5 = data.productcode.toString();
                                                  String dpValue = widget.eqpt.toString();
                                                  String stValue = widget.stid.toString();

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => QuantityScreen(title: productcode5,dp: dpValue,st: stValue, ),
                                                  );
                                                }
                                                print("${data.productcode}:product");
                                              },

                                        ),
                                        DataCell(
                                            GestureDetector(

                                              child: widget.equipType.toString() == 'Mannequin'?
                                      data.mannequin_signage.toString() == "0" ?
                                                const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                                const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)):
                                      data.signage.toString() == "0" ?
                                              const Center(child:Icon(Icons.close, color: Colors.red,size: 25,)):
                                              const Center(child:Icon(Icons.check, color: Colors.green,size: 25,)),
                                              onTap: () {
                                                if (data.signage.toString() == "0" || data.signage.toString() == "1") {
                                                  String productcode6 = data.productcode.toString();
                                                  String dpValue = widget.eqpt.toString();
                                                  String stValue = widget.stid.toString();

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => SignageScreen(title: productcode6,dp: dpValue,st: stValue ),
                                                  );
                                                }
                                                print("${data.mannequin_signage}:signage");
                                              },
                                            )
                                        ),
                                      ]);
                                },
                              ).toList(),

                            )
                        )
                    );
                  },
                ),
               ),
              ],
            ),

           ),

          ),
          ]
          ),

    );

  }

  Future<List<Compliance>> fetchResults() async {
    print("equipType.......${widget.equipType}");
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_all_compliance/${widget.stid}/${widget.eqpt!}");
    var response = await ioClient.get(url);
    print("successAPI");
    var resultsJsonfirst = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Compliance> emplist = await resultsJsonfirst
        .map<Compliance>((json) => Compliance.fromJson(json))
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







class ColourScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const ColourScreen({Key? key, required this.title,required,required this.dp,required this.st}) : super(key: key);
// Step 2 <-- SEE HERE
final String title;
final String dp;
final String st;

@override
State<ColourScreen> createState() => _ColourScreenState();
}
class _ColourScreenState extends State<ColourScreen> {



  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      title: const Text("Colour Compliance", style: TextStyle(fontSize: 16),),


      content:
      FutureBuilder<List<Comp>>(

        initialData: const <Comp>[],
        future:fetchComp(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...");
          }
          print(widget.title);



          return SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowHeight: 50,
                columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                headingRowColor:
                MaterialStateColor.resolveWith((states) =>
                Colors.black45),
                columns: const [
                  DataColumn(label: Text('Product\nCode', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
                  DataColumn(label: Text('Required\nColour', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
                  // DataColumn(label: Text('Actual\nColour', style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 12,
                  //     color: Colors.white)),),
                  DataColumn(label: Text('Action\nRequired', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
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
                              Container(
                                  child:  Text('${widget.title}', textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 12))
                              )),
                          DataCell(
                              Container(
                                  child:  Text(data.v_color.toString(), textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 12))
                              )
                          ),
                          // DataCell(
                          //     Container(
                          //
                          //
                          //       child: Text(data.d_color.toString(), textAlign: TextAlign.left,
                          //         style: TextStyle(fontSize: 12),),
                          //     )),
                          DataCell(
                            Container(

                              child: const Text("Change\nColour", textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 12),),
                            ),
                          )
                        ]);
                  },
                ).toList(),

              )

          );
        },
      ),

    );

  }
  Future<List<Comp>> fetchComp() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_all_popup_compliance/${widget.st}/${widget.dp}/${widget.title}");
    var response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<Comp> emplist = await resultsJson
        .map<Comp>((json) => Comp.fromJson(json))
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




/////////////////////////SizeRatio Compliance ///////////////////////////



    class SizeratioScreen extends StatefulWidget {
    // In the constructor, require a Todo.
    const SizeratioScreen({Key? key, required this.title,required this.dp,required this.st}) : super(key: key);
    // Step 2 <-- SEE HERE
    final String title;
    final String dp;
    final String st;

      @override
      State<SizeratioScreen> createState() => _SizeratioScreenState();
      }
    class _SizeratioScreenState extends State<SizeratioScreen> {

    @override
    void initState() {
  }
    String? store;
    String? product;
    String? equipment;
    String? storecode;
    double?  systemQty;
    double?  sitQty ;
    String  season = "gg";
    String  materialGroup = "dd";
    String v_sizeCount = '';
    String d_sizeCount = '';
    int  diff = 0;
    var message;
    var storeGate;
    String? articleCode;
    String? barcodeValue;
    String cheatSize = '0';
    double?  TsystemQty  ;
    double?  TposQty ;
    int access = 0;


   @override
   Widget build(BuildContext context) {
     return AlertDialog(

      title: const Text("Size", style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
                child: FutureBuilder<List<dynamic>>(
                  initialData: const <dynamic>[],
                  future: fetchCombinedData(),
                 builder: (context, snapshot) {
                if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading...");
              }
              List<Comp> compList = snapshot.data![1];
              List<stockQuery> stockList = snapshot.data![0];

    print(widget.title);
    List<Map<String, dynamic>> tableData = [];
    for (int i = 0; i < compList.length; i++) {
    Comp comp = compList[i];
    v_sizeCount = comp.sizeCount.toString();
    d_sizeCount = comp.quantity.toString();
    var a = int.parse(comp.sizeCount.toString());
    var b = int.parse(comp.quantity.toString());
    diff = a - b;

      diff > 0 ? message = "Add\n${NumberToWordsEnglish.convert(diff)} - ${comp.size.toString()}" : message = "Remove \n${NumberToWordsEnglish.convert(diff)} - ${comp.size.toString()}" ;

      for (int i = 0; i < stockList.length; i++) {
            stockQuery stock = stockList[i];

            if (storecode == stock.storeCode) {
              if (comp.size.toString() == stock.size.toString()) {

                    systemQty = stock.sap?.toDouble();
                    sitQty = stock.trans_qty?.toDouble();

                  var articleNo = stock.material_code.toString();
                  String extractedArticleNo = articleNo.substring(articleNo.length - 12);
                  tableData.add({
                      'articleNo': extractedArticleNo.toString(),
                      'size': stock.size.toString(),
                      'v_quantity': comp.sizeCount.toString(),
                      'd_quantity': comp.quantity.toString(),
                      'difference': diff.toString(),
                      'sap': systemQty.toString(),
                      'sit': sitQty.toString(),
                      'message': message.toString(),

          });
              }
            }
      }
    }

              return FittedBox(
      child: DataTable(

        columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
        headingRowHeight: 50,
        headingRowColor:
        MaterialStateColor.resolveWith((states) =>
        Colors .black45),
        columns: const [

          DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('Required\nSize Count',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('Actual\nSize Count',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('Difference',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('SAP\nQTY',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('SIT\nQTY',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
          DataColumn(label: Text('Action\nRequired',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
        ],
        rows: tableData.map((data) {

          return DataRow(
          color: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }

        return Colors.white.withOpacity(0.2);
        }),

        cells: [
          DataCell(
            Container(

            child: Text(data["articleNo"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14))
              )
            ),
        DataCell(
            Container(
            child: Text(data["size"],textAlign:TextAlign.right,style: TextStyle(fontSize: 14))
          )),
          DataCell(
            Container(

          child: Text(data["v_quantity"],textAlign:TextAlign.right,style: TextStyle(fontSize: 14))
            )
          ),
        DataCell(
            Container(

          child: Text(data["d_quantity"],textAlign:TextAlign.right,style: TextStyle(fontSize: 14),),
          )),
        DataCell(
            Container(

          child: Text(data["difference"],textAlign:TextAlign.right,style: TextStyle(fontSize: 14),),
          ),
        ),

          DataCell(
              Container(

            child:Text(data["sap"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),
            )),
              DataCell(Container(
                          child: Text(data["sit"],textAlign: TextAlign.left,style: TextStyle(fontSize: 14),
                          ),
                        )),
                        DataCell(
          Container(

        child:Text(data["message"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),

          ),
        )
      ]);
      }).toList(),
      )
      );
      },
      ),
      )
      );
      }


      Future<List<dynamic>> fetchCombinedData() async {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);

      final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.st.toString()}),
      headers: {
      "content-type": "application/json",
      },
    );
    var storeJson = json.decode(storeResponse.body);
    storecode = storeJson[0]['code'];
    print("storeCode.......$storecode");

    final stockResponse = await ioClient.post(
    Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
    body : json.encode({
    "storeCode": storecode.toString(),
    "code": widget.title.toString(),
    }),
    headers: {
    "content-type": "application/json",
    },
    );

    final complianceResponse = await ioClient.post(
    Uri.parse("https://smh-app.trent-tata.com/flask/get_detected_size"),
    body: json.encode({"storeId": widget.st.toString(), "equipmentId": widget.dp.toString(), "product_code": widget.title.toString(),
    }),
    headers: {
    "content-type": "application/json",
    },
    );


    var stockJson = json.decode(stockResponse.body).cast<Map<String, dynamic>>();
    var complianceJson = json.decode(complianceResponse.body).cast<Map<String, dynamic>>();
    List<stockQuery> stockList = stockJson.map<stockQuery>((json) => stockQuery.fromJson(json)).toList();
    List<Comp> compList = complianceJson.map<Comp>((json) => Comp.fromJson(json)).toList();

     return [stockList, compList];
  }



  Future<SecurityContext> get globalContext async {
  final sslCert1 = await
  rootBundle.load('assets/starttrent.pem');
  SecurityContext sc = SecurityContext(withTrustedRoots: false);
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  return sc;
  }

  }



/////////////////////////Product Compliance //////////////////////

class ProductScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const ProductScreen({Key? key, required this.title,required this.dp,required this.st, this. equipType}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String title;
  final String dp;
  final String st;
  final String? equipType;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}
class _ProductScreenState extends State<ProductScreen> {


  @override
  void initState() {
  }
  String? store;
  String? product;
  String? equipment;
  String? storecode;
  double  systemQty = 0.0;
  double  sitQty = 0.0;
  var storeGate;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Product Compliance", style: TextStyle(fontSize: 16),),
      content:
          SingleChildScrollView(
      child:FutureBuilder<List<stockQuery>>(
        initialData:  const <stockQuery>[],
        future:fetchResults(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...");
          }
          List<Map<String, dynamic>> tableData = [];

      if (snapshot.data != null) {
        for (stockQuery stockquery in snapshot.data!) {
           if (storecode == stockquery.storeCode) {
             var articleNo = stockquery.material_code.toString();
             String extractedArticleNo = articleNo.substring(articleNo.length - 12);
             sitQty = stockquery.trans_qty!.toDouble();
            tableData.add({
              'productCode':widget.title.toString(),
              'sap': stockquery.sap.toString(),
              'sit': sitQty.toString(),
              'articleNo': extractedArticleNo.toString(),
              'size' :stockquery.size.toString(),
              'colour' :stockquery.colour.toString(),
              'message' :"Click for Detail",
              'season' :stockquery.season.toString(),
              'materialGroup':stockquery.materialGroup.toString(),
            });
          }
         }
       }


          return SizedBox(
              width: double.infinity,
              child: DataTable(

                columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                headingRowHeight: 50,
                headingRowColor:
                MaterialStateColor.resolveWith((states) =>
                Colors.black45),
                columns: const [
                  DataColumn(label: Text('Product\nCode',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('Colour',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('SAP\nQty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('SIT\nQty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                  DataColumn(label: Text('Alternate\nProducts',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                ],
                rows: tableData.map((data) {
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
                            // if (index % 2 == 0) {
                            //   return Colors.white;
                            // }
                            return Colors.white.withOpacity(0.2);
                          }),

                      cells: [
                        DataCell(
                            Container(
                                child:Text(data['productCode'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12))
                            )),

                        DataCell(
                            Container(
                              child:Text(data['articleNo'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),),
                            )),
                        DataCell(
                            Container(
                              child:Text(data['size'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),),
                            )),
                        DataCell(
                            Container(
                              child:Text(data['colour'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),),
                            )),


                        DataCell(
                            Container(
                              child:Text(data['sap'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),),
                            )),
                       DataCell(Container(
                              child: Text(data['sit'],textAlign: TextAlign.left,style: TextStyle(fontSize: 12),
                              ),
                            )),
                            DataCell(
                          GestureDetector(

                              child: Text(data['message'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12,color: Colors.purple,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
                              onTap: (){
                                if(widget.equipType.toString() == "Mannequin")
                                {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => AlternateProductForMannequin(storeCode: storecode.toString(),equipType : widget.equipType,eqId:widget.dp
                                   ),
                                  ),
                                 );
                                 }
                                else{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlternateProductCompliance(storeCode: storecode.toString(), materialGroup: data['materialGroup'],season:data['season'],
                                     equipType : widget.equipType
                                    ),
                                  ),
                                );
                              }

                                }
                          ),
                        )
                      ]);
                }).toList(),
              )
          );
        },
      ),
          )
    );
  }


  Future<List<stockQuery>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response_store = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
        body: json.encode({"storeId": widget.st.toString()}),
        headers: {
          "content-type": "application/json",
        });
    var resultsJson = json.decode(response_store.body);
    storecode = resultsJson[0]['code'];
    print("storeCode.......$storecode");
    final response = await ioClient.post(
        Uri.parse(
            "https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
        body: json.encode({
          "storeCode": storecode.toString(),
          "code": widget.title.toString()
        }),
        headers: {
          "content-type": "application/json",
        });
    print(response.statusCode);
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }

    var resultJson = json.decode(response.body).cast<Map<String, dynamic>>();

    print(resultJson);
    List<stockQuery> emplist = await resultJson
        .map<stockQuery>((json) => stockQuery.fromJson(json))
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




/////////////////Quantity Compliance ////////////////////////

class QuantityScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const QuantityScreen({Key? key, required this.title,required this.dp,required this.st}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String title;
  final String dp;
  final String st;

  @override
  State<QuantityScreen> createState() => _QuantityScreenState();
}
class _QuantityScreenState extends State<QuantityScreen> {

  @override
  void initState() {
  }
  String? store;
  String? product;
  String? equipment;
  String? storecode;
  double?  systemQty;
  double?  sitQty;
  var storeGate;
  String v_sizeCount = '';
  String d_sizeCount = '';
  var diff;
  var message;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      title: const Text("Quantity Compliance", style: TextStyle(fontSize: 16),),
      content:
          SingleChildScrollView(
        child:FutureBuilder<List<dynamic>>(
          initialData: const <dynamic>[],
          future: fetchCombinedData(),
          builder: (context, snapshot) {
            if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            List<Comp> compList = snapshot.data![1];
            List<stockQuery> stockList = snapshot.data![0];

            List<Map<String, dynamic>> tableData = [];

            for (int i = 0; i < compList.length; i++) {
              Comp comp = compList[i];
              v_sizeCount = comp.sizeCount.toString();
              d_sizeCount = comp.quantity.toString();
              var a = int.parse(comp.sizeCount.toString());
              var b = int.parse(comp.quantity.toString());
              diff = a - b;
              if (diff > 0) {
                message =
                    "Add\nto display";
              } else if (diff < 0) {
                message =
                    "Remove from\nthe display";
              } else {
                message = "Nil";
              }

              for (int i = 0; i < stockList.length; i++) {
                stockQuery stock = stockList[i];

                if (comp.size.toString() == stock.size.toString()) {
                  systemQty = stock.sap?.toDouble();
                  sitQty = stock.trans_qty?.toDouble();
                  var articleNo = stock.material_code.toString();
                  String extractedArticleNo =
                      articleNo.substring(articleNo.length - 12);
                  tableData.add({
                    'productCode': widget.title.toString(),
                    'articleNo': extractedArticleNo.toString(),
                    'size': stock.size.toString(),
                    'v_quantity': comp.sizeCount.toString(),
                    'd_quantity': comp.quantity.toString(),
                    'difference': diff.toString(),
                    'sap': systemQty.toString(),
                    'sit' : sitQty.toString(),
                    'message': message.toString(),
                  });
                }
              }
            }

            return FittedBox(
              child: DataTable(

                columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                headingRowHeight: 50,
                headingRowColor:
                MaterialStateColor.resolveWith((states) =>
                Colors.black45),
                columns: const [
                  DataColumn(label: Text('Product\nCode',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Required\nQuantity',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Actual\nQuantity',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Difference',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('SAP\nQTY',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('SIT\nQTY',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                  DataColumn(label: Text('Action\nRequired',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white)),),
                ],
                rows: tableData.map((data) {

                  return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }

                            return Colors.white.withOpacity(0.2);
                          }),

                      cells: [
                        DataCell(
                            Container(
                                child: Text(data['productCode'],textAlign:TextAlign.left,style: TextStyle(fontSize: 14))
                            )),
                        DataCell(
                            Container(

                                child: Text(data["articleNo"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14))
                            )
                        ),
                           DataCell(
                              Container(
                          child: Text(data["size"],
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14)))),
                      DataCell(
                            Container(

                                child: Text(data["v_quantity"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14))
                            )
                        ),
                        DataCell(
                            Container(

                              child: Text(data["d_quantity"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),
                            )),
                        DataCell(
                          Container(

                            child: Text(data["difference"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),
                          ),
                        ),

                        DataCell(
                            Container(

                              child:Text(data["sap"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),
                            )),
                            DataCell(
                            Container(

                            child:Text(data["sit"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),
                            )),
                        DataCell(
                          Container(

                            child:Text(data["message"],textAlign:TextAlign.left,style: TextStyle(fontSize: 14),),

                          ),
                        )
                      ]);
                }).toList(),
              )
          );
        },
      ),
          ),
    );
  }
  Future<List<dynamic>> fetchCombinedData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);

    final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.st.toString()}),
      headers: {
        "content-type": "application/json",
      },
    );
    var storeJson = json.decode(storeResponse.body);
    storecode = storeJson[0]['code'];
    print("storeCode.......$storecode");

    final stockResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
      body: json.encode({
        "storeCode": storecode.toString(),
        "code": widget.title.toString(),
      }),
      headers: {
        "content-type": "application/json",
      },
    );

final complianceResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_detected_size"),
      body: json.encode({
        "storeId": widget.st.toString(),
        "equipmentId": widget.dp.toString(),
        "product_code": widget.title.toString(),
      }),
      headers: {
        "content-type": "application/json",
      },
    );

    var stockJson = json.decode(stockResponse.body).cast<Map<String, dynamic>>();
    var complianceJson = json.decode(complianceResponse.body).cast<Map<String, dynamic>>();
    List<stockQuery> stockList = stockJson.map<stockQuery>((json) => stockQuery.fromJson(json)).toList();
    List<Comp> compList = complianceJson.map<Comp>((json) => Comp.fromJson(json)).toList();
    return [stockList, compList];
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
}

///Signage Compliance popup

class SignageScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const SignageScreen({Key? key, required this.title,required,required this.dp,required this.st}) : super(key: key);
// Step 2 <-- SEE HERE
final String title;
final String dp;
final String st;

@override
State<SignageScreen> createState() => _SignageScreenState();
}
class _SignageScreenState extends State<SignageScreen> {



  @override
  Widget build(BuildContext context) {
    return AlertDialog(


      title: const Text("Signage Compliance", style: TextStyle(fontSize: 16),),

      content:
      FutureBuilder<List<Comp>>(

        initialData: const <Comp>[],
        future:fetchComp(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...");
          }
          print(widget.title);



          return SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowHeight: 50,
                columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                headingRowColor:
                MaterialStateColor.resolveWith((states) =>
                Colors.black45),
                columns: const [
                  DataColumn(label: Text('Product\nCode', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
                  DataColumn(label: Text('Required\nSignage', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
                  DataColumn(label: Text('Action\nRequired', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),),
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
                              Container(

                                 child:  Text(widget.title, textAlign: TextAlign.left,
                                      style: const TextStyle(fontSize: 12))
                              )),
                          DataCell(
                              Container(


                                  child:  Text(data.vm_signage.toString(), textAlign: TextAlign.left,
                                      style: const TextStyle(fontSize: 12))
                              )
                          ),

                          DataCell(
                            Container(

                              child:  Text("Please Currect\nSignage to ${data.vm_signage}", textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 12),),
                            ),
                          )
                        ]);
                  },
                ).toList(),

              )

          );
        },
      ),

    );

  }
  Future<List<Comp>> fetchComp() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_all_popup_compliance/${widget.st}/${widget.dp}/${widget.title}");
    var response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<Comp> emplist = await resultsJson
        .map<Comp>((json) => Comp.fromJson(json))
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







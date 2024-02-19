import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/io_client.dart';
import '../model.dart';

class StockQueryCity extends StatefulWidget {
  const StockQueryCity({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<StockQueryCity> createState() => _StockQueryCityState();
}

class _StockQueryCityState extends State<StockQueryCity> {
  String _scanBarcode = '';
  String? fileContents;
  String? articleCode;
  String? barcodeValue;
  String? _imageData;
  int access = 0;
  String? storecode;
  String? storeCode;
  String?StoreCode;
  String equipmentName = "";
  String? generic_code;
  bool _isLoading = false;
  List<String> storeNames = [];
  List<String> storecodes = [];
  String? selectedStoreCode;
  String  message = 'Empty Data';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchStores().then((data) {
      setState(() {
        storeNames = data;
      });
    });
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchStores();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  final TextEditingController _articleCodeController = TextEditingController();

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        '',
        false,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _scanBarcode = barcodeScanRes;
      int lengthScanbarcode = _scanBarcode.length;
      if (lengthScanbarcode > 14) {
        barcodeValue = _scanBarcode.substring(3);
        fetchData(barcodeValue!);

      } else if (lengthScanbarcode == 14) {
        barcodeValue = _scanBarcode;
        fetchData(barcodeValue!);
      } else {
      }
    });
  }

  Future<void> fetchData(articleCode) async {
    List<stockQuery> results = await fetchResults(articleCode);
    await fetchEquipment(generic_code);

  }



  Future<List<String>> fetchStores() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_region_store_latest/${widget.username}'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      if (responseData.isNotEmpty) {
        final Map<String, dynamic> data = responseData[0]; // Assuming you want the first object
        final String codesString = data['codes'] as String;
        final List<String> storeNames = codesString.split(',').map((code) => code.trim()).toList();
        storeNames.sort();
        return storeNames;
      } else {
        throw Exception('Empty response data');
      }
    } else {
      throw Exception('Failed to load equipment names');
    }
  }






  Future<List<stockQuery>> fetchResults(articleCode) async {

    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
        body: json.encode({
          "storeCode": selectedStoreCode.toString(),
          "code": articleCode.toString(),
        }),
        headers: {"content-type": "application/json"},
      );
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("FAILED"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      var resultJson = json.decode(response.body).cast<Map<String, dynamic>>();

      // Check if the response is an empty list
      // if (resultJson.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text("Empty Data"),
      //       backgroundColor: Colors.red,
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      //   return []; // Return an empty list or handle it as per your requirements
      // }

      generic_code = resultJson[0]['genericCode'];
      List<stockQuery> emplist = await resultJson
          .map<stockQuery>((json) => stockQuery.fromJson(json))
          .toList();
      return emplist;
    } catch (e) {
      print(e);
      throw Exception('API request failed');
    }
  }


  Future<void> fetchEquipment(String? generic_code) async {

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_which_equipment/$generic_code");
    var response = await ioClient.get(url);
    var result = json.decode(response.body).cast<Map<String, dynamic>>();
    if (result.isNotEmpty) {
      String name = result[0]["code"];
      setState(() {
        _isLoading = false;
        equipmentName = name;
      });
    } else {
      setState(() {
        _isLoading = false;
        equipmentName = "No Guideline";
      });
    }
  }
  TextEditingController _typeAheadController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            appBar: AppBar(

              /// Store Code Dropdown box
              title:  Container(
                width: 300,
                height: 44,
                margin: const EdgeInsets.only(top: 2, left: 10, right: 0, bottom: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child:TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController, // Use the TextEditingController
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 7, bottom: 10.0, left: 20),
                      labelText: 'StoreCode',
                      labelStyle: TextStyle(fontSize: 15),
                      border: InputBorder.none,
                      fillColor: Colors.white,
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    // Implement your logic to filter suggestions based on the user's input
                    return storeNames.where((name) => name.toLowerCase().contains(pattern.toLowerCase())).toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedStoreCode = suggestion;
                      _typeAheadController.text = suggestion; // Set the selected value to the TextField
                    });
                  },
                )
              ),


              backgroundColor: Colors.white,
              elevation: 0.00,

              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  )),

              actions: [
                /// Article Code Text box
                Container(
                  width: 150,
                  height: 44,
                  margin: const EdgeInsets.only(top: 5, left: 0, right: 2, bottom: 5),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.black),
                      ),
                      labelText: 'Article Code',
                      isDense: true,
                      filled: false,
                    ),
                    controller:
                    _articleCodeController, // Assign the TextEditingController here
                  ),
                ),



                /// submit button
                Container(
                    height: 44,

                    margin: const EdgeInsets.only(
                        top: 5, left: 0, right: 0, bottom: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        // fetchEquipment(generic_code);
                        setState(() {
                          barcodeValue = _articleCodeController.text;
                          if (_articleCodeController.text.isNotEmpty &&
                              _articleCodeController.text != '') {
                            fetchData(barcodeValue);
                          }
                        });

                        FocusManager.instance.primaryFocus?.unfocus();
                        //_articleCodeController.text = '';
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(40, 52),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          // add some space between icon and label
                          Text('Submit', style: TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    )),


               /// scanner button
                Container(
                    height: 50,
                    width: 100,
                    margin: const EdgeInsets.only(
                        top: 5, left: 5, right: 0, bottom: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        scanBarcodeNormal();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(25, 42),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 17,
                          ),
                          SizedBox(width: 5),
                          // add some space between icon and label
                          Text(
                            'Scan\nEAN Code',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    )),



            /// equipment name show box
                Container(
                  width: 150,
                  height: 42,
                  margin: const EdgeInsets.only(
                      top: 5, left: 3, right: 0, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    // margin: const EdgeInsets.only(top: 0, left: 20, right: 0, bottom: 0),
                    child: equipmentName == "" || equipmentName == null
                        ? const Text("",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold))
                        : Text(
                      '$equipmentName\n',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                )
              ],








            ),
            body: Column(children: <Widget>[

              Container(
                child: SingleChildScrollView(
                  child: FittedBox(
                      child: DataTable(
                        headingRowHeight: 50,
                        headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.grey.shade200),
                        columns: const [
                          DataColumn(
                            label: Center(
                                child: Text('Style Code',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child:
                                Text('Article No\t\t\t\t\t\t\t\t\t\t\t\t\t\t',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('Prodh',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('Size',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('    Colour',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('SAP Qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('SIT Qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                          DataColumn(
                            label: Center(
                                child: Text('Nearby\nStore Qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ))),
                          ),
                        ],
                        rows: [],
                      )),
                ),
              ),
              Expanded(
                // height: 200,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(children: [
                    Container(
                      child: FutureBuilder<List<stockQuery>>(
                        initialData: const <stockQuery>[],
                        future: fetchResults(barcodeValue),
                        builder: (context, snapshot) {
                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return  Center(child: (Text("$message")));
                          }
                          List<Map<String, dynamic>> tableData = [];

                          if (snapshot.data != null) {
                            for (stockQuery stockquery in snapshot.data!) {
                              var articleNo = stockquery.material_code.toString();
                              String extractedArticleNo = articleNo.substring(articleNo.length - 12);

                              tableData.add({
                                'genericCode': stockquery.generic_code.toString(),
                                'articleNo': extractedArticleNo.toString(),
                                'prodh': stockquery.prodh.toString(),
                                'size': stockquery.size.toString(),
                                'colour': stockquery.colour.toString(),
                                'sap': stockquery.sap.toString(),
                                'sitQty': stockquery.trans_qty.toString(),
                                'nearbyStock': 'Click\nfor Detail',
                                'article': stockquery.material_code.toString(),
                              });
                            }
                          }

                          return FittedBox(
                            // fit: BoxFit.fitHeight,
                            child: DataTable(
                              dataRowHeight: 70,
                              headingRowHeight: 0,
                              headingRowColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.black45),
                              columns: const [
                                DataColumn(
                                  label: Center(
                                      child: Text('Style Code',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('Article No',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('Prodh',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('Size',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('Colour',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('SAP Qty',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('SIT Qty',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                                DataColumn(
                                  label: Center(
                                      child: Text('Nearby\nStore Qty',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ))),
                                ),
                              ],
                              rows: tableData.map(
                                    (data) {
                                  return DataRow(
                                      color: MaterialStateProperty.resolveWith<
                                          Color>((Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.08);
                                        }

                                        return Colors.white.withOpacity(0.2);
                                      }),
                                      cells: [
                                        DataCell(
                                          GestureDetector(
                                            child: Center(
                                              child: Text(
                                                data['genericCode'],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(
                                              data['articleNo'],
                                              textAlign: TextAlign.center,
                                              style:
                                              const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(
                                              data['prodh'],
                                              textAlign: TextAlign.center,
                                              style:
                                              const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(data['size'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                )),
                                          ),
                                          // width:40,
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(data['colour'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                )),
                                          ),
                                          // width:40,
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(data['sap'],
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                          ),
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(data['sitQty'],
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                          ),
                                          // width:40,
                                          onTap: () {},
                                        )),
                                        DataCell(GestureDetector(
                                          child: Center(
                                            child: Text(data['nearbyStock'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 21,
                                                    color: Colors.purple)),
                                          ),
                                          onTap: () {
                                            String materialCode =
                                            data['article'];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StockNearby(
                                                        M_code: materialCode,
                                                        stCode: selectedStoreCode.toString()),
                                              ),
                                            );
                                          },
                                        )),
                                      ]);
                                },
                              ).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Positioned.fill(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 6,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                              SizedBox(height: 16),
                              // add some spacing between the progress indicator and the label
                              Text(
                                'Detecting Image...',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              // add the label
                            ],
                          ),
                        ),
                      ),
                  ]),
                ),
              )
            ]));
  }
}

Future<SecurityContext> get globalContext async {
  final sslCert1 = await rootBundle.load('assets/starttrent.pem');
  SecurityContext sc = SecurityContext(withTrustedRoots: false);
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  return sc;
}

/// NEAR BY STOCK SCREEN

class StockNearby extends StatefulWidget {
  const StockNearby({Key? key, required this.M_code, required this.stCode})
      : super(key: key);
  final String M_code;
  final String stCode;

  @override
  State<StockNearby> createState() => _StockNearbyState();
}

class _StockNearbyState extends State<StockNearby> {
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
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  List<Map<String, String>> addressesAndCities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stock Query', style: TextStyle(fontSize: 16)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          backgroundColor: Colors.black87,
          elevation: 0.00,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(children: [
            FutureBuilder<Map<String, dynamic>>(
              initialData: {},
              future: fetchnearby(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ));
                }

                List<Map<String, String>> addressesAndCities = snapshot
                    .data!['addressesAndCities'];
                List<stockQuery> stockQueryList = snapshot
                    .data!['stockQueryList'];

                List<Map<String, dynamic>> tableData = [];
                for (stockQuery stock in stockQueryList) {
                  var correspondingData = addressesAndCities.firstWhere(
                        (data) => data['storeCode'] == stock.storeCode,
                    orElse: () => {'address': 'N/A', 'city': 'N/A'},
                  );
                  tableData.add({
                    "StoreCode": stock.storeCode,
                    "sap": stock.sap,
                    "storeName": correspondingData['address'],
                    "city": correspondingData['city'],
                  });
                }

                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DataTable(
                    dataRowHeight: 50,
                    headingRowHeight: 50,
                    headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.black45,
                    ),
                    columns: const [
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Store Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Available Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            '            Store',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            '            City',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: tableData.map((data) {
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme
                                  .of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08);
                            }
                            return Colors.white.withOpacity(0.2);
                          },
                        ),
                        cells: [
                          DataCell(
                            GestureDetector(
                              child: Center(
                                child: Text(
                                  data['StoreCode'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              child: Center(
                                child: Text(
                                  data['sap'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              child: Center(
                                child: Text(
                                  data['storeName'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              child: Center(
                                child: Text(
                                  data['city'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),

          ]),
        ),

    );
  }

  Future<Map<String, dynamic>> fetchnearby() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
        body: json.encode({
          "storeCode": widget.stCode.toString(),
          "code": widget.M_code.toString()
        }),
        headers: {
          "content-type": "application/json",
        });

    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);

    List<stockQuery> emplist = await resultsJson
        .map<stockQuery>((json) => stockQuery.fromJson(json))
        .toList();

    for (var item in resultsJson) {
      if (item.containsKey('storeCode')) {
        var storeCode = item['storeCode'];
        try {
          final response = await ioClient.get(
            Uri.parse("https://smh-app.trent-tata.com/flask/get_store_address_and_city/$storeCode"),
          ).timeout(Duration(seconds: 10));

          var addressCityList = json.decode(response.body);

          if (addressCityList is List && addressCityList.isNotEmpty) {
            var addressCity = addressCityList[0];

            addressesAndCities.add({
              'storeCode': storeCode,
              'address': addressCity['address'],
              'city': addressCity['city'],
            });
          }
        } catch (e) {
          // Handle any exceptions that might occur during the API call
          print("Error fetching data for storeCode $storeCode: $e");
        }
      } else {
        print("Error: 'storeCode' key not found in the item: $item");
      }
    }

    print("here the arrayyyy.....$addressesAndCities");

    return {
      'addressesAndCities': addressesAndCities,
      'stockQueryList': emplist
    };
  }
}


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Detection/DetectedImageGrid.dart';
import '../model.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:loading_alert_dialog/loading_alert_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class BarCodeSize extends StatefulWidget {
  const BarCodeSize({Key? key, required this. eqpt, required this.stid, required this. image,this. equipName, this.position, required this. takenImages, required this.imageWidget,
    this. equipType, this. equipCode, this. fileName, this. SnpShot, required this.displayProductImage, required this.displayColour, required this. displayProductCode,}) : super(key: key);
  final String eqpt;
  final String stid;
  final ImageProvider image;
  final String? equipName;
  final String? equipCode;
  final String? fileName;
  final String? SnpShot;
  final String? equipType;
  final int? position;
  final  List<List<int>> takenImages;
  final List<Image> imageWidget;
  final ImageProvider<Object> displayProductImage;
  final String displayColour;
  final String displayProductCode;



  @override
  State<BarCodeSize> createState() => _BarCodeSizeState();
}

class _BarCodeSizeState extends State<BarCodeSize> {

  String _scanBarcode = '';
  String? fileContents;
  String? mMaterialCode;
  String? barcodeValue;
  String? gGenericCode;
  String? sSize;
  double? sSap;
  String? selectedQuantity;
  final _formKey = GlobalKey<FormState>();
  FToast? fToast;
  @override
  void initState() {
    fToast = FToast();
    fToast?.init(context);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  bool _isLoading = false;
  List<String> size = [];
  List<String> articleCodes = [];
  List<String> SelectQuantity = [];
  List<String> MaterialCode = [];
  List<String> selectedQuantities = [];




  final TextEditingController _productCountController = TextEditingController();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE,

      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
      int lengthScanbarcode = _scanBarcode.length;
      if (lengthScanbarcode > 14) {
        barcodeValue = _scanBarcode.substring(3);
        fetchResults(barcodeValue!);

      }
      else if (lengthScanbarcode == 14){
        barcodeValue = _scanBarcode;
        fetchResults(barcodeValue!);

      }
    });
  }
  String? _imageData;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.grey
      ),
      home: Scaffold(

        appBar: AppBar(title: const Text('Barcode Scanner',
            style: TextStyle(fontSize: 16, color: Colors.white)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
          backgroundColor: Colors.black,
          elevation: 0.00,
        ),

        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// BARCODE SCANNER
              Container(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 20, right: 30, top: 10),
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
                      minimumSize: Size(35, 52),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 25,
                        ),
                        SizedBox(width: 8),
                        // add some space between icon and label
                        Text('Scan Barcode', style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  )),



              /// Quantity dropdown BOX
              Container(
                padding: const EdgeInsets.only(left: 30, bottom: 20, right: 30, top: 10
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:DropdownButtonFormField<String>(
                            value: selectedQuantity,
                            hint: const Text('Select Quantity'),
                            items: List<DropdownMenuItem<String>>.generate(20, (index) {
                              final number = (index + 1).toString();
                              return DropdownMenuItem<String>(
                                value: number,
                                child: Text(
                                  number,
                                  style: TextStyle(fontSize: 17),
                                ),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                selectedQuantity = value; // Update selected quantity when dropdown value changes
                              });
                            },
                          ),
                        ),
                    /// Plus Button
                            SizedBox(width: 7), // add some space between the TextField and the button
                            ElevatedButton(
                            onPressed: () {

                            setState(() {
                                if (selectedQuantity != null) {
                                    setState(() {
                                       selectedQuantities.add(selectedQuantity!); // Add selected quantity to the array
                                       selectedQuantity = null; // Reset selected quantity to null
                                     });
                                   }

                            });
                            for (var quantity in selectedQuantities) {
                              print("qua..$quantity");
                            }
                            },
                            style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: Size(20, 52),
                            ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, size: 25,),
                                  SizedBox(width: 1),
                                ],
                              ),
                            )
                           ],
                          ),
                         ]
                        ),
                    ),


              /// SUBMIT AFTER BARSCANNING OR INPUT ARTICLE CODE TEXT BOX
              Container(
                  padding: const EdgeInsets.only(left: 30, bottom: 4, right: 30, top: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      final preferences = await SharedPreferences.getInstance();
                      await preferences.setBool('showSubmitButton', true);


                      updateSizeRatios();

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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save,
                          size: 25,
                        ),
                        SizedBox(width: 2),
                        // add some space between icon and label
                        Text('Submit', style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )),
              Stack(
                  children: [
                    if (_isLoading)
                      const Positioned.fill(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 6,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                              // SizedBox(height: 16), // add some spacing between the progress indicator and the label
                              // Text('',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),), // add the label
                            ],
                          ),
                        ),
                      ),

                    /// SHOWING RESULT INTO THE SCREEN
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // color: Colors.grey,
                            width: 200,
                            height: 300,
                            child: ListView.builder(
                              itemCount: articleCodes.length,
                              itemBuilder: (BuildContext context, int index) {
                                final articleCode = articleCodes[index];
                                final articleSize = size[index];

                                return Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                  child: Text('Code: $articleCode\t   Size: $articleSize',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            // color: Colors.grey,
                            width: 100,
                            height: 300,
                            padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 0),
                            child: ListView.builder(
                              itemCount: selectedQuantities.length,
                              itemBuilder: (BuildContext context, int index) {
                                final selectQuantity = selectedQuantities[index];
                                return Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                  child: Text('Quantity: $selectQuantity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    var res = articleCodes.removeLast();
                    var res1 = size.removeLast();
                    var res2 = selectedQuantities.removeLast();
                    print(res);
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.clear,color: Colors.black),
                    Text('Clear', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> fetchResults(code) async {
    setState(() {
      _isLoading = true;
    });
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final responseStore = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.stid.toString()}),
      headers: {"content-type": "application/json"},
    );
    var resultsJson = json.decode(responseStore.body);
    String storeCode = resultsJson[0]['code'];
    print("storeCode.......$storeCode");
    if(responseStore.statusCode != 200)
    {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{

    }
    final response = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv_barcode_lookup"),
      body: json.encode({"storeCode": storeCode.toString(), "code": code.toString(),}),
      headers: {"content-type": "application/json"},
    );
    if (response.statusCode != 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("FAILED"),
      //     backgroundColor: Colors.red,
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      setState(() {
        _isLoading = false;
      });
    }
    else{
      setState(() {
        _isLoading = false;
      });
    }
    var resultJson = json.decode(response.body);
    String genericCode = resultJson[0]['genericCode'];
    String materialCode = resultJson[0]['materialCode'];
    String Size = resultJson[0]['size'];


    setState(() {
      articleCodes.add(genericCode);
      gGenericCode = genericCode;
      String extractedArticleNo = materialCode.substring(materialCode.length - 12);
      mMaterialCode = extractedArticleNo;
      size.add(Size);
      MaterialCode.add(materialCode);
    });
  }

  Future<void> updateSizeRatios() async {

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_maximum_id/${widget.stid}/${widget.eqpt}");
    var Idresponse = await ioClient.get(url);
    var IdresultJson = json.decode(Idresponse.body);
    final id = IdresultJson[0]['id'];
    url = Uri.parse("https://smh-app.trent-tata.com/flask/get_sizefrom_detected/$id/$gGenericCode");
    var detectedSizeresponse = await ioClient.get(url);
    var detectedSizeJson = json.decode(detectedSizeresponse.body);
    print("detected size json.........................$detectedSizeJson");
    bool sizeExists = false;
    if (size.length == selectedQuantities.length) {
      for (int i = 0; i < size.length; i++) {
        String currentSize = size[i];
        String currentQuantity = selectedQuantities[i];

        bool sizeExists = false;
        for (var item in detectedSizeJson) {
          if (item['size'] == currentSize) {
            item['quantity'] = currentQuantity;
            sizeExists = true;
            break;
          }
        }

        // If currentSize does not exist, add it to detectedSizeJson
        if (!sizeExists) {
          detectedSizeJson.add({
            'size': currentSize,
            'quantity': currentQuantity,
          });
        }
      }
    } else {
      // Handle the case when the size and selectedQuantity arrays have different lengths
    }
    print("Updated.........detected size json.........................$detectedSizeJson");
    final body = {
      'product_code': gGenericCode,
      'detected_values_table_id': id.toString(),
      'size_ratios': detectedSizeJson,
    };

    try {
      final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/update_size_ratios"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Size ratios updated successfully');
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              image:widget.image ,
              eqid: widget.eqpt.toString(),stid:widget.stid.toString(), equipName:widget.equipName,
              position: widget.position,
              imageWidget: widget.imageWidget, takenImages: widget.takenImages,equipCode: widget.equipCode,
              equipType: widget.equipType,fileName: widget.fileName,snpShot: widget.SnpShot,
              displayProductImage: widget.displayProductImage,
              displayColour: widget.displayColour,
              displayProductCode: widget.displayProductCode,

            ),
          ),
        );
      } else {
        print('Failed to update size ratios. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }


  _showToast() {
    Widget toast = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("DETECTION FAILED",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        ],
      ),
    );
    fToast?.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    // Custom Toast Position

  }

}
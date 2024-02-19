import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart';
import 'package:sample/Detection/DetectedImageGrid.dart';
import '../Detection/DetectedImage.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';



class BarCodeScannerCompliance extends StatefulWidget {
  const BarCodeScannerCompliance({Key? key, required this. eqpt, required this.stid, required this.takenImages, required this. equipType, required this. fileName, required this. equipCode,
    required this.equipName,  this. Snpshot, required this.imageWidget}) : super(key: key);
  final String eqpt;
  final String stid;
  final String equipType;
  final List<List<int>> takenImages;
  final List<Image> imageWidget;
  final String? Snpshot;
  final String? fileName;
  final String? equipCode;
  final String? equipName;



  @override
  State<BarCodeScannerCompliance> createState() => _BarCodeScannerComplianceState();
}

class _BarCodeScannerComplianceState extends State<BarCodeScannerCompliance> {

  String _scanBarcode = '';
  String? fileContents;
  String? articleCode;
  String? barcodeValue;
  String? genericCode;
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
  int _randomNumber = 0;
  bool _isLoading = false;
  List<String> barcodeList = [];
  List<String> articleCodes = [];
  final TextEditingController _articleCodeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

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
          // executejava(barcodeValue!);
          barcodeList.add(barcodeValue!);
      }
      else if (lengthScanbarcode == 14){
        barcodeValue = _scanBarcode;
        // executejava(barcodeValue!);
        fetchResults(barcodeValue!);
        barcodeList.add(barcodeValue!);
      }
    });
  }
  String? _imageData;
  int access = 0;

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 25,
                        ),
                        SizedBox(width: 8),
                        // add some space between icon and label
                        Text(
                          'Scan EAN Code',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  )),

              Container(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 20, right: 30, top: 10),
                  child: const Column(
                      children: [
                        Center(child: Text('OR', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)))
                      ]
                  )

              ),
              /// ARTICLE CODE TEXT BOX
              Container(
                padding: const EdgeInsets.only(left: 30, bottom: 20, right: 30, top: 10
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                ),
                              ),
                              labelText: 'Article Code',
                              isDense: true,
                            ),
                            controller: _articleCodeController, // Assign the TextEditingController here
                          ),
                        ),
                        SizedBox(width: 7), // add some space between the TextField and the button
                       ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            articleCode = _articleCodeController.text;
                            int lengtharticleCode = articleCode.toString().length;
                            setState(() {
                              if( lengtharticleCode == 9 )
                              {
                                articleCodes.add(articleCode.toString());
                              }
                              else if(lengtharticleCode == 14)
                              {
                                barcodeList.add(articleCode!);
                                // executejava(articleCode!);
                                fetchResults(articleCode!);
                              }
                            });
                            _articleCodeController.text = '';
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
                  ],
                ),
              ),
              /// Position TEXT BOX
              Container(
                padding: const EdgeInsets.only(left: 30, bottom: 20, right: 30, top: 10
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                ),
                              ),
                              labelText: 'Position',
                              isDense: true,
                            ),
                            controller: _positionController, // Assign the TextEditingController here
                          ),
                        ),
                        // SizedBox(width: 7), // add some space between the TextField and the button

                      ],
                    ),
                  ],
                ),
              ),

            /// SUBMIT AFTER BARSCANNING OR INPUT ARTICLE CODE TEXT BOX
              Container(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 20, right: 30, top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      articleCodes.map((code) {
                        genericCode = articleCodes.join('-');
                      }).toList();
                      if(genericCode != null){
                        sendImagesToDetection(genericCode,_positionController.text);
                        // _showAlert();
                        //  _showAlert(); // start showing the loading dialog
                      }
                      else{
                        _showToast();

                      }
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
                        Text(
                          'Submit',
                          style: TextStyle(fontSize: 14),
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
                     Container(
                      width: 300,
                      height: 300,
                      padding: const EdgeInsets.only(left:30, bottom: 20, right: 30, top:5),
                       child: ListView.builder(
                            itemCount: articleCodes.length,
                            itemBuilder: (BuildContext context, int index) {
                          return Center(
                           child: Text(
                               '${articleCodes[index]}\n',
                               style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)
                          )
                    );
                  },
                ),
              ),
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
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{

    }
    final response = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
      body: json.encode({"storeCode": storeCode.toString(), "code": code.toString(),}),
      headers: {"content-type": "application/json"},
    );
    if (response.statusCode != 200) {
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
    String articleCode = resultJson[0]['genericCode'];
    print(articleCode);
    setState(() {
      articleCodes.add(articleCode);
      // sendImagesToDetection();
    });
  }

  Future<void> sendImagesToDetection(genericCode,position) async {
    setState(() {
      _isLoading = true;
    });
    print("generic..code....$genericCode");
    print("position.....$position");
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final url = Uri.parse(
        'https://smh-app.trent-tata.com/flask/getVMGuidelineDetailsAndDetectedValuesFromProductCode');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    // Add each image as a file field
    for (var i = 0; i < widget.takenImages.length; i++) {
      final fileName = '$index.jpg';
      request.fields['storeId'] = widget.stid.toString();
      request.fields['equipmentId'] = widget.eqpt.toString();
      request.fields['productCodes'] = genericCode.toString();
      request.fields['productPosition'] = position.toString();
      request.files.add(http.MultipartFile.fromBytes(
        'files[]', // Use a name that matches the server's expectations
        widget.takenImages[i],
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if (response.statusCode != 200) {
      setState(() {
        _isLoading = false;
      });
      _showToast();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else {
      setState(() {
        _isLoading = false;
      });
    }
    if(widget.equipType == 'Wall')
      {
        final imageData = await response.stream.toBytes();
          final archive = ZipDecoder().decodeBytes(imageData);
          final compressedImages = <Uint8List>[];
          for (var file in archive.files) {
            if (file.isFile) {
              final compressedImage = await FlutterImageCompress.compressWithList(
                file.content,
                quality: 100,
                rotate: 90,
              );
              compressedImages.add(compressedImage!);
            }
          }
          final imageWidgets = compressedImages
              .map((compressedImage) => Image.memory(compressedImage))
              .toList();
          Navigator.of(context).pop();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetectedImage(imagewidget: imageWidgets,
            equipmentId: widget.eqpt.toString(),
            storeId: widget.stid.toString(),
            takenImages: widget.takenImages,
            equipType: widget.equipType,
            equipCode: widget.equipCode,
            equipName: widget.equipName,
            Snpshot: widget.Snpshot,
            filename: widget.fileName,
          ),
          ),
          );
      }
    else if (widget.equipType == 'Table')
      {
        final imageData = await response.stream.toBytes();
        final archive = ZipDecoder().decodeBytes(imageData);

// Sort the files in the archive based on their names numerically
        final sortedFiles = archive.files.toList()
          ..sort((a, b) {
            final aNumeric = int.tryParse(a.name.replaceAll(RegExp('[^0-9]'), ''));
            final bNumeric = int.tryParse(b.name.replaceAll(RegExp('[^0-9]'), ''));
            if (aNumeric != null && bNumeric != null) {
              return aNumeric.compareTo(bNumeric);
            } else if (aNumeric != null) {
              return -1; // Place filenames with numeric values before non-numeric filenames
            } else if (bNumeric != null) {
              return 1; // Place filenames with numeric values after non-numeric filenames
            } else {
              return a.name.compareTo(b.name);
            }
          });

        final compressedImages = <Uint8List>[];
        final imageFilenames = <String>[]; // List to store the filenames

        for (var file in sortedFiles) {
          if (file.isFile) {
            final compressedImage = await FlutterImageCompress.compressWithList(
              file.content,
              quality: 100,
              // rotate: 90,
            );
            compressedImages.add(compressedImage!);
            imageFilenames.add(file.name); // Add filename to the list
          }
        }

        final imageWidgets = compressedImages
            .map((compressedImage) => Image.memory(compressedImage))
            .toList();
        print('Extracted Image Filenames (Numeric Sorted Order): $imageFilenames'); // Print the filenames
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetectedImage2(
                  imageWidgets: imageWidgets,
                  equipmentId: widget.eqpt,
                  storeId: widget.stid.toString(),
                  takenImages: widget.takenImages,
                  equipType: widget.equipType,
                  filename: widget.fileName,
                  equipCode: widget.equipCode,
                  equipName: widget.equipName,
                  Snpshot: widget.Snpshot,
                ),
          ),
        );
      }

    else
    {
      final imageData = await response.stream.toBytes();
      final archive = ZipDecoder().decodeBytes(imageData);
      final imageWidgets = archive.files
          .where((file) => file.isFile)
          .toList();
      imageWidgets.sort((a, b) => a.name.compareTo(b.name)); // Sort by file name
      final sortedImageWidgets = imageWidgets
          .map((file) => Image.memory(file.content))
          .toList();
      // Do something with the response data, e.g. display it in a new screen
      Navigator.of(context).pop();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,
        equipmentId: widget.eqpt.toString(),
        storeId: widget.stid.toString(),
        takenImages: widget.takenImages,
        equipType: widget.equipType,
        equipName: widget.equipName,
        equipCode: widget.equipCode,
        Snpshot: widget.Snpshot,
        filename: widget.fileName,
      ),
      ),
      );
    }
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  // void _showAlert() {
  //   LoadingAlertDialog.showLoadingAlertDialog<int>(
  //     context: context,
  //     builder: (context,) => Card(
  //       color: Colors.black12,
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child:Center(
  //           child:
  //           Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: const <Widget>[
  //               CircularProgressIndicator(strokeWidth: 6,
  //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
  //               SizedBox(height: 16), // add some spacing between the progress indicator and the label
  //               Text('Detecting...',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
  //             ],
  //           ),
  //         )
  //
  //       ),
  //     ),
  //     computation: Future<int>.delayed(
  //       const Duration(seconds: 1), () {
  //       final randomNumber = Random().nextInt(100);
  //       return randomNumber;
  //     },
  //      ) ,// Set to null to stop the computation
  //    );
  // }
  _showToast() {
    Widget toast = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.red,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
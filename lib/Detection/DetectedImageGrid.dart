import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import 'package:sample/Barcode/BarCodeSize.dart';
import 'package:sample/CompliancePopUpImage.dart';
import 'package:sample/TablesResultScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../StoreManager/AlternateProductCompliance.dart';
import '../Barcode/BarCodeScannerCompliance.dart';
import '../Camera/StackClosupCamera.dart';
import 'package:sample/Camera/VMCameraHome.dart' as vmcamerahome;
import '../main.dart';
import '../temporary.dart';
import 'FirstDetailedReport.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model.dart';

class DetectedImage2 extends StatefulWidget {
  final List<Image> imageWidgets;
  const DetectedImage2({Key? key, required this.imageWidgets, this.equipmentId, this.storeId, required this. takenImages, this. equipType,this.filename ,this.equipCode, this.equipName, this. Snpshot,}) : super(key: key);
  final String? equipmentId;
  final String? storeId;
  final String? equipType;
  final String? equipCode;
  final String? equipName;
  final String?  Snpshot;
  final String? filename;

  final List<List<int>> takenImages;
  @override
  _DetectedImage2State createState() => _DetectedImage2State();
}

class _DetectedImage2State extends State<DetectedImage2> {

  CameraDescription? selectedCamera;
  int _selectedIndex = 0;
  bool _isVisible = true;
  int? position ;
  int? status;
  int detectionPercent = 0;
  bool _isLoading = false;
  int? vmTableId;
  int? sendingPosition;
  int gotoCapture = 0;
  String? dialogue;
  String? fullImageData;
  String? complianceColor;
  String? compliancePosition;
  String? complianceQuantity;
  String? complianceSizeRatio;
  String? complianceProduct;
  String detectionTime = "0.00.00";
  List<Compliance>? _apiData;
  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchResults().then((data) {
      setState(() {
        _apiData = data;
      });
    });
    fetchDetectionPercentage ();
    fetchDetectionTimeTaken();
    checkGuidelineData ();
    getFullImageData ();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

  }
  @override
  void dispose() {
    if(gotoCapture == 0) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    else{
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 250,
              child: Text(
                "${widget.equipName.toString()}  - Compliance Score - $detectionPercent%",
                style: TextStyle(fontSize: 14, color: _getScoreColor(detectionPercent)),
              ),
            ),
            SizedBox(
              width: 90,
              child: Align(
                child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                   // color: Colors.green,
                    image: DecorationImage(
                      image: widget.imageWidgets[0].image,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),

       // automaticallyImplyLeading: false,
        leading: Row(
         children: [
           IconButton(
             onPressed: () {
               Navigator.of(context).pop();
             },
             icon: const Icon(Icons.arrow_back_ios),
           ),
         ],
        ),

        actions: [
          Visibility(
            visible: kDebugMode,
            child: IconButton(
              onPressed: () async {
                // alice.showInspector();
              },
              icon: const Icon(Icons.show_chart_outlined),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.only(top:10),
          //   width: 180,
          //   child: Text(
          //     "Detection Time - $detectionTime",
          //     style: const TextStyle(fontSize: 14, color: Colors.white),
          //   ),
          // ),
          Container(
            width: 50,
            height: 50,
            child: IconButton(
              icon: const Icon(Icons.menu,color: Colors.white,), // Replace with your desired icon
              onPressed: () => SideSheet.right(
                context: context,
                width: MediaQuery.of(context).size.width * 0.15,
                body: Container(
                    color: Colors.white, // Set the background color
                    width: double.infinity, // Set the width to expand to the screen width
                    padding: const EdgeInsets.only(top:20,bottom:20), // Add padding
                    child: Column(
                      children: [
                        ///,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,detail report.......................
                        ///........................


                        Container(
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Creates a circular button
                            color: Colors.black, // Background color of the button
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.article_outlined,
                              color: Colors.white,
                              size: 20,// Icon color
                            ),
                            onPressed: () {

                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => tablesResult(
                              //       takenImages:widget.takenImages,
                              //       equipType: widget.equipType,
                              //       eqId: widget.equipmentId,
                              //       stId: widget.storeId,
                              //
                              //
                              //     ),
                              //   ),
                              // );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return FirstDetailedReport(
                                      orientation: "landscape",
                                      eqpt: widget.equipmentId,
                                      stid: widget.storeId,
                                      equipType: widget.equipType,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 2,),
                        const Text('Detail Report', style:  TextStyle(fontSize: 9,fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2,),

                        /// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, recapture...............
                        /// ..................


                        Container(
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Creates a circular button
                            color: Colors.black, // Background color of the button
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded,color: Colors.white,size: 20,),
                            onPressed: () {
                              setState(() {
                                gotoCapture = 1;
                              });
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => vmcamerahome.VMCaptureImage(
                                    filename: widget.filename.toString(),
                                    eqptId: widget.equipmentId.toString(),
                                    eqptCode: widget.equipCode.toString(),
                                    eqptName: widget.equipName.toString(),
                                    eqptNoOfSnaps: widget.Snpshot.toString(),
                                    stid:widget.storeId.toString(),
                                    eqptType: widget.equipType.toString(),
                                    // storeId:widget.storeId.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 2,),
                        const Text('Recapture', style:  TextStyle(fontSize: 9,fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2,),

                        ///...................................print actionlist.....................
                        ///................................
                        ///
                        Container(
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Creates a circular button
                            color: Colors.black, // Background color of the button
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.picture_as_pdf_sharp,color: Colors.white,size: 20,),
                            onPressed: () {
                              printActionList();
                            },
                          ),),
                        const SizedBox(height: 2,),
                        const Text('Print Action List', style:  TextStyle(fontSize: 9,fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2,),

                        ///,,,,,,,,,,,,,,,,   Vmguideline.......
                        ///.....................


                        Container(
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Creates a circular button
                            color: Colors.black, // Background color of the button
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.summarize,color: Colors.white,size: 20,),
                            onPressed: () {
                              downloadAndShowVMGuideline(vmTableId,widget.equipmentId);
                            },
                          ),),
                        const SizedBox(height: 2,),
                        const Text('VM Guideline', style:  TextStyle(fontSize: 9,fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2,),

                        ///.................................Full Image Button.............
                        ///..........................................................

                        Container(
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Creates a circular button
                            color: Colors.black, // Background color of the button
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.image,color: Colors.white,size: 20,),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return CompliancePopUpImage(imageData: fullImageData.toString(), eqid: widget.equipmentId.toString(),

                                    );
                                  },
                                ),
                              );
                            },
                          ),),
                        const SizedBox(height: 0,),
                        const Text('Full Image', style:  TextStyle(fontSize: 9,fontWeight: FontWeight.bold)),
                        const SizedBox(height: 0,),
                      ],
                    )

                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0.00,
        toolbarHeight: 40,
      ),
      body:  Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child:
              SizedBox(
                width: MediaQuery.of(context).size.width ,
                height: MediaQuery.of(context).size.height ,
                //color: Colors.orange,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.only(left: 140,right: 140,top: 10,bottom: 5),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: widget.equipName.toString() == 'BT1-FRONT' ||  widget.equipName.toString() == 'GT1-FRONT' ||
                      widget.equipName.toString() == 'BT2-FRONT' || widget.equipName.toString() == 'GT2-FRONT'? 6:5,
                  children: widget.imageWidgets.sublist(1).asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final position = entry.key;
                    final imageWidget = entry.value;
                    final image = entry.value;
                    return FutureBuilder(
                      future: Future.value(_apiData),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("");
                        } else if (snapshot.hasError) {
                          return const Text("Error");
                        } else {
                          // Use _apiData directly instead of calling fetchResults again
                          final apiData = snapshot.data as List<Compliance>?;
                          if (apiData == null || apiData.isEmpty) {
                            return const Text("No data available");
                          }

                          return GestureDetector(
                            onTap: () async {
                              if (await Vibration.hasVibrator() ?? false) {
                                Vibration.vibrate(duration: 50);
                              }
                              fetchTickOrCross(position, image.image,apiData?[position].product,apiData?[position].position,
                                  apiData?[position].color,apiData?[position].detectedQuantity,apiData?[position].sizeratio,apiData?[position].status);
                              print("Tapped on image: $position");
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: image.image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    height: 17,
                                    width: 20,
                                    padding: const EdgeInsets.all(3),
                                    color: Colors.black.withOpacity(0),
                                    child: Text(
                                      '$index',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    padding: const EdgeInsets.only(left: 10),
                                    color: Colors.black.withOpacity(0.0),
                                    child: Icon(
                                      apiData[position].status == 1
                                          ? Icons.check
                                          : (apiData[position].status == 5
                                          ? Icons.circle_outlined
                                          : Icons.close),
                                      size: 60,
                                      color: apiData[position].status == 1
                                          ? Colors.green
                                          : (apiData[position].status == 5
                                          ? Colors.white  // Replace with the desired color for status 5
                                          : Colors.red),
                                    ),

                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  left: 0,
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    padding:const EdgeInsets.only(left: 5, top: 10),
                                    color: Colors.black.withOpacity(0),
                                    child: Text(
                                          'Prod: ${apiData?[position].product.toString() == '1'? 'Yes' : 'No'}\n'
                                          'Posi: ${apiData?[position].position.toString() == '1'? 'Yes' : 'No'}\n'
                                          'Col: ${apiData?[position].color.toString() == '1'? 'Yes' : 'No'}\n'
                                          'Qty: ${apiData?[position].detectedQuantity} \n'
                                          'Size Rt: ${apiData?[position].sizeratio.toString() == '1'? 'Yes' : 'No'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
      ),





      // bottomNavigationBar: BottomNavigationBar(
      //   showUnselectedLabels: true,
      //   backgroundColor: Colors.black87,
      //   unselectedItemColor: Colors.white,
      //   selectedItemColor: Colors.yellowAccent,
      //   selectedLabelStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 10),
      //   unselectedLabelStyle: const TextStyle(color: Colors.white, fontSize: 10),
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.black87,
      //       icon: Icon(Icons.article_outlined),
      //       label: 'Detail Report',
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.black87,
      //       icon: Icon(Icons.camera_alt_rounded),
      //       label: 'Recapture',
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.black87,
      //       icon: Icon(Icons.picture_as_pdf_sharp),
      //       label: 'Print Action List',
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.black87,
      //       icon: Icon(Icons.summarize),
      //       label: 'VM Guideline',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }


  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //
  //   switch (index) {
  //     case 0:
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (BuildContext context) {
  //             return FirstDetailedReport(eqpt: widget.equipmentId, stid: widget.storeId,equipType:widget.equipType );
  //           },
  //         ),
  //       );
  //       // code to execute when Report item is pressed
  //       break;
  //     case 1:
  //       Navigator.of(context).pop();
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => vmcamerahome.VMCaptureImage(
  //             filename: widget.filename.toString(),
  //             eqptId: widget.equipmentId.toString(),
  //             eqptCode: widget.equipCode.toString(),
  //             eqptName: widget.equipName.toString(),
  //             eqptNoOfSnaps: widget.Snpshot.toString(),
  //             stid:widget.storeId.toString(),
  //             eqptType: widget.equipType.toString(),
  //             // storeId:widget.storeId.toString(),
  //           ),
  //         ),
  //       );
  //
  //       break;
  //     case 2:
  //       printActionList();
  //       break;
  //
  //     case 3:
  //       downloadAndShowVMGuideline(vmTableId,widget.equipmentId);
  //       break;
  //   }
  // }


  Future<List<Compliance>> fetchResults() async {

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_compliance_for_text/${widget.storeId}/${widget.equipmentId}");
    var response = await ioClient.get(url);
    var resultsJsonfirst = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Compliance> emplist = await resultsJsonfirst
        .map<Compliance>((json) => Compliance.fromJson(json))
        .toList();
    return emplist;

  }

  Future<void> checkGuidelineData () async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;

    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/check_guideline_data/${widget.equipmentId}'));

    var guidelineData = json.decode(response.body);
    int? id = guidelineData[0]['id'];

    setState(() {
      vmTableId = id;
    });
  }

  /// display full detected image ///
  Future<void> getFullImageData () async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;

    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_image_data_from_detected_values/${widget.storeId}/${widget.equipmentId}'));

    var result = json.decode(response.body);
    String imageData = result[0]['returned_image_file'];

    setState(() {
      fullImageData = imageData;
    });
  }


  /// Goto VM Guideline
  Future <void> downloadAndShowVMGuideline(VMId,EqptId) async {
    print(VMId);
    print(EqptId);
    try {
      print("Calling...VM...");
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_vm_guideline_pdf_preview"),
          body: json.encode({"table_id":VMId,"equipment_id":EqptId}),
          headers: {
            "content-type": "application/json",
            "accept": "application/pdf",
          });
      print(response.statusCode);

      if (response.statusCode == 200) {
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        Directory('${appDocDirectory.path}/dir')
            .create(recursive: true)
            .then((Directory directory) async {
          final file = File("${directory.path}/vm_guideline.pdf");
          await file.writeAsBytes(response.bodyBytes);

          // await Printing.layoutPdf(onLayout: (_) => response.bodyBytes);
          // ignore: use_build_context_synchronously
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VMShowPDF(pdfPath: "${directory.path}/vm_guideline.pdf",sheet: VMId.toString(),tiger: EqptId)));
          print("${directory.path}/vm_guideline.pdf");
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }






  Future<void> fetchTickOrCross (int? position, ImageProvider<Object> image, int? complianceProduct, int? compliancePosition, int? complianceColor, int? complianceQuantity, int? complianceSizeratio, int? complianceStatus, )async{
    try {
        final Pposition = position! + 1;
        print("productImagePosition...$position");
        HttpClient client = HttpClient(context: await globalContext);
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
        IOClient ioClient = IOClient(client);
        Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_tick_or_cross/${widget.storeId}/${widget.equipmentId}/$Pposition");
        var response = await ioClient.get(url);
        var resultJson = json.decode(response.body);
        final statusResponse = resultJson[0]['status'];

        Uri url1 = Uri.parse("https://smh-app.trent-tata.com/flask/get_reason_message/${widget.storeId}/$Pposition/${widget.equipmentId}");
        var response1 = await ioClient.get(url1);
        var resultJson1 = json.decode(response1.body);
        final message = resultJson1[0]['detection'];

        Uri url2 = Uri.parse("https://smh-app.trent-tata.com/flask/get_product_image_grid/$position/${widget.equipmentId}");
        var response2 = await ioClient.get(url2);
        var resultJson2 = json.decode(response2.body);
        final imageBase64 = resultJson2[0]['file_contents'];
        final code = resultJson2[0]['code'];
        final colour = resultJson2[0]['color'];


          final bytes = base64Decode(imageBase64);
          ImageProvider productImage = MemoryImage(bytes);
          String productCode = code.toString();
          String requiredColour = colour.toString();
          print("$productCode....$requiredColour....");


        setState(() {
          status = statusResponse;
          sendingPosition = position;
          dialogue = message;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(image: image,stid:widget.storeId,eqid:widget.equipmentId,
                    equipName:widget.equipName,position:position,equipType:widget.equipType,imageWidget:widget.imageWidgets,
                    snpShot:widget.Snpshot,fileName:widget.filename,equipCode:widget.equipCode, takenImages:widget.takenImages,
                    dialogue: dialogue,complianceProduct:complianceProduct.toString(),complianceColor:complianceColor.toString(),compliancePosition:compliancePosition.toString(),
                complianceQuantity:complianceQuantity.toString(),complianceSizeratio:complianceSizeRatio.toString(),complianceStatus:complianceStatus.toString(),
                displayProductCode:productCode,displayProductImage:productImage,displayColour:requiredColour)
              ),
            );
        });
      } catch (e) {
        print('Error fetching image: $e');
      }
  }





  Future<void> fetchDetectionPercentage () async{
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_compliance_detection_percentage_latest/${widget.storeId}/${widget.equipmentId}/${widget.equipType.toString()}");
      var response = await ioClient.get(url);
      var resultJson = json.decode(response.body);
      final percentResponse = resultJson['percent'];
      setState(() {
        detectionPercent = int.parse(percentResponse);

      });

    }


  Future<void> fetchDetectionTimeTaken() async{
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_detection_time_taken/${widget.storeId}/${widget.equipmentId}");
    var response = await ioClient.get(url);
    var resultJson = json.decode(response.body);
    //print(resultJson);
    final timeTakenResponse = resultJson[0]['time_taken'];
    setState(() {
      detectionTime = timeTakenResponse.toString();
    });
  }

  ///printActionList  API
  Future printActionList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_flutter_pdf"),
          body: json.encode({"equipment_id": widget.equipmentId, "store_code":widget.storeId}),
          headers: {
            "content-type": "application/json",
            "accept": "application/pdf",
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        Directory('${appDocDirectory.path}/dir')
            .create(recursive: true)
            .then((Directory directory) async {
          final file = File("${directory.path}/ComplianceActionList.pdf");
          await file.writeAsBytes(response.bodyBytes);
          // ignore: use_build_context_synchronously
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => showActionListPDF(pdfPath: "${directory.path}/ComplianceActionList.pdf",stid: widget.storeId.toString(),eqid:widget.equipmentId.toString())));
          print("${directory.path}/ComplianceActionList.pdf");
        });
        setState(() {
          _isLoading = false;
        });
      }
      else{
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
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

/// VM PDF PREVIEW /////
class VMShowPDF extends StatefulWidget {


  // In the constructor, require a Todo.
  const VMShowPDF({Key? key, required this.pdfPath,required this.sheet,required this.tiger}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String pdfPath;
  final String sheet;
  final String tiger;

  @override
  State<VMShowPDF> createState() => _VMShowPDFState();
}
class _VMShowPDFState extends State<VMShowPDF> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VM Guideline',style:TextStyle(fontSize: 16)),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              VMpdfprint(widget.sheet,widget.tiger);
            },
          ),

        ],
        backgroundColor: Colors.black,
        elevation: 0.00,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: <Widget>[
            if (widget.pdfPath != null)
              Expanded(
                child: PdfView(path: widget.pdfPath),
              )
            else
             const Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }
  /// VM PRINT PDF USING WIFI ///
  Future VMpdfprint(VMId,EqptId) async {
    //print(VMId);
    //print(EqptId);
    try {
      print("Calling...Print....");
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_vm_guideline_pdf_preview"),
          body: json.encode({"table_id":VMId,"equipment_id":EqptId}),
          headers: {
            "content-type": "application/json",
            "accept": "application/pdf",
          });
      print(response.statusCode);

      await Printing.layoutPdf(
        onLayout: (_) => response.bodyBytes,
        // name: 'My Document',
        format: PdfPageFormat.letter.copyWith(
          // Set the page size to landscape orientation
          width: PdfPageFormat.a4.height,
          height: PdfPageFormat.a4.width,
          // landscape:true,

        ),
      );

    } catch (e) {
      print(e.toString());
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


_getScoreColor(int detectionPercent) {
  if (detectionPercent >= 80) {
    return Colors.green;
  } else if (detectionPercent >= 50 && detectionPercent < 80) {
    return Colors.yellow;
  } else {
    return Colors.red;
  }
}

// ignore: camel_case_types
class showActionListPDF extends StatefulWidget {

  // In the constructor, require a Todo.
  const showActionListPDF({Key? key, required this.pdfPath,required this.stid,required this.eqid}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String pdfPath;
  final String stid;
  final String eqid;


  @override
  State<showActionListPDF> createState() => _showActionListPDFState();
}
// ignore: camel_case_types
class _showActionListPDFState extends State<showActionListPDF> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('',style:TextStyle(fontSize: 16)),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ComplianceActionListpdfprint(widget.eqid,widget.stid);

            },
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0.00,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: <Widget>[
            if (widget.pdfPath != null)
              Expanded(
                child: PdfView(path: widget.pdfPath),
              )
            else
              const Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }

}



/// VM PRINT PDF USING WIFI ///
Future ComplianceActionListpdfprint(stId,eqId) async {
  try {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_flutter_pdf"),
        body: json.encode({"equipment_id":stId.toString(), "store_code": eqId.toString()}),
        headers: {
          "content-type": "application/json",
          "accept": "application/pdf",
        });
    print(response.statusCode);

    await Printing.layoutPdf(
      onLayout: (_) => response.bodyBytes,
      // name: 'My Document',
      format: PdfPageFormat.letter.copyWith(
        // Set the page size to landscape orientation
        width: PdfPageFormat.a4.height,
        height: PdfPageFormat.a4.width,
        // landscape:true,

      ),
    );

  } catch (e) {
    print(e.toString());
  }
}

Future<SecurityContext> get globalContext async {
  final sslCert1 = await rootBundle.load('assets/starttrent.pem');
  SecurityContext sc = SecurityContext(withTrustedRoots: false);
  sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
  return sc;
}













class DetailScreen extends StatefulWidget {

  final ImageProvider image;
  final String? stid;
  final String? eqid;
  final String? equipName;
  final int? position;
  final String? equipType;
  final List<Image> imageWidget;
  final String? snpShot;
  final String? fileName;
  final String? equipCode;
  final String? dialogue;
  final String? complianceProduct;
  final String? compliancePosition;
  final String? complianceColor;
  final String? complianceSizeratio;
  final String? complianceQuantity;
  final String? complianceStatus;
  final String? orientation;
  final String? displayProductCode;
  final List<List<int>> takenImages;
  final ImageProvider<Object> displayProductImage;
  final String displayColour;

  const DetailScreen({Key? key, required this.image, this. stid, this. eqid, this. equipName, this. position,
    this. equipType, required this. imageWidget, this. snpShot, this. fileName, this. equipCode, required this. takenImages,this.dialogue, this. complianceProduct, this. complianceQuantity, this. complianceColor, this. compliancePosition, this. complianceSizeratio, this.complianceStatus, this. orientation,
    this.displayProductCode,  required this.displayProductImage,  required this. displayColour}) : super(key: key);
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

  class _DetailScreenState extends State<DetailScreen> {
    final PageController _pageController = PageController();
    int _currentPageIndex = 0;
  // ImageProvider? productImage;
  // String productCode = '';
  // String requiredColour = '';
  Color buttermilkColor = const Color.fromRGBO(255, 238, 204, 1.0);
    List<Map<String, dynamic>> producttableData = [];
     Future<List<dynamic>>? _apiDataFuture;
  String? store;
  String? product;
  String? equipment;
  String? storecode;
  double?  systemQty;
  double?  sitQty;
  double?  TsystemQty;
  double?  TposQty;
  String  season = "";
  String  materialGroup = "";
  String v_sizeCount = '';
  String d_sizeCount = '';
  int diff = 0;
  var message;
  var storeGate;
  String? articleCode;
  String? barcodeValue;
  String cheatSize = '0';
  bool showSubmitButton = false;
  String? selectedQuantity;
  String? sizeCorrectionSize;
  List<stockQuery> stockList = [];
  List<Comp> compList = [];


    @override
  void initState() {
  super.initState();
  _loadShowSubmitButton();
  //_apiDataFuture = fetchCombinedData();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // fetchImage();
  // Future.delayed(Duration(milliseconds: 100), () {
  //   _showPopupMessage(context);
  //   // Call dependOnInheritedWidgetOfExactType or dependOnInheritedElement here.
  // });

    }


    @override
    void dispose() {
      SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      clearSharedPreferences();
      _disposeAsyncTasks(); // Call the async function to handle async tasks
      super.dispose();
    }

    Future<void> _disposeAsyncTasks() async {
      // Perform any necessary cleanup tasks here
      final preferences = await SharedPreferences.getInstance();
      preferences.setBool('showSubmitButton', false);
    }

    Future<void> _loadShowSubmitButton() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        showSubmitButton = preferences.getBool('showSubmitButton') ?? false;
      });
    }



    String getTitleText(String dialogue) {
      if (dialogue == 'Colour, position and quantity matching. No SAP checking required. Tick Mark') {
        return 'Product and position as per guideline';
      } else if (dialogue == '1. VM position != D Position or VM colour != D Colour and SAP qty < 5. Tick Mark') {
        return 'Wrong Product But Not Enough Stock';
      } else if (dialogue == '2. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
        return 'Required quantity not on display';
      } else if (dialogue == '2. VM position != D Position or VM colour != D Colour and SAP qty >= VM qty. Cross Mark') {
        return 'Wrong product placed';
      } else if (dialogue == '3. qtyDiff >= 80 and VM position = D Position or VM colour = D Colour. Tick Mark') {
        return 'Product and position as per guideline';
      } else if (dialogue == '4. qtyDiff >= 80 and VM position = D Position or VM colour != D Colour. Cross Mark') {
        return 'Wrong product placed';
      } else if (dialogue == '5. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
        return 'Required quantity not on display';
      } else if (dialogue == '6. qtyDiff < 80 and SAP qty < VM qty. Tick Mark') {
        return 'Not enough stock';
      } else {
        return '';
      }
    }

    Color getTitleColor(String dialogue) {
      if (dialogue == 'Colour, position and quantity matching. No SAP checking required. Tick Mark') {
        return Colors.green;
      } else if (dialogue == '1. VM position != D Position or VM colour != D Colour and SAP qty < 5. Tick Mark') {
        return Colors.green;
      } else if (dialogue == '2. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
        return Colors.red;
      } else if (dialogue == '2. VM position != D Position or VM colour != D Colour and SAP qty >= VM qty. Cross Mark') {
        return Colors.red;
      } else if (dialogue == '3. qtyDiff >= 80 and VM position = D Position or VM colour = D Colour. Tick Mark') {
        return Colors.green;
      } else if (dialogue == '4. qtyDiff >= 80 and VM position = D Position or VM colour != D Colour. Cross Mark') {
        return Colors.red;
      } else if (dialogue == '5. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
        return Colors.red;
      } else if (dialogue == '6. qtyDiff < 80 and SAP qty < VM qty. Tick Mark') {
        return Colors.green;
      } else {
        return Colors.black;
      }
    }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.equipName.toString(), style: const TextStyle(fontSize: 16,color: Colors.white)),
          backgroundColor: Colors.black,
          leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            },
             icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),

      ),
      body: SingleChildScrollView(
        child:Container(
         color:Colors.white,
         child:Column(
          children: [ Container(
            padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 10),
            height: 180,
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 10),
                  height: 180,
                  color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return
                                  Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue,
                                  ),
                                  child: Stack(
                                    children: [
                                       GestureDetector(
                                        onTap: () {
                                          _showImagePopup(context);
                                        },
                                        child: Container(
                                          width: 200,
                                          height: 200,

                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: widget.image,
                                              fit: BoxFit.cover,
                                            ),

                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child:  GestureDetector(
                                        onTap: () {
                                          _showImagePopup(context);
                                         },
                                        child:Container(
                                          padding: const EdgeInsets.only(top: 10, left: 20),
                                          width: 160,
                                          height: 150,

                                          child: Icon(
                                            widget.complianceStatus == '1'
                                                ? Icons.check
                                                : widget.complianceStatus.toString() == '5'
                                                ? Icons.circle_outlined
                                                : Icons.close,
                                            size: 100,
                                            color: widget.complianceStatus.toString() == '1'
                                                ? Colors.green
                                                : widget.complianceStatus.toString() == '5'
                                                ? Colors.white
                                                : Colors.red,
                                          ),
                                        ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        top: 0,
                                        left: 20,
                                        child:GestureDetector(
                                         onTap: () {
                                         _showImagePopup(context);
                                         },
                                       child:Container(
                                          padding: const EdgeInsets.only(top: 30),
                                          width: 140,
                                          height: 50,
                                          color: Colors.black.withOpacity(0),
                                          child: Text(
                                            '${int.parse(widget.position.toString()) + 1}\n'
                                                'Prod:${widget.complianceProduct.toString() == '1' ? 'Yes' : 'No'} \n'
                                                'Posi:${widget.compliancePosition.toString() == '1' ? 'Yes' : 'No'}\n'
                                                'Col: ${widget.complianceColor.toString() == '1' ? 'Yes' : 'No'} \n'
                                                'Qty: ${widget.complianceQuantity.toString()} \n'
                                                'Size Rt:${widget.complianceSizeratio.toString() == '1' ? 'Yes' : 'No'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                       ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),


                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.only(left: 10, bottom: 0, right: 10, top: 0),
                          child: Text(
                            getTitleText(widget.dialogue.toString()),
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: getTitleColor(widget.dialogue.toString(),),
                              fontSize: 16,
                              // Add other text styling options as needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),





            if (widget.displayProductImage != null)
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 60, bottom: 0, right: 0, top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                  onTap: () {
                  _showProductImagePopup(context);
                    },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(85),
                    child: Transform.scale(
                      scale: 0.8, // Adjust the scale value to resize the image
                      child: Image(
                        image: widget.displayProductImage!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, ),
                      ),
                      Text(widget.displayProductCode.toString(), style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      const Text('Required Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, // Adjust the font size as needed
                        ),
                      ),
                      Text(widget.displayColour, style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),


  ///     Home ///////////////////////////////////////////////////////////////////////////////////////////
           Container(
                height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - 334,
                 // color: Colors.cyanAccent,
                padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 0),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        children: [
                          buildTable1(),
                          buildTable2(),

                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DotsIndicator(
                      dotsCount: 2,
                      position: _currentPageIndex.toInt(),
                      decorator: const DotsDecorator(
                        activeColor: Colors.black,
                        activeSize: Size(9, 9),
                        size: Size(6, 6),
                        spacing: EdgeInsets.symmetric(horizontal: 4),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
      )
      ),
    );
  }
    /// SIZE /////////////////////////////////////////////////////////////////////////////////////////////////////
    Widget buildTable1() {
      return SingleChildScrollView(
        child:Column(
        children: [
                 Container(
                   padding: const EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 0),
                   child: const Text('Size / Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),),

                          FutureBuilder<List<dynamic>>(
                              initialData: const <dynamic>[],
                              future:  fetchCombinedData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError ||
                                    snapshot.data == null ||
                                    snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text("Loading...");
                                }
                                List<Comp> compList = snapshot.data![1];
                                List<stockQuery> stockList = snapshot.data![0];

                                List<Map<String, dynamic>> tableData = [];
                                tableData.clear();
                                producttableData.clear();
                                Set<String> uniqueSizes = {};

                                for (int i = 0; i < compList.length; i++) {
                                  Comp comp = compList[i];
                                  var sizeKey;
                                  var guidelineSize;

                                  if(widget.equipName.toString() == 'BT1-FRONT' || widget.equipName.toString() == 'GT1-FRONT' ||
                                      widget.equipName.toString() == 'BT2-FRONT' || widget.equipName.toString() == 'GT2-FRONT' ) {
                                    guidelineSize = comp.size.toString();
                                    String numericPart = extractNumericPart(guidelineSize);
                                    sizeKey = numericPart;
                                    print(sizeKey);
                                  }
                                  else{
                                    guidelineSize = comp.size.toString();
                                    sizeKey = guidelineSize;
                                  }
                                  v_sizeCount = comp.sizeCount.toString();
                                  d_sizeCount = comp.quantity.toString();
                                  var a = int.parse(comp.sizeCount.toString());
                                  var b = int.parse(comp.quantity.toString());
                                  diff = a - b;
                                  if (diff > 0) {
                                    message = "Add\n${NumberToWordsEnglish.convert(diff)} - ${sizeKey.toString()}";
                                  } else if (diff < 0) {
                                    message = "Remove\n${NumberToWordsEnglish.convert(-diff)} - ${sizeKey.toString()}";
                                  } else {
                                    message = "Nil";
                                  }


                                  systemQty = 0.0; // Default to 0
                                  sitQty = 0.0;    // Default to 0
                                  String articleNo = '';
                                  String colour = '';
                                  String  extractedArticleNo = 'Nill';// Initialize with an empty string

                                  for (int j = 0; j < stockList.length; j++) {
                                  stockQuery stock = stockList[j];
                                     if (sizeKey == stock.size.toString()) {
                                        systemQty = stock.sap?.toDouble() ?? 0.0;
                                        sitQty = stock.trans_qty?.toDouble() ?? 0.0;
                                        articleNo = stock.material_code.toString();
                                        colour = stock.colour.toString();
                                        extractedArticleNo = articleNo.substring(articleNo.length - 12);// Take article number from stock
                                    break; // Exit the loop when a matching stock is found
                                   }
                                 }

                                if (!uniqueSizes.contains(sizeKey)) {
                                  tableData.add({
                                    'articleNo': extractedArticleNo.toString(),
                                    'size': sizeKey,
                                    'v_quantity': comp.sizeCount.toString(),
                                    'd_quantity': comp.quantity.toString(),
                                    'difference': diff.toString(),
                                    'sap': systemQty.toString(),
                                    'sit': sitQty.toString(),
                                    'message': message.toString(),
                                    'colour': colour.toString(),
                                    // You need to populate the color as per your data
                                  });

                                  producttableData.add({
                                    'articleNo': extractedArticleNo.toString(),
                                    'size': sizeKey,
                                    'sap': systemQty.toString(),
                                    'sit': sitQty.toString(),
                                    'colour': colour.toString(),
                                    // You need to populate the color as per your data
                                  });
                                  uniqueSizes.add(sizeKey);
                                }
                                }





                             return FittedBox(
                                  child:DataTable(
                                      columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                                      headingRowHeight: 60,
                                      headingRowColor:
                                      MaterialStateColor.resolveWith((states) =>
                                      Colors.black45),
                                      columns: const [

                                        DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('Required\n  Count',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('Actual\nCount',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('Diff',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('SAP',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('SIT',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
                                        DataColumn(label: Text('Action',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),),
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
                                                  Text(data["articleNo"],textAlign:TextAlign.left,style: const TextStyle(fontSize: 18))
                                              ),
                                              DataCell(
                                                  Center(child: Text(data["size"],textAlign:TextAlign.center,style: const TextStyle(fontSize: 18))
                                                  )),
                                              DataCell(
                                                  Center(child:Text(data["v_quantity"],textAlign:TextAlign.right,style: const TextStyle(fontSize: 18))
                                                  )
                                              ),
                                              DataCell(
                                                  GestureDetector(
                                                    child:Container(
                                                      color:Colors.grey.shade300,
                                                    child: Center(child:Text(data["d_quantity"],textAlign:TextAlign.right,style: const TextStyle(fontSize: 23),)),
                                                  ),
                                                    onTap: () async{
                                                      if (await Vibration.hasVibrator() ?? false) {
                                                      Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                                      }
                                                      setState(() {
                                                        sizeCorrectionSize = data["size"];
                                                      });

                                                      // ignore: use_build_context_synchronously
                                                      _showUpdateActualQuantityDialog(context);
                                                      // showDialog(
                                                      //   context: context,
                                                      //   builder: (context) => UpdateActualQuantity(productCode:productCode,stid:widget.stid,eqid:widget.eqid,size:data["size"],
                                                      //   image:widget.image,position:widget.position,equipName:widget.equipName,equipType:widget.equipType,imageWidget:widget.imageWidget,
                                                      //   takenImages:widget.takenImages,equipCode:widget.equipCode,fileName:widget.fileName,Snpshot:widget.snpShot),
                                                      // );
                                                      },
                                                  )
                                                    ),
                                              DataCell(
                                                Center (child:Text(data["difference"],textAlign:TextAlign.right,style: TextStyle(fontSize: 18),),
                                                ),
                                              ),
                                              DataCell(
                                                  Center(child:Text(data["sap"],textAlign:TextAlign.left,style: TextStyle(fontSize: 18),),
                                                  )),
                                              DataCell(
                                                  Center(child:Text(data["sit"],textAlign:TextAlign.left,style: TextStyle(fontSize: 18),),
                                                  )),
                                              DataCell(
                                                Center(child:Text(data["message"],textAlign:TextAlign.left,style: TextStyle(fontSize: 18),),
                                                ),
                                              )
                                            ]);
                                      }).toList(),
                                    )
                                );
                                },
                              ),

                                Container(
                                  color:Colors.grey,
                                  padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 0),
                                  child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                   ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return BarCodeSize(eqpt: widget.eqid.toString(),stid:widget.stid.toString(), 
                                               image:widget.image,
                                               equipName:widget.equipName,
                                               position: widget.position,
                                               equipType:widget.equipType,
                                               equipCode:widget.equipCode,
                                               fileName:widget.fileName,
                                               SnpShot:widget.snpShot,
                                               imageWidget:widget.imageWidget,
                                               takenImages:widget.takenImages,
                                               displayProductImage:widget.displayProductImage,
                                               displayColour:widget.displayColour,
                                               displayProductCode:widget.displayProductCode.toString()
                                              );

                                        },
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    minimumSize: const Size(70, 35),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                                    child: Text(
                                      'Size Correction Scan',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    var Position = widget.position! + 1;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                            CaptureClosupStack(image:widget.image,imageWidget:widget.imageWidget,
                                              takenImages:widget.takenImages,storeId:widget.stid,
                                              equipmentId:widget.eqid,productCode:widget.displayProductCode,
                                              stackPosition:Position,equipType:widget.equipType,equipCode:widget.equipCode,
                                              equipName:widget.equipName,snpShot:widget.snpShot,fileName:widget.fileName

                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    minimumSize: const Size(70, 35),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                                    child:Text('Capture Closeup Image',style: TextStyle(fontSize: 13),),
                                  ),
                                ),
                                  ],
                                 ),
                                ),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            if (showSubmitButton)
             ElevatedButton(
              onPressed: () {
              checkCheatsheetAndDetected();
              },
               style: ElevatedButton.styleFrom(
               primary: Colors.black,
               onPrimary: Colors.white,
               elevation: 3,
               shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(5.0),
              ),
               minimumSize: const Size(70, 35),
           ),
               child: const Padding(
                padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                child:Text('Submit',style: TextStyle(fontSize: 13),),
            ),
          ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return BarCodeScannerCompliance(eqpt: widget.eqid.toString(),stid:widget.stid.toString(),
                          takenImages: widget.takenImages,equipType:widget.equipType.toString(),fileName: widget.fileName,
                          equipCode: widget.equipCode,equipName: widget.equipName,Snpshot: widget.snpShot,imageWidget: widget.imageWidget);
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                minimumSize: const Size(70, 35),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                child:Text('Barcode',style: TextStyle(fontSize: 13),),
              ),
            ),
            ],
          ),
        ],
      )
      );
    }


    Widget buildTable2() {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 0),
            child: const Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),),
              FittedBox(
                  child: DataTable(

                    columnSpacing: 10,
                    headingRowHeight: 50,
                    dataRowHeight: 30,
                    headingRowColor:
                    MaterialStateColor.resolveWith((states) =>
                    Colors.black45),
                    columns: const [
                      DataColumn(label: Text('Article No',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                      DataColumn(label: Text('Size',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                      DataColumn(label: Text('Colour',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                      DataColumn(label: Text('SAP\nQty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                      DataColumn(label: Text('SIT\nQty',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
                      DataColumn(label: Text('   Alternate\nProducts',textAlign:TextAlign.right,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white,)),),
                    ],
                    rows: producttableData.map((data) {
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

                                return Colors.white.withOpacity(0.2);
                              }),

                          cells: [

                            DataCell(
                                Text(data['articleNo'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),)),
                            DataCell(
                                Center(child:Text(data['size'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),),
                                )),
                            DataCell(
                                Text(data['colour'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),)),

                            DataCell(
                                Text(data['sap'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),)),
                            DataCell(
                                Text(data['sit'],textAlign:TextAlign.left,style: TextStyle(fontSize: 12),)),

                            DataCell(
                              GestureDetector(
                                  child:  const Text("Click for Detail",textAlign:TextAlign.left,style: TextStyle(fontSize: 12,color: Colors.purple,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AlternateProductCompliance(storeCode: storecode.toString(), materialGroup: data['materialGroup'].toString(),
                                          season:data['season'].toString(),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          ]);
                    }).toList(),
                  )
              ),



          Container(
            padding: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    var Position = widget.position! + 1;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          CaptureClosupStack(image:widget.image,imageWidget:widget.imageWidget,
                              takenImages:widget.takenImages,storeId:widget.stid,
                              equipmentId:widget.eqid,productCode:widget.displayProductCode,
                              stackPosition:Position,equipType:widget.equipType,equipCode:widget.equipCode,
                              equipName:widget.equipName,snpShot:widget.snpShot,fileName:widget.fileName

                          ),
                      ),
                    );
                  },
                      style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: const Size(70, 35),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                    child:Text('Capture Closeup Image',style: TextStyle(fontSize: 11),),
                  ),
                ), ElevatedButton(
                   onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return BarCodeScannerCompliance(eqpt: widget.eqid.toString(),stid:widget.stid.toString(),
                              takenImages: widget.takenImages,equipType:widget.equipType.toString(),fileName: widget.fileName,
                              equipCode: widget.equipCode,equipName: widget.equipName,Snpshot: widget.snpShot,imageWidget: widget.imageWidget);
                        },
                      ),
                    );
                  },
                       style: ElevatedButton.styleFrom(
                       primary: Colors.black,
                       onPrimary: Colors.white,
                       elevation: 3,
                       shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: const Size(70, 35),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7), // Add padding here
                    child:Text('Barcode',style: TextStyle(fontSize: 13),),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }



    // void _showPopupMessage(BuildContext context) {
    //   String titleText;
    //   Color titleColor = Colors.black;
    //   if (widget.dialogue.toString() == 'Colour, position and quantity matching. No SAP checking required. Tick Mark') {
    //     titleText = 'Product and position as per guideline';
    //     titleColor = Colors.green;
    //   } else if (widget.dialogue.toString() == '1. VM position != D Position or VM colour != D Colour and SAP qty < 5. Tick Mark') {
    //     titleText = 'Not enough stock of required product';
    //     titleColor = Colors.green;
    //   } else if (widget.dialogue.toString() == '2. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
    //     titleText = 'Required quantity not on display';
    //     titleColor = Colors.red;
    //   }else if (widget.dialogue.toString() == '2. VM position != D Position or VM colour != D Colour and SAP qty >= VM qty. Cross Mark') {
    //     titleText = 'Required quantity not on display';
    //     titleColor = Colors.red;
    //   }else if (widget.dialogue.toString() == '3. qtyDiff >= 80 and VM position = D Position or VM colour = D Colour. Tick Mark') {
    //     titleText = 'product and position as per guideline';
    //     titleColor = Colors.green;
    //   }else if (widget.dialogue.toString() == '4. qtyDiff >= 80 and VM position = D Position or VM colour != D Colour. Cross Mark') {
    //     titleText = 'Wrong product placed';
    //     titleColor = Colors.red;
    //   }else if (widget.dialogue.toString() == '5. qtyDiff < 80 and SAP qty >= VM qty. Cross Mark') {
    //     titleText = 'Required quantity not on display';
    //     titleColor = Colors.red;
    //   }else if (widget.dialogue.toString() == '6. qtyDiff < 80 and SAP qty < VM qty. Tick Mark') {
    //     titleText = 'Not enough stock';
    //     titleColor = Colors.green;
    //   }
    //   else {
    //     titleText = '';
    //   }
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //
    //             Row(
    //               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Container(
    //                   width:180,
    //                   child:Text(titleText,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: titleColor),),
    //                 ),
    //
    //                // Title
    //                 Align(
    //                   alignment: Alignment.topRight,
    //                   child: IconButton(
    //                     iconSize: 20, // Customize the size of the close icon button
    //                     icon: const Icon(Icons.close), // Close icon
    //                     onPressed: () {
    //                       Navigator.of(context).pop();
    //                     },
    //                   ),
    //                 ),
    //               ],
    //
    //
    //             ),
    //
    //           ],
    //         ),
    //       );
    //     },
    //   );
    // }








    String extractNumericPart(String input) {
      RegExp regExp = RegExp(r'[\d\/.-]+');
      Match match = regExp.firstMatch(input) as Match;

      if (match != null) {
        return match.group(0)!; // Group 0 contains the whole match
      } else {
        return "No numeric value found.";
      }
    }
    /// fetch image and colour,productCode
    String v_quantity = '';
    String d_quantity = '';

  //   Future<void> fetchImage () async{
  //   //print("productImagePosition...${widget.position}");
  //   try {
  //     HttpClient client = HttpClient(context: await globalContext);
  //     client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
  //     IOClient ioClient = IOClient(client);
  //     Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_product_image_grid/${widget.position}/${widget.eqid}");
  //     var response = await ioClient.get(url);
  //     var resultJson = json.decode(response.body);
  //     final imageBase64 = resultJson[0]['file_contents'];
  //     final code = resultJson[0]['code'];
  //     final colour = resultJson[0]['color'];
  //     setState(() {
  //       final bytes = base64Decode(imageBase64);
  //       productImage = MemoryImage(bytes);
  //       productCode = code.toString();
  //       requiredColour = colour.toString();
  //     });
  //   } catch (e) {
  //     print('Error fetching image: $e');
  //   }
  // }





    void _showImagePopup(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: InteractiveViewer(
              child: Container(
                width: double.maxFinite,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }

    void _showProductImagePopup(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: InteractiveViewer(
              child: Container(
                width: double.maxFinite,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.displayProductImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close',),
              ),
            ],
          );
        },
      );
    }


    Future<List<dynamic>> fetchCombinedData() async {
      var sendPosition = widget.position! + 1;
      // print(sendPosition);
      // print(productCode);

      // Check if data is already fetched
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isDataFetched = prefs.getBool('isDataFetched') ?? false;
      if (isDataFetched) {
        // Data has already been fetched, return the existing data
        List<Comp> compList = prefs.getStringList('compList')!.map((json) => Comp.fromJson(jsonDecode(json))).toList();
        List<stockQuery> stockList = prefs.getStringList('stockList')!.map((json) => stockQuery.fromJson(jsonDecode(json))).toList();
        return [stockList, compList];
      }

      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);

      final storeResponse = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
        body: json.encode({"storeId": widget.stid.toString()}),
        headers: {"content-type": "application/json",},
      );
      var storeJson = json.decode(storeResponse.body);
      storecode = storeJson[0]['code'];
     // print("storeCode.......$storecode");

      final stockResponse = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
        body: json.encode({
          "storeCode": storecode.toString(),
          "code":widget.displayProductCode.toString(),
        }),
        headers: {
          "content-type": "application/json",
        },
      );

      final complianceResponse = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_detected_size_latest"),
        body: json.encode({
          "storeId": widget.stid.toString(),
          "equipmentId": widget.eqid.toString(),
          "product_code": widget.displayProductCode.toString(),
          "position": sendPosition,
        }),
        headers: {
          "content-type": "application/json",
        },
      );

      var stockJson = json.decode(stockResponse.body).cast<Map<String, dynamic>>();
      var complianceJson = json.decode(complianceResponse.body).cast<Map<String, dynamic>>();
     // print(complianceJson);
     // print(stockJson);
      List<stockQuery> stockList = stockJson.map<stockQuery>((json) => stockQuery.fromJson(json)).toList();
      List<Comp> compList = complianceJson.map<Comp>((json) => Comp.fromJson(json)).toList();

      // Store data in shared preferences
      prefs.setBool('isDataFetched', true);
      prefs.setStringList('compList', compList.map((comp) => jsonEncode(comp.toJson())).toList());
      prefs.setStringList('stockList', stockList.map((stock) => jsonEncode(stock.toJson())).toList());

      return [stockList, compList];
    }

    Future<void> clearSharedPreferences() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

  /// size Api//////////////////////////////////////////////////////////
  // Future<List<dynamic>> fetchCombinedData() async {
  //     var sendPosition = widget.position! + 1;
  //   HttpClient client = HttpClient(context: await globalContext);
  //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
  //   IOClient ioClient = IOClient(client);
  //
  //   final storeResponse = await ioClient.post(
  //     Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
  //     body: json.encode({"storeId": widget.stid.toString()}),
  //     headers: {"content-type": "application/json",},
  //   );
  //   var storeJson = json.decode(storeResponse.body);
  //   storecode = storeJson[0]['code'];
  //   print("storeCode.......$storecode");
  //   final stockResponse = await ioClient.post(
  //     Uri.parse("https://smh-app.trent-tata.com/tomcat/ReboTataSMHApi/rest/zud_smh_inv"),
  //     body: json.encode({
  //       "storeCode": storecode.toString(),
  //       "code": productCode.toString(),
  //     }),
  //     headers: {
  //       "content-type": "application/json",
  //     },
  //   );
  //   final complianceResponse = await ioClient.post(
  //     Uri.parse("https://smh-app.trent-tata.com/flask/get_detected_size_latest"),
  //     body: json.encode({"storeId": widget.stid.toString(), "equipmentId": widget.eqid.toString(), "product_code": productCode.toString(),
  //       "position":sendPosition
  //     }),
  //     headers: {
  //       "content-type": "application/json",
  //     },
  //   );
  //   var stockJson = json.decode(stockResponse.body).cast<Map<String, dynamic>>();
  //   var complianceJson = json.decode(complianceResponse.body).cast<Map<String, dynamic>>();
  //  // print(complianceJson);
  //   //print(stockJson);
  //   List<stockQuery> stockList = stockJson.map<stockQuery>((json) => stockQuery.fromJson(json)).toList();
  //   List<Comp> compList = complianceJson.map<Comp>((json) => Comp.fromJson(json)).toList();
  //   return [stockList, compList];
  // }

/// checking CheatsheetAndDetected  are equal or not
Future<void> checkCheatsheetAndDetected () async {
  HttpClient client = HttpClient(context: await globalContext);
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
  IOClient ioClient = IOClient(client);

  final Response = await ioClient.post(
  Uri.parse("https://smh-app.trent-tata.com/flask/get_both_check_detect_cheatsheet_size_equal_latest"),
      body: json.encode({"storeId": widget.stid.toString(), "equipmentId": widget.eqid.toString(), "product_code":widget.displayProductCode.toString(),
  }),
  headers: {
  "content-type": "application/json",
  },
  );
  var checkCheatsheetAndDetectedJson = json.decode(Response.body).cast<Map<String, dynamic>>();
  // Search for all_sizes_quantity_equal values equal to 1
  bool allSizesQuantityEqual = true;
  for (var item in checkCheatsheetAndDetectedJson) {
    if (item['all_sizes_quantity_equal'] != 1) {
      allSizesQuantityEqual = false;
      break;
    }
  }

  if (allSizesQuantityEqual) {
    int statusGreen = 1;
    UpdatingComplianceSize(statusGreen);
    print('All sizes and quantities are equal');
  } else {
    int statusRed = 3;
    UpdatingComplianceSize(statusRed);
    print('Sizes and quantities are not equal');
  }
}

// /// update Status for if Sizes and quantities are not equal
//     Future<void> updatingStatus() async {
//   HttpClient client = HttpClient(context: await globalContext);
//   client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
//   IOClient ioClient = IOClient(client);
//   final response = await ioClient.post(
//     Uri.parse("https://smh-app.trent-tata.com/flask/get_update_status"),
//     body: json.encode({"storeId": widget.stid.toString(), "equipmentId": widget.eqid.toString(), "product_code": productCode.toString(),
//     }),
//     headers: {
//       "content-type": "application/json",
//     },
//   );
//   if(response.statusCode == 200)
//     {
//       print("update successfully");
//        UpdatingComplianceSize ();
//     }
// }
/// Update Size Correption
    Future<void> UpdatingComplianceSize (int statusCode) async {
      final Pposition = widget.position! + 1;
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getRedrawnImageAfterUpdatingComplianceValues');
        final request = http.MultipartRequest('POST', url);
        request.headers['Connection'] = 'Keep-Alive';
        int index = 1;

        // Add each image as a file field
        for (var i = 0; i < widget.takenImages.length; i++) {
          final fileName = '$index.jpg';

          request.fields['storeId'] = widget.stid.toString();
          request.fields['equipmentId'] = widget.eqid.toString();
          request.fields['productCode'] = widget.displayProductCode.toString();
          request.fields['productPosition'] = Pposition.toString();
          request.fields['status'] = statusCode.toString();


          request.files.add(await http.MultipartFile.fromBytes(
            'files[]', // Use a name that matches the server's expectations
            widget.takenImages[i],
            filename: fileName,
          ));

          request.fields['fileName$index'] = fileName;
          index++;
        }
        print("Sending ${widget.takenImages!.length} images...");
        var response = await ioClient.send(request).timeout(const Duration(seconds: 180));
        print(response.statusCode);
        if (response.statusCode != 200) {
          setState(() {
            // _isLoading = false;
          });
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("DETECTION FAILED"),
          //   backgroundColor: Colors.red,
          //   duration: Duration(seconds: 2),
          // ));
        }
        else {
          setState(() {
            // _isLoading = false;
          });
        }

        // Process the response data, e.g. display it in a new screen
        final imageData = await response.stream.toBytes();
        final archive = ZipDecoder().decodeBytes(imageData);

        // Sort the files in the archive based on their names numerically
        final sortedFiles = archive.files.toList()..sort((a, b) {
            final aNumeric = int.tryParse(
                a.name.replaceAll(RegExp('[^0-9]'), ''));
            final bNumeric = int.tryParse(
                b.name.replaceAll(RegExp('[^0-9]'), ''));
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
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetectedImage2(
                  imageWidgets: imageWidgets,
                  equipmentId: widget.eqid,
                  storeId: widget.stid,
                  takenImages: widget.takenImages,
                  equipType: widget.equipType,
                  filename: widget.fileName,
                  equipCode: widget.equipCode,
                  equipName: widget.equipName,
                  Snpshot: widget.snpShot,
                ),
          ),
        );
      }




      Future<void> _showUpdateActualQuantityDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedQuantity,
                        hint: const Text('Select Quantity'),
                        items: List<DropdownMenuItem<String>>.generate(10, (index) {
                          final number = (index + 0).toString();
                          return DropdownMenuItem<String>(
                            value: number,
                            child: Text(
                              number,
                              style: const TextStyle(
                                  fontSize: 14), // Adjust the font size as per your requirement
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
                    const SizedBox(width: 7),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedQuantity != null) {
                          final preferences = await SharedPreferences.getInstance();
                          await preferences.setBool('showSubmitButton', true);
                          clearSharedPreferences();
                          updateSizeRatios();
                          // Perform the async operation after updating preferences
                          setState(() {

                            // Update the widget's state
                          });
                          //Navigator.of(context).pop(); // Close the dialog after pressing "OK"
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(20, 36), // Adjust the button's minimumSize as per your requirement
                      ),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
    Future<void> updateSizeRatios() async {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_maximum_id/${widget.stid}/${widget.eqid}");
      var Idresponse = await ioClient.get(url);
      var IdresultJson = json.decode(Idresponse.body);
      final id = IdresultJson[0]['id'];
      url = Uri.parse("https://smh-app.trent-tata.com/flask/get_sizefrom_detected/$id/${widget.displayProductCode}");
      var detectedSizeresponse = await ioClient.get(url);
      var detectedSizeJson = json.decode(detectedSizeresponse.body);
      print("detected size json.........................$detectedSizeJson");
      bool sizeExists = false;
      for (var item in detectedSizeJson) {
        if (item['size'] == sizeCorrectionSize ) {
          item['quantity'] = selectedQuantity;
          sizeExists = true;
          break;
        }
      }

      // If widget.size does not exist, add it to detectedSizeJson
      if (!sizeExists) {
        detectedSizeJson.add({
          'size': sizeCorrectionSize,
          'quantity': selectedQuantity,
        });
      }

      print("Updated.........detected size json.........................$detectedSizeJson");

      final body = {
        'product_code': widget.displayProductCode,
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
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          print('Size ratios updated successfully');

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
}











/// popup dropdown for update actual quantity

// class UpdateActualQuantity extends StatefulWidget {
//   // In the constructor, require a Todo.
//   final String? productCode;
//   final String? stid;
//   final String? eqid;
//   final String? size;
//   final int? position;
//   final List<Image> imageWidget;
//   final ImageProvider image;
//   final String? equipName;
//   final String? equipType;
//   final String? equipCode;
//   final String? fileName;
//   final String? Snpshot;
//   final List<List<int>> takenImages;
//
//   const UpdateActualQuantity({Key? key, required this. productCode, this. stid, this. eqid,this.size, required this. image, this. position, this. equipName, this. equipType, required this. takenImages, this. equipCode, this. fileName, this. Snpshot, required this. imageWidget
//   }): super(key: key);
// // Step 2 <-- SEE HERE
//
//
//   @override
//   State<UpdateActualQuantity> createState() => _UpdateActualQuantityState();
// }
//
// class _UpdateActualQuantityState extends State<UpdateActualQuantity> {
//   String? selectedQuantity;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       // title: const Text("", style: TextStyle(fontSize: 0)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         // Make the dialog content wrap its children tightly
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: selectedQuantity,
//                   hint: const Text('Select Quantity'),
//                   items: List<DropdownMenuItem<String>>.generate(10, (index) {
//                     final number = (index + 0).toString();
//                     return DropdownMenuItem<String>(
//                       value: number,
//                       child: Text(
//                         number,
//                         style: const TextStyle(
//                             fontSize: 14), // Adjust the font size as per your requirement
//                       ),
//                     );
//                   }),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedQuantity = value; // Update selected quantity when dropdown value changes
//                     });
//                   },
//                 ),
//               ),
//               const SizedBox(width: 7),
//               // add some space between the DropdownButtonFormField and the button
//               ElevatedButton(
//                 onPressed: () async {
//                   if (selectedQuantity != null) {
//                     final preferences = await SharedPreferences.getInstance();
//                     await preferences.setBool('showSubmitButton', true);
//                     updateSizeRatios(); // Perform the async operation after updating preferences
//                     setState(() {
//                       // Update the widget's state
//                     });
//                   }
//                 },
//
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.black,
//                   onPrimary: Colors.white,
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   minimumSize: const Size(20, 36), // Adjust the button's minimumSize as per your requirement
//                 ),
//                 child: const Text("OK",),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> updateSizeRatios() async {
//     HttpClient client = HttpClient(context: await globalContext);
//     client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
//     IOClient ioClient = IOClient(client);
//     Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_maximum_id/${widget.stid}/${widget.eqid}");
//     var Idresponse = await ioClient.get(url);
//     var IdresultJson = json.decode(Idresponse.body);
//     final id = IdresultJson[0]['id'];
//     url = Uri.parse("https://smh-app.trent-tata.com/flask/get_sizefrom_detected/$id/${widget.productCode}");
//     var detectedSizeresponse = await ioClient.get(url);
//     var detectedSizeJson = json.decode(detectedSizeresponse.body);
//     print("detected size json.........................$detectedSizeJson");
//     bool sizeExists = false;
//     for (var item in detectedSizeJson) {
//       if (item['size'] == widget.size) {
//         item['quantity'] = selectedQuantity;
//         sizeExists = true;
//         break;
//       }
//     }
//
//     // If widget.size does not exist, add it to detectedSizeJson
//     if (!sizeExists) {
//       detectedSizeJson.add({
//         'size': widget.size,
//         'quantity': selectedQuantity,
//       });
//     }
//
//     print("Updated.........detected size json.........................$detectedSizeJson");
//
//     final body = {
//       'product_code': widget.productCode,
//       'detected_values_table_id': id.toString(),
//       'size_ratios': detectedSizeJson,
//     };
//
//     try {
//       final response = await ioClient.post(
//         Uri.parse("https://smh-app.trent-tata.com/flask/update_size_ratios"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );
//
//       if (response.statusCode == 200) {
//         // ignore: use_build_context_synchronously
//         Navigator.of(context).pop();
//         print('Size ratios updated successfully');
//         // ignore: use_build_context_synchronously
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => DetailScreen(
//         //       image:widget.image ,
//         //       eqid: widget.eqid.toString(),stid:widget.stid.toString(), equipName:widget.equipName,
//         //       position: widget.position,
//         //       imageWidget: widget.imageWidget, takenImages: widget.takenImages,equipCode: widget.equipCode,
//         //       equipType: widget.equipType,fileName: widget.fileName,snpShot: widget.Snpshot,
//         //
//         //     ),
//         //   ),
//         // );
//       } else {
//         print('Failed to update size ratios. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }





//   Future<SecurityContext> get globalContext async {
//     final sslCert1 = await rootBundle.load('assets/starttrent.pem');
//     SecurityContext sc = SecurityContext(withTrustedRoots: false);
//     sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
//     return sc;
//   }
//
// }






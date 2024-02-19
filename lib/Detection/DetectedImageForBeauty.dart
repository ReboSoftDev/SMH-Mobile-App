
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import 'package:sample/Camera/VMCameraHome.dart' as vmcamerahome;
import 'package:sample/Detection/DetailReportForBeauty.dart';
import 'package:sample/HomeMenu.dart';
import 'package:sample/homeclass.dart';
import '../Barcode/BarCodeScannerCompliance.dart';
import 'FirstDetailedReport.dart';



class DetectedImageForBeauty extends StatefulWidget {
  final List<Image> imagewidget;
  // this.filename ,this.equipCode, this.equipName, this. Snpshot
  const DetectedImageForBeauty({Key? key, required this.imagewidget, this.equipmentId, this.storeId, required this. takenImages, this. equipType,this.filename ,this.equipCode, this.equipName, this. Snpshot}) : super(key: key);
  final String? equipmentId;
  final String? storeId;
  final String? equipType;
  final String? equipCode;
  final String? equipName;
  final String?  Snpshot;
  final String? filename;
  final List<List<int>> takenImages;
  @override
  _DetectedImageForBeautyState createState() => _DetectedImageForBeautyState();
}

class _DetectedImageForBeautyState extends State<DetectedImageForBeauty> {
  int _selectedIndex = 0;
  bool _isVisible = true;
  int detectionPercent = 0;
  int? count;
  int? vmTableId;
  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }
  @override
  void initState() {
    super.initState();
    fetchDetectionPercentage ();
    checkGuidelineData ();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.equipCode.toString()}",
            style:  TextStyle(fontSize: 14,  color:Colors.white,),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => homeClass(stid:widget.storeId.toString(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),

          backgroundColor: Colors.black,
          elevation: 0.00,
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
                width: MediaQuery.of(context).size.width, // set width to screen width
                height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight - 48,
                child:Stack(
                  children: [
                    ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: widget.imagewidget.map((image) =>
                          InteractiveViewer(
                            scaleEnabled: true,
                            maxScale: 4.0, // Set the maximum scale factor
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: image.image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          )
                      ).toList(),
                    ),
                  ],
                )

            )
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels:true,
          backgroundColor: Colors.black87,
          unselectedItemColor: Colors.white,
          selectedItemColor: _selectedIndex == 2 ? Colors.green : Colors.yellowAccent,
          selectedLabelStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 10),
          unselectedLabelStyle: const TextStyle(color: Colors.white, fontSize: 10),
          items:  <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: Icon(Icons.article_outlined),
              label: 'Detail Report',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: const Icon(Icons.camera_alt_rounded),
              label: widget.equipName == 'BT2' || widget.equipName == 'BT1' || widget.equipName == '1' ? "Second Two Tray":
              widget.equipName == '2' ? "Third Two Tray":
              widget.equipName == '3' ? "Fourth Two Tray" :
              widget.equipName == '4' ? "Fifth Two Tray" :
              widget.equipName == '5' ? "Sixth Two Tray" :
              widget.equipName == '6' ? "Seventh Two Tray" :
              widget.equipName == '7' ? "Eighth Two Tray" :
              widget.equipName == '8' ? "Take Tester" :
              "Recapture"),



          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,

        ),

      );
    // );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add your code here to handle the item tap event for each item
    switch (index) {
      case 0:
        if(widget.equipType == 'Lipstick')
        {

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return DetailedReportForBeauty(
                    eqpt: widget.equipmentId, stid: widget.storeId);
              },
            ),
          );
        }
        // else {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (BuildContext context) {
        //         return FirstDetailedReport(
        //             eqpt: widget.equipmentId, stid: widget.storeId,equipType:widget.equipType);
        //       },
        //     ),
        //   );
        // }
        // code to execute when Report item is pressed
        break;
      case 1:
        print("count..from detectedimge.........${widget.equipName}");
       if(widget.equipName.toString() == 'BT1' || widget.equipName.toString() == 'BT2')
         {
           count = 2;
         }
       else if (int.parse(widget.equipName.toString()) <= 9){
         count = int.parse(widget.equipName.toString()) + 1 ;

       }
       else{
         // count = 1;
       }

        Navigator.of(context).pop();
        if(widget.equipName.toString() == 'BT1' || widget.equipName.toString() == 'BT2' || int.parse(widget.equipName.toString()) < 9) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                vmcamerahome.VMCaptureImage(
                  filename: widget.filename.toString(),
                  eqptId: widget.equipmentId.toString(),
                  eqptCode: widget.equipCode.toString(),
                  eqptName: count.toString(),
                  eqptNoOfSnaps: widget.Snpshot.toString(),
                  stid:widget.storeId.toString(),
                  eqptType: widget.equipType.toString(),
                  // storeId:widget.storeId.toString(),

                )),);
        }
        break;
      case 2:
        downloadAndShowVMGuideline(vmTableId,widget.equipmentId);
        break;

    }
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VMShowPDF(pdfPath: "${directory.path}/vm_guideline.pdf",sheet: VMId.toString(),tiger: EqptId)));
          print("${directory.path}/vm_guideline.pdf");
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _getScoreColor(int detectionPercent) {
    if (detectionPercent > 80) {
      return Colors.green;
    } else if (detectionPercent >= 50 && detectionPercent <= 80) {
      return Colors.yellow;
    } else {
      return Colors.red;
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
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

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
            icon: Icon(Icons.print),
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
                child: Container(
                  child: PdfView(path: widget.pdfPath),
                ),
              )
            else
              Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }
  /// VM PRINT PDF USING WIFI ///
  Future VMpdfprint(VMId,EqptId) async {
    print(VMId);
    print(EqptId);
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







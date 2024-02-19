import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'VMCameraHome.dart';




class CameraEquipmentDropdown extends StatefulWidget {
  const CameraEquipmentDropdown({Key? key, required this. stid, required this. StCode}) : super(key: key);
  final String stid;
  final String StCode;
  @override
  State<CameraEquipmentDropdown> createState() => _CameraEquipmentDropdownState();
}

class _CameraEquipmentDropdownState extends State<CameraEquipmentDropdown> {
  final TextEditingController _storeTypeAheadController = TextEditingController();
  Map<String, bool> _selectedEquipments = {}; // Initialize an empty map

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final List<String> _fetchedEquipmentData = [];
  List<String> codeValues = [];
  Map<String, Map<String, dynamic>> _fetchEquipmentData = {};
  List<Map<String, dynamic>> equipmentData = [];
  TextEditingController _typeAheadController = TextEditingController();



  bool _isLoading = true;
  bool buttonPressed = false;
  String? eqId;
  String? eqCode;
  int? vmId;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCheckBoxData();
    _selectedEquipments = { for (var item in _fetchedEquipmentData) item : false };
  }


  @override
  void didUpdateWidget(CameraEquipmentDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stid != widget.stid) {
       fetchCheckBoxData();
    }
  }

  // List<String> getFilteredEquipments() {
  //   if (_searchText.isEmpty) {
  //     return _fetchedEquipmentData;
  //   } else {
  //     return _fetchedEquipmentData
  //         .where((equipment) =>
  //         equipment.toLowerCase().contains(_searchText.toLowerCase()))
  //         .toList();
  //   }
  // }


  @override
  dispose() {
    super.dispose();
  }

  Future fetchData() async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      IOClient ioClient = IOClient(client);
      final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_trained_equipments'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          equipmentData = List<Map<String, dynamic>>.from(data);
        });
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          setState(() {
            codeValues = List<String>.from(responseData.map((item) => item["code"]));
            _isLoading = false;
          });

        } else {
          throw Exception('Empty response data');
        }
      } else {
        throw Exception('Failed to load equipment names');
      }
    } catch (error) {
      print('Error fetching equipment data: $error');
      return []; // Return an empty list in case of an error
    }
  }


  Future<void> fetchCheckBoxData() async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      IOClient ioClient = IOClient(client);
      final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_checkbox_tick_equipments_list/${widget.stid}'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        responseData.forEach((data) {
          String equipmentCode = data['code'];
          String captureAttempts = data['capture_attempts'];
          List<int> attempts = captureAttempts.split(',').map((value) => int.parse(value)).toList();
          // Set the checkboxes based on capture_attempts
          for (int attempt in attempts) {
            _selectedEquipments[equipmentCode + attempt.toString()] = true;
          }
        });
        setState(() {}); // Trigger UI update
      } else {
        throw Exception('Failed to load equipment names');
      }
    } catch (error) {
      print('Error fetching equipment data: $error');
    }
  }

  void onPressed() {
    setState(() {
      buttonPressed = true; // Set the button state to pressed
    });
    Vibration.vibrate(duration: 100);
    // Set a timer to revert the button state to not pressed after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        buttonPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: <Widget>[
          Container(
            height: 170,
            width:500,
            margin: const EdgeInsets.only(top: 50, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300], // Set the light rose background color
              borderRadius: BorderRadius.circular(20), // Set the border radius for curved corners
              border: Border.all(
                color: Colors.white, // Set the border color
                width: 2.0, // Set the border width
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Adjust alignment as needed
              children: [
                Container(
                  width: 300, // Set the desired width for the container
                  height: 70, // Set the desired height for the container
                  padding: const EdgeInsets.only(left: 12, right: 12,top: 8),
                 child:

                 TypeAheadField(
                   textFieldConfiguration:  TextFieldConfiguration(
                     decoration: InputDecoration(
                       labelText: 'Select Equipment',
                       filled: false,
                       enabledBorder: OutlineInputBorder(
                         borderSide:  const BorderSide(color: Colors.black, width: 1.0),
                         borderRadius: BorderRadius.circular(8.0),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                         borderRadius: BorderRadius.circular(8.0),
                       ),
                     ),

                   ),

                   suggestionsCallback: (pattern) {
                     return equipmentData.where((equipment) {
                       return equipment['code'].toLowerCase().contains(pattern.toLowerCase());
                     }).toList();
                   },
                   itemBuilder: (context, suggestion) {
                     return ListTile(
                       title: Text(suggestion['code']),
                     );
                   },
                   onSuggestionSelected: (suggestion) {
                     _typeAheadController.text = suggestion['code'];
                     // Access the ID corresponding to the selected code
                     int selectedId = suggestion['id'];
                     setState(() {
                       eqId = suggestion['id'].toString();
                       eqCode = suggestion['code'].toString();

                     });
                     checkGuidelineData ();
                     // print('Selected Code: ${suggestion['code']}, ID: $selectedId');
                     String filename = "${widget.StCode}-$eqCode";
                     //print("file........name............................$filename");
                     Navigator.of(context).push(
                       MaterialPageRoute(
                         builder: (BuildContext context) {
                           return VMCaptureImage(
                             filename: filename.toString(),
                             eqptId: eqId.toString(),
                             eqptCode: eqCode.toString(),
                             eqptName: eqCode.toString(),
                             eqptNoOfSnaps:suggestion['no_of_snaps_to_take'].toString(),
                             eqptType: suggestion['equip_type'].toString(),
                             stid : widget.stid,);
                         },
                       ),
                     );
                     },
                 ),
            ),


                const SizedBox(height: 10), // Add some spacing between the fields
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return VMQRView(stid: widget.stid.toString());
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300],
                    onPrimary: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),side: const BorderSide(color: Colors.black, width: 1.0),),
                    minimumSize: const Size(70, 45), //////// HERE
                  ),
                  child:const Text('                       QR Scanner                          '),
                )
              ],
            ),
          ),


          Expanded(
            child: Container(
              width: 500,
              margin: const EdgeInsets.only(top: 5, right: 10, left: 10),
              decoration: BoxDecoration(
                color: Colors.white, // Set the light rose background color
                borderRadius: BorderRadius.circular(20), // Set the border radius for curved corners
                border: Border.all(
                  color: Colors.white, // Set the border color
                  width: 2.0, // Set the border width
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Adjust alignment as needed
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Equipment',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                              //  _searchText = value;
                                _searchText = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            fetchCheckBoxData();
                            fetchData();
                          },
                          child:Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(
                              onTap: () {
                                fetchCheckBoxData();
                                fetchData();
                                onPressed();
                                },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: buttonPressed ? Colors.white : Colors.white,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Show the refresh icon
                                    if (!buttonPressed)
                                      const IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: null,
                                      ),
                                    // Show the circular progress indicator when button is pressed
                                    if (buttonPressed)
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        width: 50.0, // Set the desired width
                                        height: 50.0, // Set the desired height
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 3.0, // Adjust the thickness as needed
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  // Display progress indicator while loading
                  FittedBox(
                    child:DataTable(
                      columnSpacing: 60,
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Equipment')),
                        DataColumn(label: Text('11 AM',)),
                        DataColumn(label: Text('5 PM      ',)),

                      ], rows: const [],
                    ),
                  ),

                  _isLoading ? const Text("Loading...",style: TextStyle(color: Colors.black),)

                      : Expanded(
                        child: SingleChildScrollView(
                         scrollDirection: Axis.vertical,
                         child: CheckboxTheme(
                          data: CheckboxThemeData(
                            fillColor: MaterialStateColor.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.green; // Replace with your desired color
                              } else {
                                return Colors.grey.shade200; // Replace with your desired color for unchecked
                              }
                            }), // Color of the check icon
                            // ... other properties you might want to customize ...
                          ),

                          child: DataTable(
                            columnSpacing: 0,
                            headingRowHeight: 0,
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Equipment')),
                              DataColumn(label: Text('1')),
                              DataColumn(label: Text('2')),
                              DataColumn(label: Text('3')),
                              DataColumn(label: Text('4')),
                            ],
                            rows: codeValues
                                ?.where((code) => code.toLowerCase().contains(_searchText))
                                .map(
                                  (code) =>DataRow(
                                cells: [
                                  DataCell(Text(code)),
                                  for (int i = 1; i <= 4; i++)
                                    DataCell(
                                      Container(
                                        color: i <= 2 ? Colors.grey[200] : Colors.grey[300],
                                        child: Checkbox(
                                          value: _selectedEquipments[code + i.toString()] ?? false,
                                          onChanged: null,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )?.toList() ?? [],
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
  )
    );
  }





  Future<void> checkGuidelineData () async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;

    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/check_guideline_data/$eqId'));

    var guidelineData = json.decode(response.body);
    print( guidelineData);
    int? is_valid = guidelineData[0]['is_valid'];
    int? result = guidelineData[0]['result'];
    int? id = guidelineData[0]['id'];
    print("is_valid:$is_valid.......result:$result");

    if(result == 0)
      {
        setState(() {
          _showGuidelineError();
        });
      }

    else if(result == 1 && is_valid == 0){
      setState(() {
        vmId = id;
        _showGuidelineWarning();
      });
    }

  }
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<void> _showGuidelineError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red, // Change the color as needed
              ),
              SizedBox(width: 8), // Add some spacing between the icon and text
              Text('Error'),
            ],
          ),

          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('No guideline available for $eqCode'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go Back'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }



  Future<void> _showGuidelineWarning() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange, // Change the color as needed
                ),
                SizedBox(width: 8), // Add some spacing between the icon and text
                Text('Warning'),
              ],
            ),

          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Product details not available'),
                Text('for equipment $eqCode')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go Back'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('View Guideline'),
              onPressed: () {
                downloadAndShowVMGuideline(vmId,eqId);

              },
            ),
          ],
        );
      },
    );
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



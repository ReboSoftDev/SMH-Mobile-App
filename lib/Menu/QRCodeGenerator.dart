import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../HomeMenu.dart';

class MydropdownApp extends StatefulWidget {
  const MydropdownApp({super.key, required this.stid});
  final String stid;

  @override
  _MydropdownAppState createState() => _MydropdownAppState();
}

class _MydropdownAppState extends State<MydropdownApp> {
  static get value => null;
  bool _isLoading = false;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _selectedValues = [];
  List<String> _items = [];
  String? storecode;
  String? StoreCode;

  @override
  void initState() {
    super.initState();
    getWhichStore();
    fetchEquipmentIds().then((equipmentNames) {
      setState(() {
        _items = equipmentNames;
      });
    }).catchError((error) {
      print('Failed to fetch equipment names: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? EqptdropdownValue;
  String CompdropdownValue = value ?? "1";
  String? finaldropdownValue;
  String hyphen = "-";
  String? qrData;
  ImageProvider? qrImage;
  int? message;

  ///Fetching Equipments

  Future<List<String>> fetchEquipmentIds() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(
        Uri.parse('https://smh-app.trent-tata.com/flask/get_all_equipments'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> equipmentNames =
          data.map((dynamic item) => item['name'].toString()).toList();
      equipmentNames.sort();
      equipmentNames.insert(0, 'Select ALL');
      return equipmentNames;
    } else {
      throw Exception('Failed to load equipment IDs');
    }
  }

  ///QR CODE SAVE INTO DATABASE
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<void> qrSave() async {
    setState(() {
      _isLoading = true; // Show the loading overlay
    });

    for (String equipmentId in _selectedValues) {
      try {
        HttpClient client = HttpClient(context: await globalContext);
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
        IOClient ioClient = IOClient(client);
        final response = await ioClient.post(
            Uri.parse("https://smh-app.trent-tata.com/flask/generate_qrcode"),
            body: json.encode({
              "storecode": StoreCode!,
              "equipment_name": equipmentId!,
              "equipment_component": CompdropdownValue!
            }),
            headers: {
              "content-type": "application/json",
            });
        print('Response body: ${response.body}');
      } catch (e) {
        print(e.toString());
      }
    }
    setState(() {
      _isLoading = false; // Hide the loading overlay
    });
  }

  /// Deleting Folder
  Future<void> deleteFolder() async {
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/delete_folder"),
        body: json.encode({"folder_path": "qrcodes/uploads/$StoreCode"}),
        headers: {
          "content-type": "application/json",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("Folder deleted successfully");
      } else {
        print("Failed to delete folder");
      }
    } catch (e) {
      print("Error deleting folder: $e");
    }
  }

  Future<void> getWhichStore() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.stid.toString()}),
      headers: {
        "content-type": "application/json",
      },
    );
    var storeJson = json.decode(storeResponse.body);
    storecode = storeJson[0]['code'];
    if (storeJson[0]['code'] == null) {
      setState(() {
        StoreCode = '';
      });
    } else {
      setState(() {
        StoreCode = storecode!;
      });
    }
  }

  Future downloadAndShowQRPdf(StoreCode) async {
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/qr_saveall_pdf"),
          body: json.encode({
            "folder_path": "qrcodes/uploads/$StoreCode",
            "output_file_name": "$StoreCode.pdf",
            "store_id": StoreCode!,
          }),
          headers: {
            "content-type": "application/json",
            "accept": "application/pdf",
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        new Directory('${appDocDirectory.path}/dir')
            .create(recursive: true)
            .then((Directory directory) async {
          final file = File("${directory.path}/$StoreCode.pdf");
          await file.writeAsBytes(response.bodyBytes);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QRShowPDF(
                      QRpdfPath: "${directory.path}/$StoreCode.pdf",
                      QRsheet: StoreCode)));

        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  final TextEditingController _storetypeAheadController =
      TextEditingController();
  final TextEditingController _eqpttypeAheadController =
      TextEditingController();
  final TextEditingController _comptypeAheadController =
      TextEditingController();
  SuggestionsBoxController storesuggestionBoxController =
      SuggestionsBoxController();
  SuggestionsBoxController eqptsuggestionBoxController =
      SuggestionsBoxController();
  SuggestionsBoxController compsuggestionBoxController =
      SuggestionsBoxController();

  /// class
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(
            title: const Text('QR Code Generation',
                style: TextStyle(fontSize: 16)),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios)),
            backgroundColor: Colors.black,
            elevation: 0.00,
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Container(
                  // Add zero opacity to make the gesture detector work
                  color: Colors.amber.withOpacity(0),
                  // Create the form for the user to enter their favorite city
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 30, bottom: 20, right: 30, top: 10),
                      // padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.center,
                            child: StoreCode == null
                                ? const Text(
                                    '',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    StoreCode!,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                          MultiSelectDialogField<String>(
                            title: Text('Equipment IDs'),
                            items: _items.map((name) => MultiSelectItem<String>(name, name)).toList(),
                            initialValue: _selectedValues,
                            selectedColor: Colors.blue,
                            selectedItemsTextStyle:
                                const TextStyle(color: Colors.white),
                            buttonIcon: const Icon(Icons.arrow_drop_down),
                            buttonText: Text('Select Equipment IDs'),
                            listType: MultiSelectListType.CHIP,
                            searchable: true, // Enable search functionality
                            onConfirm: (values) {
                              setState(() {
                                if (values.contains('Select ALL')) {
                                  if (_selectedValues.contains('Select ALL')) {
                                    _selectedValues = [];
                                  } else {
                                    _selectedValues = List.from(_items)
                                      ..remove('Select ALL');
                                  }
                                } else {
                                  if (values.length == _items.length) {
                                    _selectedValues = ['Select ALL'];
                                  } else {
                                    _selectedValues = List.from(values);
                                    if (_selectedValues.length ==
                                        _items.length) {
                                      _selectedValues.add('Select ALL');
                                    } else {
                                      _selectedValues.remove('Select ALL');
                                    }
                                  }
                                }
                                print(_selectedValues);
                              });
                            },
                          ),
                          if (qrImage != null)
                            Image(
                              image: qrImage!,
                              height: 200,
                              width: 200,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                LoadingOverlay(color: Colors.amber),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    await deleteFolder();
                    await qrSave();
                    await downloadAndShowQRPdf(StoreCode);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.qr_code_outlined, color: Colors.black),
                      Text('Generate QR', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class QRShowPDF extends StatefulWidget {
  // In the constructor, require a Todo.
  const QRShowPDF({Key? key, required this.QRpdfPath, required this.QRsheet})
      : super(key: key);
  // Step 2 <-- SEE HERE
  final String QRpdfPath;
  final String QRsheet;
  @override
  State<QRShowPDF> createState() => _QRShowPDFState();
}

class _QRShowPDFState extends State<QRShowPDF> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR PDF', style: TextStyle(fontSize: 16)),
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
              QRpdfprint(widget.QRsheet);
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
            if (widget.QRpdfPath != null)
              Expanded(
                child: Container(
                  child: PdfView(path: widget.QRpdfPath),
                ),
              )
            else
              const Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }
}

Future QRpdfprint(String StoreCode) async {
  try {
    print("Calling...Print....");
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient
        .post(Uri.parse("https://smh-app.trent-tata.com/flask/qr_saveall_pdf"),
            body: json.encode({
              "folder_path": "qrcodes/uploads/$StoreCode",
              "output_file_name": "$StoreCode.pdf",
              "store_id": StoreCode!,
            }),
            headers: {
          "content-type": "application/json",
          "accept": "application/pdf",
        });
    print(response.statusCode);

    const pdfPageFormat = PdfPageFormat(8.5 * PdfPageFormat.inch, 11 * PdfPageFormat.inch);
    await Printing.layoutPdf(
      onLayout: (_) => response.bodyBytes,
      format: pdfPageFormat,
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

class LoadingOverlay extends StatelessWidget {
  final Color color;

  LoadingOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}



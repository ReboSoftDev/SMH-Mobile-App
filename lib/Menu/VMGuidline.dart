import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import '../model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';





class VMGuideline extends StatefulWidget {
  const VMGuideline({Key? key, required this. stid}) : super(key: key);
   final String stid;
  @override
  State<VMGuideline> createState() => _VMGuidelineState();
}

class _VMGuidelineState extends State<VMGuideline> {

  final _formKey = GlobalKey<FormState>();
  String? dropdownValue;
  String? dropdown_id;
  int? dropdownid;
  String? VM_Id;
  String? Eqpt_Id;
  String? GDId;
  String? CategoryId;
  List<String> menuItems = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Future<List<String>> fetchDataFromApi() async {

    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/categorySelect'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Extract the menu item strings from your API response
      final List<String> menuItems = data.map((item) {
        return item['category_name'] as String;
      }).toList();
      return menuItems;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromApi().then((items) {
      setState(() {
        dropdown_id = '1';
        menuItems = items;
        dropdownValue = menuItems.isNotEmpty ? menuItems[0] : null; // Set the default value
      });
    });

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

        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios,color: Colors.black,)),
            backgroundColor: Colors.white,
            elevation: 0.00,
            toolbarHeight: 60,


        title: Container(
            width: 180,
            height: 35,
            margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 0),
            // Add padding to style the box

            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Equipment',
                labelStyle: const TextStyle(fontSize: 13.0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
        ),



        actions: [
          Container(
              width: 150,
              height: 35,
              margin: const EdgeInsets.only(top: 15,left:0,right: 5,bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10), // Add padding to style the box
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(), // Remove the default underline
                hint: const Text('Category', style: TextStyle(color: Colors.black45, fontSize: 13,),
                  textAlign: TextAlign.center,
                ),
                value: dropdownValue,
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue.toString();
                  });
                  dropdownid = menuItems.indexOf(newValue.toString());
                  dropdownid = dropdownid! + 1;
                  dropdown_id = dropdownid.toString();
                },
                items: menuItems.map<DropdownMenuItem<String>>(
                      (value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ).toList(),
              )
          ),

          Container(
            margin: const EdgeInsets.only(top: 15,left:0,right: 5,bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),side: const BorderSide(color: Colors.black, width: 1.0),),
                minimumSize: const Size(120, 35), //////// HERE
              ),
              onPressed: () {
                downloadAndShowAllGuideline(dropdownValue);
              },
              child: const Text('Print All Guideline',style: TextStyle(fontSize: 11),),

            ),

          ),
          Container(
            margin: const EdgeInsets.only(top: 15,left:0,right: 5,bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),side: const BorderSide(color: Colors.black, width: 1.0),),
                minimumSize: const Size(130, 35), //////// HERE
              ),
              onPressed: () {
                downloadAndShowAllGuideline(dropdownValue);
              },
              child: const Text('Print Category Guideline',style: TextStyle(fontSize: 11),),

            ),

          )


        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

              //////////////////general guidline with category /////////////////
              /////////////////////////////////////////////////////////////////
              /////////////////////////////////////////////////////////////////


            FutureBuilder<List<GeneralGuidelineMenu>>(
              initialData: const <GeneralGuidelineMenu>[],
              future: fetchGeneralGuideline(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center( child:Container(
                    padding: const EdgeInsets.only(top: 10),
                      child:const CircularProgressIndicator(color: Colors.black,)))
                  ;
                }

                return SizedBox(
                  width: double.infinity,
                  child: DataTable(

                    headingRowColor:
                    MaterialStateColor.resolveWith((states) =>
                    Colors.grey.shade200),
                    headingRowHeight: 40,
                    columns: const [
                      DataColumn(
                          label: Text('Guideline Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('             Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Created By',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black))),
                      DataColumn(
                          label: Text('Print',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black))),
                    ],
                    rows: List.generate(
                      snapshot.data!.length,
                          (index) {
                        var data = snapshot.data![index];
                        return DataRow(

                            color: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Theme.of(context)
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
                                    onTap:  () async => {
                                      GDId = data.id.toString(),
                                      CategoryId = dropdown_id,
                                      downloadAndShowGMGuideline(GDId,CategoryId),



                                    },
                                  child: Container(
                                   width: data.GDguidelineName.toString() == 'BEAUTY' ? 110.0 : 80.0,
                                   alignment: Alignment.centerLeft,
                                   child: Text(
                                   data.GDguidelineName.toString(),
                                   textAlign: TextAlign.left,
                                   style: const TextStyle(fontSize: 14),
                                  ),
                                  )
                                )
                                  //



                               ),
                              DataCell(GestureDetector(
                                onTap:  () async => {
                                  GDId = data.id.toString(),
                                  CategoryId = dropdown_id,
                                  downloadAndShowGMGuideline(GDId,CategoryId),

                                },

                                child: Text(
                                  data.GDdate.toString().substring(0, 16),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )),
                              DataCell(GestureDetector(
                                onTap:  () async => {
                                  GDId = data.id.toString(),
                                  CategoryId = dropdown_id,
                                  downloadAndShowGMGuideline(GDId,CategoryId)

                                },
                                // width: 130,
                                // alignment: Alignment.centerLeft,
                                child: Text(
                                  data.GDcreatedBy.toString(),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )),
                              DataCell(GestureDetector(
                                onTap:  () async => {
                                  GDId = data.id.toString(),
                                  CategoryId = dropdown_id,
                                  downloadAndShowGMGuideline(GDId,CategoryId),


                                },
                                child: const Icon(Icons.print, color: Colors.black,),

                              )),
                            ]);
                      },
                    ).toList(),
                  ),
                );
              },
            ),


            //////////////////vm guidline with equipment /////////////////
            /////////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////////


            FutureBuilder<List<VMGuidelineMenu>>(
              initialData: const <VMGuidelineMenu>[],
              future: fetchVMGuideline(dropdown_id),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.connectionState == ConnectionState.waiting) {

                  return Container(
                    margin:  const EdgeInsets.only(top: 5,left:0,right: 0,bottom: 0),
                      child:const Text("Loading",style: TextStyle(fontSize: 10),)
                  );

                }

               return SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowHeight: 0,
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.purpleAccent.shade100),
                    columns: const [
                      DataColumn(
                        label: Text('Guideline Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('Created By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('Print', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      ),
                    ],
                    rows: snapshot.data!
                        .where((data) => data.guidelineName?.toLowerCase().contains(_searchText) ?? false)
                        .map<DataRow>(
                          (data) {
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                              }
                              if (snapshot.data!.indexOf(data) % 2 == 0) {
                                return Colors.white;
                              }
                              return Colors.white.withOpacity(0.2);
                            },
                          ),
                          cells: [
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  VM_Id = data.id.toString();
                                  Eqpt_Id = data.eqpt_id.toString();
                                  downloadAndShowVMGuideline(VM_Id, Eqpt_Id);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data.guidelineName.toString(),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  VM_Id = data.id.toString();
                                  Eqpt_Id = data.eqpt_id.toString();
                                  downloadAndShowVMGuideline(VM_Id, Eqpt_Id);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data.date.toString().substring(0, 16),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  VM_Id = data.id.toString();
                                  Eqpt_Id = data.eqpt_id.toString();
                                  downloadAndShowVMGuideline(VM_Id, Eqpt_Id);
                                },
                                child: SizedBox(
                                  width: 60,
                                  child: Text(
                                    data.createdBy.toString(),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  VM_Id = data.id.toString();
                                  Eqpt_Id = data.eqpt_id.toString();
                                  downloadAndShowVMGuideline(VM_Id, Eqpt_Id);
                                },
                                child: const Icon(Icons.print, color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                );
                },
            ),
          ],
        ),
      ),
    );
  }

/// General guideline List //////////////////////////
  Future<List<GeneralGuidelineMenu>> fetchGeneralGuideline() async {
    //print(dropdown_id);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/get_category_with_general_guidline/$dropdown_id');
    var response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    //print(resultsJson);
    List<GeneralGuidelineMenu> emplist = await resultsJson
        .map<GeneralGuidelineMenu>((json) => GeneralGuidelineMenu.fromJson(json))
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

 /// Vm Guideline List ///////////////////////////////

  Future<List<VMGuidelineMenu>> fetchVMGuideline(dropdownId) async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_all_vm_guideline_with_equipment_name/"+dropdownId!);
    var response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<VMGuidelineMenu> emplist = await resultsJson
      .map<VMGuidelineMenu>((json) => VMGuidelineMenu.fromJson(json))
      .toList();
  return emplist;
  }


/// print ALL API ///
  Future downloadAndShowAllGuideline(dropdownName) async {
    try {
      print("Calling...PrintALL");
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/merging_all_guideline"),
          body: json.encode({"category":dropdownValue}),
          headers: {
            "content-type": "application/json",
            "accept": "application/pdf",
          });
      //print(response.statusCode);
      if (response.statusCode == 200) {
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        Directory('${appDocDirectory.path}/dir')
            .create(recursive: true)
            .then((Directory directory) async {
          final file = File("${directory.path}/all_guideline.pdf");
          await file.writeAsBytes(response.bodyBytes);
          // ignore: use_build_context_synchronously
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ALLShowPDF(pdfPath: "${directory.path}/all_guideline.pdf",dpname:dropdownName)));
            });
      }
    } catch (e) {
      print(e.toString());
    }
  }





/// VM GUIDLINE  PDF API /////

  Future downloadAndShowVMGuideline(VMId,EqptId) async {
    //print(VMId);
    //print(EqptId);
    try {
      //print("Calling...VM...");
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
      //print(response.statusCode);

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
              context, MaterialPageRoute(builder: (context) => VMShowPDF(pdfPath: "${directory.path}/vm_guideline.pdf",sheet: VMId,tiger: EqptId)));
          print("${directory.path}/vm_guideline.pdf");
        });
      }
      else{
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(child:Text("FAILED")),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print(e.toString());
    }
  }



  ///General Guidline PDF API
  Future downloadAndShowGMGuideline(GDId,CategoryId) async {
    try {
      print("Calling...GD...");
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_gmguideline_image_preview"),
          body: json.encode({"table_id":GDId, "category_id":CategoryId}),
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
          final file = File("${directory.path}/gm_guideline.pdf");
          await file.writeAsBytes(response.bodyBytes);
          // ignore: use_build_context_synchronously
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => GDShowPDF(GDpdfPath: "${directory.path}/gm_guideline.pdf",GDsheet: GDId,GDtiger: CategoryId)));
          //print("${directory.path}/gm_guideline.pdf");
        });
      }
      else{
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(child:Text("FAILED")),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
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



///General Guidline PDF SHOWING
class GDShowPDF extends StatefulWidget {


  // In the constructor, require a Todo.
  const GDShowPDF({Key? key, required this.GDpdfPath,required this.GDsheet,required this.GDtiger,}) : super(key: key);
  // Step 2 <-- SEE HERE
   final String GDpdfPath;
   final String GDsheet;
   final String GDtiger;

  @override
  State<GDShowPDF> createState() => _GDShowPDFState();
}

class _GDShowPDFState extends State<GDShowPDF> {
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
              GDpdfprint(widget.GDsheet,widget.GDtiger);
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
            if (widget.GDpdfPath != null)
              Expanded(
                child: Container(
                  child: PdfView(path: widget.GDpdfPath),
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

/// General Guidline Printing...wifi..

Future GDpdfprint(GDId,CategoryId) async {

  try {
    print("Calling...Print....");
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/get_gmguideline_image_preview"),
        body: json.encode({"table_id":GDId, "category_id":CategoryId}),
        headers: {
          "content-type": "application/json",
          "accept": "application/pdf",
        });
    print(response.statusCode);

    await Printing.layoutPdf(
      onLayout: (_) => response.bodyBytes,

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







///GD AND VM ALL PDF PREVIEW

class ALLShowPDF extends StatefulWidget {

  // In the constructor, require a Todo.
  const ALLShowPDF({Key? key, required this.pdfPath,required this.dpname}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String pdfPath;
  final String dpname;


  @override
  State<ALLShowPDF> createState() => _ALLShowPDFState();
}


class _ALLShowPDFState extends State<ALLShowPDF> {

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
              ALLpdfPrint(widget.dpname);

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
              const Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }

}
///PRINT ALL PDF USING WIFI
Future ALLpdfPrint(dropdownvalue) async {
  try {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/merging_all_guideline"),
        body: json.encode({"category":dropdownvalue}),
        headers: {
          "content-type": "application/json",
          "accept": "application/pdf",
        });
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

    print(response.statusCode);

  } catch (e) {
    print(e.toString());
  }
}


/// VM GUIDLINE  PDF API CATEGORY WISE /////

Future downloadAndShowVMGuidelineCategoryWise(BuildContext context) async {

  try {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/merge_pdfs_categories"),
        body: json.encode({"folder_path":"PRINT-ALL"}),
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
        final file = File("${directory.path}/vm_guideline_Category_wise.pdf");
        await file.writeAsBytes(response.bodyBytes);

        // await Printing.layoutPdf(onLayout: (_) => response.bodyBytes);

        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => VMCategoryWisePDF(pdfPath: "${directory.path}/vm_guideline_Category_wise.pdf")));
        print("${directory.path}/vm_guideline_Category_wise.pdf");
      });
    }
  } catch (e) {
    print(e.toString());
  }
}


///GD AND VM ALL PDF PREVIEW

class VMCategoryWisePDF extends StatefulWidget {

  // In the constructor, require a Todo.
  const VMCategoryWisePDF({Key? key, required this.pdfPath}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String pdfPath;

  @override
  State<VMCategoryWisePDF> createState() => VMCategoryWisePDFState();
}


class VMCategoryWisePDFState extends State<VMCategoryWisePDF> {

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
              VMGuidelineCategoryWisePrint();

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
              const Text("Pdf is not Loaded"),
          ],
        ),
      ),
    );
  }

}

///PRINT ALL PDF USING WIFI
Future VMGuidelineCategoryWisePrint() async {
  try {

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
        Uri.parse("https://smh-app.trent-tata.com/flask/merge_pdfs_categories"),
        body: json.encode({}),
        headers: {
          "content-type": "application/json",
          "accept": "application/pdf",
        });
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

    print(response.statusCode);

  } catch (e) {
    print(e.toString());
  }
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
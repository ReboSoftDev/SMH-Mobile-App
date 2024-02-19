import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:vibration/vibration.dart';
import '../../CompliancePopUpImage.dart';
import '../../VMProductImage.dart';
import '../../model.dart';


class ProductWiseSeniormanager extends StatefulWidget {
  const ProductWiseSeniormanager({Key? key, this.date, this.storeId, this.equipId, required this. time, this. detected_id,  }) : super(key: key);
  final String? date;
  final String? storeId;
  final String? equipId;
  final String? time;
  final int? detected_id;
  @override
  State<ProductWiseSeniormanager> createState() => _HomePageState();
}

class _HomePageState extends State<ProductWiseSeniormanager> {

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Scaffold with appbar ans body.
        appBar: AppBar(
          title: const Text("VM Compliance - Senior Manager",style:TextStyle(fontSize: 16)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          backgroundColor: Colors.black,
          elevation: 0.00,
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child:Column(
              children: [
                FutureBuilder<List<CityManagerProductWise>>(
                  initialData: const <CityManagerProductWise>[],
                  future:fetchResults(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    }
                    return FittedBox(
                        fit: BoxFit.scaleDown,

                        child: DataTable(
                          dataRowHeight: 70,
                          headingRowHeight: 70,
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) =>
                          Colors.black45),
                          columns: const [
                            DataColumn(label: Center(child:Text('Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Size Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
                            DataColumn(label: Center(child:Text('Signage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)))),
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
                                        child:Center(
                                          child: Image.memory(base64Decode(data.fileContents.toString()),width: 50,),
                                        ),
                                        onTap: () {
                                          String imageData = data.imageContent.toString();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                            ),
                                          );

                                        },
                                      ),
                                    ),
                                    DataCell(
                                      GestureDetector(
                                        child:Center(child: Text(data.productcode.toString(), textAlign: TextAlign.left, style: const TextStyle(fontSize: 20),),),
                                        onTap: () {
                                          String imageData = data.imageContent.toString();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                            ),
                                          );

                                        },
                                      ),
                                    ),
                                    DataCell(
                                        GestureDetector(
                                          child:Center( child: data.color.toString() == "0" ?
                                          const Icon(Icons.close, color: Colors.red,size: 30,):
                                          const Icon(Icons.check, color: Colors.green,size:30,),),
                                          onTap: () async{
                                            String imageData = data.imageContent.toString();
                                            if (await Vibration.hasVibrator() ?? false) {
                                              Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                            }
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                              ),
                                            );

                                          },
                                        )
                                    ),
                                    DataCell(
                                        GestureDetector(
                                          child:Center( child: data.sizeratio.toString() == "0" ?
                                          const Icon(Icons.close, color: Colors.red,size: 30,):
                                          const Icon(Icons.check, color: Colors.green,size: 30,),),
                                          onTap: () async{
                                            String imageData = data.imageContent.toString();
                                            if (await Vibration.hasVibrator() ?? false) {
                                              Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                            }
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                              ),
                                            );

                                          },
                                        )
                                    ),
                                    DataCell(
                                        GestureDetector(
                                          child:Center( child: data.product.toString() == "0" ?
                                          const Icon(Icons.close, color: Colors.red,size: 30,):
                                          const Icon(Icons.check, color: Colors.green,size: 30,),),
                                          onTap: () async{
                                            String imageData = data.imageContent.toString();
                                            if (await Vibration.hasVibrator() ?? false) {
                                              Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                            }
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                              ),
                                            );

                                          },
                                        )
                                    ),
                                    DataCell(
                                        GestureDetector(
                                          child:Center(  child: data.quantity.toString() == "0" ?
                                          const Icon(Icons.close, color: Colors.red,size: 30,):
                                          const Icon(Icons.check, color: Colors.green,size: 30,),),
                                          onTap: () async{
                                            String imageData = data.imageContent.toString();
                                            if (await Vibration.hasVibrator() ?? false) {
                                            Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                            }
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                              ),
                                            );

                                          },
                                        )
                                    ),
                                    DataCell(
                                        GestureDetector(
                                          child:Center(child: data.signage.toString() == "0" ?
                                          const Icon(Icons.close, color: Colors.red,size: 30,):
                                          const Icon(Icons.check, color: Colors.green,size: 30,),),
                                          onTap: () async{
                                              String imageData = data.imageContent.toString();
                                              if (await Vibration.hasVibrator() ?? false) {
                                            Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
                                            }
                                              // ignore: use_build_context_synchronously
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CompliancePopUpImage(imageData: imageData,eqid: widget.equipId.toString()),
                                                ),
                                              );

                                          },
                                        )
                                    ),
                                  ]);
                            },
                          ).toList(),

                        )
                    );
                  },
                ),
              ],
            )
        ),

    );
  }


  Future<List<CityManagerProductWise>> fetchResults() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_citymanager_productwise/${widget.detected_id}/${widget.storeId}/${widget.equipId}");
    var response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<CityManagerProductWise> emplist = await resultsJson
        .map<CityManagerProductWise>((json) => CityManagerProductWise.fromJson(json))
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





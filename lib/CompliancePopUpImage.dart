import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart';


class CompliancePopUpImage extends StatefulWidget {
  const CompliancePopUpImage({Key? key, required this.imageData, required this.eqid, }) : super(key: key);

  final String imageData;
  final String eqid;

  @override
  State<CompliancePopUpImage> createState() => _CompliancePopUpImageState();
}

class _CompliancePopUpImageState extends State<CompliancePopUpImage> {

  List<Image> _images = [];
  String? store;
  String? equipment;
  bool _isLoading = false;
  String? imageUrl;
  String? equiptype;

  @override
  void initState() {
    // BackButtonInterceptor.add(myInterceptor);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _fetchAndDisplayImages();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }



  Future<Uint8List> _fetchAndDisplayImages() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_equipType/${widget.eqid}");
    var responseget = await ioClient.get(urlget);
    var equipmentResponse = jsonDecode(responseget.body);
    String equipType = equipmentResponse[0]['equip_type'];

    if (equipType == 'Table' || equipType == 'Wall') { // Check equipType
      final response = await ioClient.post(
        Uri.parse('https://smh-app.trent-tata.com/flask/get_detected_image'),
        body: {"image_file_name": widget.imageData},
      );

      if (response.statusCode == 200) {
        final compressedImage = await FlutterImageCompress.compressWithList(
          response.bodyBytes,
          quality: 100, // Adjust the quality as needed
          rotate: 0, // Adjust the rotation as needed
        );
        return Uint8List.fromList(compressedImage);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("FAILED"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ));
      }
    } else {
      String originalString = widget.imageData.toString();
      String modifiedString = '${originalString.substring(0, originalString.lastIndexOf('.'))}.zip';
      final response = await ioClient.post(
        Uri.parse('https://smh-app.trent-tata.com/flask/get_detected_zip_file'),
        body: {"zip_file_name": modifiedString},
      );

      if (response.statusCode == 200) {
        final compressedImage = await FlutterImageCompress.compressWithList(
          response.bodyBytes,
          quality: 100,
          rotate: -90,// Adjust the quality as needed
           // Adjust the rotation as needed
        );
        return Uint8List.fromList(compressedImage);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("FAILED"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ));
      }

    }

    // Return an empty Uint8List when there's an issue
    return Uint8List(0);
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("VM Compliance", style: TextStyle(fontSize: 16)),
      //   automaticallyImplyLeading: false,
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //     icon: const Icon(Icons.arrow_back_ios),
      //   ),
      //   backgroundColor: Colors.black,
      //   elevation: 0.00,
      // ),
      body: FutureBuilder<Uint8List>(
        future:_fetchAndDisplayImages(),
        // Your function to fetch and compress the image
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Image not available"));
          } else {
            return
            InteractiveViewer(maxScale: 4.0,
              panEnabled: true,child:
              Image.memory(
              snapshot.data!,
              fit: BoxFit.fill, // Adjust the fit as needed
              width: MediaQuery.of(context).size.width, // Set the image width
              height: MediaQuery.of(context).size.height, // Set the image height
            ),
            );
          }
        },
      ),
    );
  }
}





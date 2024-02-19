import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'CameraLandscape.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'VMCamera.dart';



class VMQRView extends StatefulWidget {
  const VMQRView({Key? key,  this. stid}) : super(key: key);
  final String? stid;
  @override
  State<StatefulWidget> createState() => _VMQRViewState();
}

class _VMQRViewState extends State<VMQRView> {
  @override
  void initState() {
     // BeautyStatusUtil.checkBeautyStatus(context);
    super.initState();

  }


  Barcode? result;
  late QRViewController qrcontroller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrcontroller.pauseCamera();
    }
    qrcontroller.resumeCamera();
    // if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 2, child: _buildQrView(context)),
        ],
      ),
    );
  }


  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 80 / 100;
    return QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.black,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      );
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
  void _onQRViewCreated(QRViewController qrcontroller) {
    setState(() {
      this.qrcontroller = qrcontroller;
    });
       qrcontroller.scannedDataStream.listen((scanData) async {
       qrcontroller.dispose();

      var code  = scanData.code.toString().substring(5, scanData.code.toString().length - 2);
      try {
        HttpClient client = HttpClient(context: await globalContext);
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
        IOClient ioClient = IOClient(client);
        var equpments = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/get_scanned_equipments/$code'));
        var response = jsonDecode(equpments.body);
       //   const apiUrl = 'https://smh-app.trent-tata.com/flask/eqprefimages/27';
       //  final responseOverlayImage = await ioClient.get(Uri.parse(apiUrl));
       //  final Map<String, dynamic> data = json.decode(response.body);
       // String imageUrl = data['image'];

        int eqptId = response[0]['id'];
        String eqptCode = response[0]['code'];
        String eqptName = response[0]['name'];
        String eqptType = response[0]['equip_type'];
        int eqptNoOfSnaps = response[0]['no_of_snaps_to_take'];

        // var EQUIPMENTSfromDB = json.decode(equpments.body);
        // var EQUIPMENTfromDB = (EQUIPMENTSfromDB as List).firstWhere((eqp) => code == eqp["code"]);
        // var eqptId = EQUIPMENTfromDB["id"].toString();
        // var eqptCode = EQUIPMENTfromDB["code"].toString();
        // var eqptName = EQUIPMENTfromDB["name"].toString();
        // var eqptNoOfSnaps = EQUIPMENTfromDB["no_of_snaps_to_take"].toString();


        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VMCaptureImage(
            filename: scanData.code.toString(),
            eqptId: eqptId.toString(),
            eqptCode: eqptCode.toString(),
            eqptName: eqptName,
            eqptType: eqptType.toString(),
            eqptNoOfSnaps: eqptNoOfSnaps.toString(),
            stid: widget.stid.toString(),
            //overlayImage:imageUrl ,
            // storeId:widget.stid.toString(),
          )),
        );
        setState(() {
          qrcontroller.stopCamera();
        });
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    });
       qrcontroller.pauseCamera();
       qrcontroller.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
     qrcontroller.dispose();
     qrcontroller.stopCamera();
    super.dispose();
  }
}



// class VMCaptureImage extends StatelessWidget {
//   final String filename;
//   final String eqptId;
//   final String eqptCode;
//   final String eqptName;
//   final String eqptNoOfSnaps;
//   final String eqptType;
//   // final String storeId;
//   const VMCaptureImage({Key? key, this.filename = "0", this.eqptId = "0", this.eqptCode = "0", this.eqptName = "0", this.eqptNoOfSnaps = "0", this. eqptType = "0",});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: VMcamera(key: key, filename: filename, eqptId: eqptId, eqptCode: eqptCode, eqptName: eqptName, eqptNoOfSnaps: eqptNoOfSnaps,eqptType : eqptType),
//       ),
//     );
//   }
// }
class VMCaptureImage extends StatelessWidget {
  final String filename;
  final String eqptId;
  final String eqptCode;
  final String eqptName;
  final String eqptNoOfSnaps;
  final String eqptType;
  final String stid;


  const VMCaptureImage({Key? key, this.filename = "0", this.eqptId = "0", this.eqptCode = "0", this.eqptName = "0", this.eqptNoOfSnaps = "0", required this.eqptType, required this. stid,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cameraView;

    if (eqptType.toString() == '') {
      cameraView = VMcamera(
        filename: filename,
        eqptId: eqptId,
        eqptCode: eqptCode,
        eqptName: eqptName,
        eqptNoOfSnaps: eqptNoOfSnaps,
        eqptType: eqptType,
        stId : stid,
      );
    }
    else {
      cameraView = VMcameraLandscape(
        filename: filename,
        eqptId: eqptId,
        eqptCode: eqptCode,
        eqptName: eqptName,
        eqptNoOfSnaps: eqptNoOfSnaps,
        eqptType: eqptType,
        stId : stid,
      );

    }

    return Scaffold(
      body: Center(
        child: cameraView,
      ),
    );
  }
}














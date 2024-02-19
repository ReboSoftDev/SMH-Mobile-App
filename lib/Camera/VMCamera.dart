import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import '../Detection/DetectedImageForBeauty.dart';
import '../Detection/DetectedImageGrid.dart';
import 'package:sample/Camera/VMCameraHome.dart' as vmcamerahome;
import 'package:archive/archive.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../Detection/DetectedImage.dart';



List<CameraDescription>? cameras;

class VMcamera extends StatefulWidget {
  final String filename;
  final String eqptId;
  final String eqptCode;
  final String eqptName;
  final String eqptNoOfSnaps;
  final String eqptType;
  final String stId;
  // final String storeId;
  const VMcamera({Key? key,  required this.filename, required this.stId, required this.eqptId, required this.eqptCode, required this.eqptName, required this.eqptNoOfSnaps, required this. eqptType,
  }) : super(key: key);
  @override
  _VMcameraState createState() => _VMcameraState();
}

class _VMcameraState extends State<VMcamera> {


  /// hide top and bottom navigator bars
  bool _hideBars = false;
  DateTime currentDate = DateTime.now();
  int? aTTempt;
  int? Attempt;
  String? whichAttempt;
  bool _isGate = false;
  String? beautyLabel;
  int? beautyCount;
  int beautyStatus = 1;
  int? preferenceBeautyCount;

  void _toggleBarsVisibility() {
    setState(() {
      _hideBars = !_hideBars;
    });
  }
  bool _isLoading = false;
  List<CameraDescription>? cameras;
  CameraController? controller;
  String imagePath = "";
  String? store_id;
  String? equipType;
  int no_of_takenphotos = 1;
  List<XFile> takenimages = [];
  List<List<int>> resizedImagesBytesList = [];
  File? imageFile;
  int captureAttempt = 0;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    WidgetsFlutterBinding.ensureInitialized();

    try {
      availableCameras()
          .then((availableCameras) => cameras = availableCameras)
          .then((cameras) async {
        ResolutionPreset resolutionPreset = ResolutionPreset.high;
        if (widget.eqptCode.toString() == 'BT1' || widget.eqptCode.toString() == 'BT2') {
          resolutionPreset = ResolutionPreset.ultraHigh;
        }

        controller = CameraController(cameras[0], resolutionPreset, enableAudio: false);

        if (controller != null) {
          await controller!.initialize().then((_) {
            if (!mounted) {
              return;
            }
            controller!.setFlashMode(FlashMode.off);
            controller!.setFocusMode(
                FocusMode.auto); // <-- set focus mode to fixed
            setState(() {});
          });
        }
      });
    } catch (error) {
      print('error taking picture ${error.toString()}');
    }
  }


  @override
  void dispose() {
    controller!.stopImageStream();
    controller!.dispose();
    super.dispose();

  }

  ///global context
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

 ///send image to backend detection
  ///showTableCompliance
  Future<void> _showTableCompliance() async {
    setState(() {
      equipType = 'Table';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showTableCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate: 270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      print('Resized image bytes (index $index): ${resizedImage!.toList()}');
      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        resizedImage!,
        filename: fileName,

      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }


    var response = await ioClient.send(request).timeout(const Duration(seconds: 180));
    if (response.statusCode != 200 && response.statusCode != 404) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else if (response.statusCode == 404) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("PLEASE RECAPTURE"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else {
      setState(() {
        _isLoading = false;
      });
       insertAttemptIntoDetectedTable (Storeid);
    }
    // Process the response data, e.g. display it in a new screen
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetectedImage2(
              imageWidgets: imageWidgets,
              equipmentId: widget.eqptId,
              storeId: Storeid.toString(),
              takenImages: resizedImagesBytesList,
              equipType: equipType,
              filename: widget.filename,
              equipCode: widget.eqptCode,
              equipName: widget.eqptName,
              Snpshot: widget.eqptNoOfSnaps,
            ),
      ),
    );
  }




    ///showMensShortsCompliance
  Future<void> _showMensShortsCompliance() async {
    setState(() {
      equipType = 'MensShorts';
      _isLoading = true;
    });

    String storecode = widget.filename.split("-").first;
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMensShortsCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {

      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);
      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }


    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });

    }

    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);
    final imageWidgets = archive.files
        .where((file) => file.isFile)
        .toList();
    imageWidgets.sort((a, b) => a.name.compareTo(b.name)); // Sort by file name
    final sortedImageWidgets = imageWidgets
        .map((file) => Image.memory(file.content))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );

  }


  ///showMannequinCompliance
  Future<void> _showMannequinCompliance() async {
    setState(() {
      equipType ='Mannequin';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling Mannequin Compliance.......");
    if (takenimages == null) return;
    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMannequinCompliance');
    final request = http.MultipartRequest('POST', url);
    request.fields['storeId'] = Storeid.toString();
    request.fields['equipmentId'] = widget.eqptId.toString();
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);
      print('Resized image bytes (index $index): ${resizedImage!.toList()}');
      final fileName = '$index.jpg';
      request.files.add(await http.MultipartFile.fromBytes(
        'image',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed

    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }
    // Process the response data, e.g. display it in a new screen
    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);
    final imageWidgets = archive.files
        .where((file) => file.isFile)
        .map((file) => Image.memory(file.content))
        .toList();
    // Do something with the response data, e.g. display it in a new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );

  }
  ///R2andR4 Compliance
  Future<void> _showR2AndR4Compliance() async {
    setState(() {
      equipType = 'R4';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showR2AndR4Compliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }







  ///showMrs1To10 Compliance
  Future<void> _showMrs1To10() async {
    setState(() {
      equipType = 'R4';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMrs1To10');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
            takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }







  ///showMR7 Compliance
  Future<void> _showMR7() async {
    setState(() {
      equipType = 'R4';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMR7');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
            takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }





  ///showWallComplianceJeanAndStack
  Future<void> _showWallComplianceJeanAndStack() async {
    setState(() {
      equipType = 'Wall';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceJeanAndStack');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate:270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }








  ///showWallComplianceJeanAndStack
  Future<void> _showWallComplianceStackAndJean() async {
    setState(() {
      equipType = 'Wall';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceStackAndJean');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate:270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }







  /// showWallComplianceJeanAndFrontHangingWithGap
  Future<void> _showWallComplianceJeanAndFrontHangingWithGap() async {
    setState(() {
      equipType = 'Wall';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceJeanAndFrontHangingWithGap');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate:270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }








  ///showWallComplianceFrontFacingAndItemsWithGap
  Future<void> _showWallComplianceFrontFacingAndItemsWithGap() async {
    setState(() {
      equipType = 'Wall';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceFrontFacingAndItemsWithGap');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate:270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }







  ///showWallTableCompliance
  Future<void> _showWallTableCompliance() async {
    setState(() {
      equipType = 'WallTable';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallTableCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,

      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'image',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);
    final imageWidgets = archive.files
        .where((file) => file.isFile)
        .map((file) => Image.memory(file.content))
        .toList();
    // Do something with the response data, e.g. display it in a new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
            takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }



  ///showWallComplianceSweaterAndStack
  Future<void> _showWallComplianceSweaterAndStack() async {
    setState(() {
      equipType = 'Wall';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceSweaterAndStack');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate:270,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }
    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }



  ///showFootwearCompliance
  Future<void> _showFootwearCompliance() async {
    setState(() {
      equipType ='Footwear';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    if (takenimages == null) return;
    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showFootwearCompliance');
    final request = http.MultipartRequest('POST', url);
    request.fields['storeId'] = Storeid.toString();
    request.fields['equipmentId'] = widget.eqptId.toString();
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);
      print('Resized image bytes (index $index): ${resizedImage!.toList()}');
      final fileName = '$index.jpg';
      request.files.add(await http.MultipartFile.fromBytes(
        'image',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }
    // Process the response data, e.g. display it in a new screen
    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);
    final imageWidgets = archive.files
        .where((file) => file.isFile)
        .map((file) => Image.memory(file.content))
        .toList();
    // Do something with the response data, e.g. display it in a new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: imageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
          takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );

  }


  ///showDeoAndPerfumeCompliance
  Future<void> _showDeoAndPerfumeCompliance() async {
    setState(() {
      equipType = 'DeoAndPerfume';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showDeoAndPerfumeCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
            takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }




  ///showNailpolishCompliance
  Future<void> _showNailpolishCompliance() async {
    setState(() {
      equipType = 'NailPolish';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showNailpolishCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    for (var imageFile in takenimages!) {
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'files[]',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage(imagewidget: sortedImageWidgets,equipmentId: widget.eqptId,storeId:Storeid.toString(),
            takenImages: resizedImagesBytesList,equipType: equipType,
          filename:widget.filename,equipCode:widget.eqptCode, equipName:widget.eqptName, Snpshot:widget.eqptNoOfSnaps,
        ),
      ),
    );
  }


/// show LipStick Compliance
  Future<void> _showLipstickCompliance() async {
    print("count..from apii.........${widget.eqptName}");
    if (widget.eqptName == 'BT2' || widget.eqptName == 'BT1' || widget.eqptName == '1')
      {
        beautyCount = 1;
        // preferenceBeautyCount = beautyCount! + 1;
        beautyStatus = 0;
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('filename', widget.filename.toString());
        // await prefs.setString('eqptId', widget.eqptId.toString());
        // await prefs.setString('eqptCode', widget.eqptCode.toString());
        // await prefs.setString('eqptName', preferenceBeautyCount.toString());
        // await prefs.setString('eqptNoOfSnaps', widget.eqptNoOfSnaps.toString());
        // await prefs.setInt('beautyStatus', beautyStatus);

      }
    else if (widget.eqptName == '9')
      {
        beautyStatus = 1;
        beautyCount = 9;
        // preferenceBeautyCount = 0;
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('filename', widget.filename.toString());
        // await prefs.setString('eqptId', widget.eqptId.toString());
        // await prefs.setString('eqptCode', widget.eqptCode.toString());
        // await prefs.setString('eqptName',preferenceBeautyCount.toString());
        // await prefs.setString('eqptNoOfSnaps', widget.eqptNoOfSnaps.toString());
        // await prefs.setInt('beautyStatus', beautyStatus);
      }
    else{
      beautyStatus = 0;
      beautyCount = int.parse(widget.eqptName.toString());
      // preferenceBeautyCount = beautyCount! + 1;
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('filename', widget.filename.toString());
      // await prefs.setString('eqptId', widget.eqptId.toString());
      // await prefs.setString('eqptCode', widget.eqptCode.toString());
      // await prefs.setString('eqptName',preferenceBeautyCount.toString());
      // await prefs.setString('eqptNoOfSnaps', widget.eqptNoOfSnaps.toString());
      // await prefs.setInt('beautyStatus', beautyStatus);
    }
    setState(() {
      equipType = 'Lipstick';
      _isLoading = true;
    });
    String storecode = widget.filename.split("-").first;
    print(storecode);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    print(Storeid);
    if (takenimages == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showLipstickCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int rotationValue = 0;
    int index = 1;
    for (var imageFile in takenimages!) {
      if(beautyCount == 9)
        {
        rotationValue = 270;
        }
      else
      {
        rotationValue = 0;
      }
      // Resize the image
      final resizedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 100,
        rotate: rotationValue,
      );
      final resizedImageBytes = resizedImage!.toList();
      resizedImagesBytesList.add(resizedImageBytes);

      final fileName = '$index.jpg';
      request.fields['storeId'] = Storeid.toString();
      request.fields['equipmentId'] = widget.eqptId.toString();
      request.fields['imagePosition'] = beautyCount.toString();
      request.files.add(await http.MultipartFile.fromBytes(
        'image',
        resizedImage!,
        filename: fileName,
      ));
      request.fields['fileName$beautyCount'] = fileName;
      index++;
    }

    // Add any additional headers or request parameters as needed
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 180));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable (Storeid);
      setState(() {
        _isLoading = false;
      });
    }
    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);
    final imageWidgets = archive.files.where((file) => file.isFile).toList();
    imageWidgets.sort((a, b) => a.name.compareTo(b.name)); // Sort by file name

    final sortedImageWidgets = await Future.wait(imageWidgets.asMap().entries.map((entry) async {
      var imageBytes = entry.value.content;

      // Set the rotation value based on the condition beautyCount == 9
      int rotationValue = beautyCount == 9 ? 90 : 0;
      // Rotate the image
      final resizedImage = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 1024,
        minHeight: 1024,
        quality: 100,
        rotate: rotationValue,
      );

      return Image.memory(resizedImage);
    }).toList());
    print("beauty.......... count ${widget.eqptName}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImageForBeauty(
          imagewidget: sortedImageWidgets,
          equipmentId: widget.eqptId,
          storeId: Storeid.toString(),
          takenImages: resizedImagesBytesList,
          equipType: equipType,
          filename: widget.filename,
          equipCode: widget.eqptCode,
          equipName:widget.eqptName,
          Snpshot: widget.eqptNoOfSnaps,
        ),
      ),
    );
  }

  Future<List<CroppedFile?>> cropTakenImages() async {
    List<CroppedFile?> croppedImages = [];

    for (var imageFile in takenimages) {
      if (imageFile != null) {
        CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop',

              toolbarWidgetColor: Colors.white,
              toolbarColor: Colors.black,
              cropGridColor: Colors.white,
              backgroundColor: Colors.black87,
              activeControlsWidgetColor: Colors.orange,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls:true,
            ),
            IOSUiSettings(title: 'Crop'),
          ],
        );

        croppedImages.add(cropped);
      }
    }

    // Replace original images with cropped images in the 'takenimages' list
    setState(() {
      for (var i = 0; i < croppedImages.length; i++) {
        if (croppedImages[i] != null) {
          takenimages[i] = XFile(croppedImages[i]!.path);
        }
      }
    });
    return croppedImages;
  }



  ///Detecting ATTEMPT
  Future<void> _detectingATTEMPT() async {
    String storecode = widget.filename.split("-").first;
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
    var responseget = await ioClient.get(urlget);
    var storeResponse = jsonDecode(responseget.body);
    int Storeid = storeResponse[0]['id'];
    setState(() {

      store_id = Storeid.toString();
    });

    String formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    print("date...........$formattedDate");
    TimeOfDay formattedTime = TimeOfDay.fromDateTime(currentDate);
    String formattedTimeString = formattedTime.format(context);
    int hour = formattedTime.hour;
    print(formattedTimeString);
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_which_attempt"),
          body: json.encode({"date":formattedDate.toString(), "equipment_id":widget.eqptId.toString(),"store_id":Storeid.toString()}),
          headers: {
            "content-type": "application/json",
          });
      var AttemptResponse = jsonDecode(response.body);
      Attempt = AttemptResponse[0][0];
      Attempt = Attempt != null ? Attempt : null;

    } catch (e) {
      print(e.toString());
    }

    ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////
    //// MORNING ATTEMPT
    if(hour >= 8 && hour <= 12) {
      if (Attempt == null) {
        aTTempt = 1;
        setState(() {
          whichAttempt = 'MF';
          _isGate = true;
          captureAttempt = aTTempt!;
        });
      }
      else if (Attempt == 1) {
        aTTempt = 2;
        setState(() {
          whichAttempt = 'MS';
          _isGate = true;
          captureAttempt = aTTempt!;
        });

      }
      else {
        aTTempt = 4;
        ///Remove after testing Demo
        setState(() {
          whichAttempt = 'ES';
          _isGate = true;
          captureAttempt = aTTempt!;
        });

        ///***************************
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text("ATTEMPT IS OVER"),
        //   backgroundColor: Colors.red,
        //   duration: Duration(seconds: 2),
        // ));
      }
    }
    ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////
    //// EVENING ATTEMPT
    else if(hour >= 12 && hour <= 20){
       if(Attempt == null || Attempt == 1) {
        if (Attempt == null) {
          aTTempt = 1;
          setState(() {
            whichAttempt = 'MF';
            _isGate = true;
            captureAttempt = aTTempt!;
          });

        }
        else if (Attempt == 1) {
          aTTempt = 2;
          setState(() {
            whichAttempt = 'MS';
            _isGate = true;
            captureAttempt = aTTempt!;
          });

        }
       }
       else {
        if (Attempt == 2) {
          aTTempt = 3;
          setState(() {
            whichAttempt = 'EF';
            _isGate = true;
            captureAttempt = aTTempt!;
          });

        }
        else if (Attempt == 3) {
          aTTempt = 4;
          setState(() {
            whichAttempt = 'ES';
            _isGate = true;
            captureAttempt = aTTempt!;
          });

        }
        else {
          ///Remove after testing Demo
          aTTempt = 4;
          setState(() {
            whichAttempt = 'ES';
            _isGate = true;
            captureAttempt = aTTempt!;
          });

          ///***************************
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("ATTEMPT IS OVER"),
          //   backgroundColor: Colors.red,
          //   duration: Duration(seconds: 2),
          // ));
        }
      }
     }
    else
    {
      ///Remove after testing Demo
      aTTempt = 4;
      setState(() {
        whichAttempt = 'ES';
        _isGate = true;
        captureAttempt = aTTempt!;
      });

      ///***************************
      ///***************************
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text("ATTEMPT IS OVER TODAY"),
      //   backgroundColor: Colors.red,
      //   duration: Duration(seconds: 2),
      // ));
    }
  }


  ///uploadCapturedImages
  Future<void> _uploadMobImages() async {
    ///camera disposing
    setState(() {
      print("Camera Off");
      // controller!.stopImageStream();
      controller?.dispose();
    });
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("SAVING IMAGES, PLEASE WAIT..."),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 1),
    ));
    if (takenimages == null) return;
      final url = Uri.parse('https://smh-app.trent-tata.com/flask/uploadMobImage');
      final request = http.MultipartRequest('POST', url);
      request.headers['Connection'] = 'Keep-Alive';
      String name = widget.filename.toString();
      int index = 1;
    for (var imageFile in takenimages!) {
      final bytes = await imageFile.readAsBytes();
      final fileName = '$name-$whichAttempt-$index.png';
        request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
       ));
      request.fields['fileName$index'] = fileName;
      index++;
    }
    print("Sending ${takenimages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      ///camera disposing
      setState(() {
        controller!.dispose();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("SAVING SUCCESSFUL..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),

      ));
      _saveCaptureDetails(store_id,aTTempt);
      print("capture...attempt .................$captureAttempt");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("SAVING FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }

  }

  Future<void> _saveCaptureDetails(Stid,aTTempt) async {
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/saveCapturedImageDetails"),
          body: json.encode({"store_id": Stid, "equipment_id": widget.eqptId, "image_path": widget.filename, "attempt": aTTempt
          }),
          headers: {
            "content-type": "application/json",
          });

      print('Response body: ${response.body}');
    } catch (e) {
      print(e.toString());
    }
  }

  /// update the attempt into vm_detected_values
  Future<void> insertAttemptIntoDetectedTable (int storeid) async{
    print(storeid);
    print(captureAttempt);
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/update_attempt_into_vm_detected_table_latest"),
          body: json.encode({"storeId":storeid.toString(), "equipmentId": widget.eqptId, "attempt": captureAttempt
          }),
          headers: {
            "content-type": "application/json",
          });

      print('Response body: ${response.body}');
    } catch (e) {
      print(e.toString());
    }
  }
  /// switch statement for calling bottom navigator buttons functions
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add your code here to handle the item tap event for each item
    switch (index) {
      case 0:
        recapture();
        break;
      case 1:
        cropTakenImages();
        break;
      case 2:
        setState(() {
          print("Camera Off");
          controller!.stopImageStream();
          // controller?.dispose();
        });
        if(_isGate) {

              if (widget.eqptCode == 'MR6' || widget.eqptCode == 'MR11') {
                    _showMensShortsCompliance();
              }
              else if (widget.eqptCode == 'BT1-BACK' || widget.eqptCode == 'BT1-FRONT' || widget.eqptCode == 'BT2-BACK' ||
                       widget.eqptCode == 'BT2-FRONT' || widget.eqptCode == 'GT1-FRONT' || widget.eqptCode == 'GT1-BACK' ||
                       widget.eqptCode == 'GT2-FRONT' || widget.eqptCode == 'GT2-BACK' || widget.eqptCode == 'MT1-FRONT' ||
                       widget.eqptCode == 'MT1-BACK' || widget.eqptCode == 'MT2-FRONT' || widget.eqptCode == 'MT2-BACK' ||
                       widget.eqptCode == 'WT-FRONT' || widget.eqptCode == 'WT-BACK' || widget.eqptCode == 'ET1-FRONT' ||
                       widget.eqptCode == 'ET1-BACK' || widget.eqptCode == 'ET2-FRONT' || widget.eqptCode == 'ET2-BACK') {
                       _showTableCompliance();
              }
              else if (widget.eqptCode == 'MHS-M1' || widget.eqptCode == 'MHS-M2' ||
                       widget.eqptCode == 'WHS-M1' || widget.eqptCode == 'WHS-M2' ||
                       widget.eqptCode == 'EHS-M1' || widget.eqptCode == 'EHS-M2') {
            _showMannequinCompliance();
          }
          else if (widget.eqptCode == 'MHS1' || widget.eqptCode == 'MHS2' || widget.eqptCode == 'WHS1' || widget.eqptCode == 'WHS2' ||  widget.eqptCode == 'EHS1' ||  widget.eqptCode == 'EHS2' ||
                   widget.eqptCode == 'BR1' || widget.eqptCode == 'BR2' || widget.eqptCode == 'BR3' || widget.eqptCode == 'BR4' || widget.eqptCode == 'BR5' ||
                   widget.eqptCode == 'GR1' || widget.eqptCode == 'GR2' || widget.eqptCode == 'GR3' || widget.eqptCode == 'GR4' || widget.eqptCode == 'GR5' ||
                   widget.eqptCode == 'MIR1' || widget.eqptCode == 'M1R2' || widget.eqptCode == 'MHS-E1'  ||
                   widget.eqptCode == 'MR12' || widget.eqptCode == 'MR13' || widget.eqptCode == 'MR14' || widget.eqptCode == 'MR15'  ||
                   widget.eqptCode == 'WHS-E1' || widget.eqptCode == 'WHS-E2' || widget.eqptCode == 'WR1' || widget.eqptCode == 'WR2' ||
                   widget.eqptCode == 'WR3' || widget.eqptCode == 'WR4' || widget.eqptCode == 'WR5' || widget.eqptCode == 'WR6' || widget.eqptCode == 'WR7' ||
                   widget.eqptCode == 'WR8' || widget.eqptCode == 'WR9' || widget.eqptCode == 'WR10' || widget.eqptCode == 'WR11' || widget.eqptCode == 'WR12' ||
                   widget.eqptCode == 'WR13' || widget.eqptCode == 'EHS-E1' || widget.eqptCode == 'EHS-E2' || widget.eqptCode == 'EHS-E3' ||
                   widget.eqptCode == 'EHS-E4' || widget.eqptCode == 'ER1' || widget.eqptCode == 'ER2' || widget.eqptCode == 'ER3' ||
                   widget.eqptCode == 'ER4' || widget.eqptCode == 'ER5' )
          {
            _showR2AndR4Compliance();
          }
          else if (widget.eqptCode == 'MR7'){
                _showMR7();
              }
          else if (widget.eqptCode == 'MR1' || widget.eqptCode == 'MR2' || widget.eqptCode == 'MR3' ||
                  widget.eqptCode == 'MR4' || widget.eqptCode == 'MR5'  || widget.eqptCode == 'MR8' || widget.eqptCode == 'MR9' || widget.eqptCode == 'MR10'){
                _showMrs1To10();
              }
          else if (widget.eqptCode == 'M5') {
            _showWallComplianceJeanAndStack();
          }
          else if (widget.eqptCode == 'M8') {
            _showWallTableCompliance();
          }
          else if (widget.eqptCode == 'M9' || widget.eqptCode == 'M7') {
            _showWallComplianceSweaterAndStack();
          }
          else if (widget.eqptCode == 'M10' || widget.eqptCode == 'M1') {
            _showWallComplianceFrontFacingAndItemsWithGap();
          }
          else if (widget.eqptCode == 'W6' || widget.eqptCode == 'W8') {
            _showWallComplianceStackAndJean();
          }
          else if (widget.eqptCode == 'W7') {
            _showWallComplianceJeanAndFrontHangingWithGap();
          }
          else if (widget.eqptCode == 'MF1' || widget.eqptCode == 'MF2' || widget.eqptCode == 'MF3') {
            _showFootwearCompliance();
          }
          else if (widget.eqptCode == 'B&B-1'|| widget.eqptCode == 'B&B-2'|| widget.eqptCode == 'B&B-3'|| widget.eqptCode == 'B&B-4' ||
                  widget.eqptCode == 'B&B-2-SIDE1'|| widget.eqptCode == 'B&B-2-SIDE2'|| widget.eqptCode == 'B&B-2-SIDE3'|| widget.eqptCode == 'B&B-2-SIDE4' ||
                  widget.eqptCode == 'B&B-3-SIDE1'|| widget.eqptCode == 'B&B-3-SIDE2'|| widget.eqptCode == 'B&B-3-SIDE3'|| widget.eqptCode == 'B&B-3-SIDE4' ||
                  widget.eqptCode == 'B&B-4-SIDE1'|| widget.eqptCode == 'B&B-4-SIDE2'|| widget.eqptCode == 'B&B-4-SIDE3'|| widget.eqptCode == 'B&B-4-SIDE4') {
            _showDeoAndPerfumeCompliance();
          }
          else if (widget.eqptCode == 'BT2') {
            // _showNailpolishCompliance();
                _showLipstickCompliance();
          }
          else if (widget.eqptCode == 'BT1') {
            _showLipstickCompliance();
          }
          _uploadMobImages();
        }
        // setState(() {
        //   _isLoading=false;
        // });
        break;
    }
  }


   @override
   Widget build(BuildContext context) {
      if(controller != null)
      {
       if (!(controller!.value.isInitialized)) {
         return  Container(child: const Text("Controller Not Initialized"),);
       }
       String noofphotos = widget.eqptNoOfSnaps;
      if(no_of_takenphotos <= int.parse(noofphotos))
      {
      var  photoORphotos = " photo.";//(int.parse(noofphotos) == 1)?" photo.":" photos.";
      return Stack(
               alignment: FractionalOffset.center,
             children: <Widget>[
                  Center(
                    child: MaterialApp(
                     debugShowCheckedModeBanner: false,
                         home: CameraPreview(controller!)
                   ),
                  ),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: 0.9,
                        child: Padding(
                           padding: const EdgeInsets.only(top: 10.0),
                           child: TextField(
                            readOnly: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.top,
                             maxLines: null,
                             decoration: InputDecoration(
                               filled: false,
                               hintStyle: const TextStyle(color: Colors.white, fontSize: 14),
                               hintText: "Equipment : ${widget.eqptCode}, \nPlease take $noofphotos$photoORphotos",

                            ),
                            ),
                            )
                            ),
                            ),
                            if(widget.eqptCode.toString() == 'BT2' || widget.eqptCode.toString() == 'BT1')
                              Padding(
                                padding: const EdgeInsets.only(bottom:30.0),
                                child: Center(
                                  child:Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FloatingActionButton.extended(
                                          label: widget.eqptName == 'BT2' || widget.eqptName == 'BT1' || widget.eqptName == '1'? const Text("First Two Tray") :
                                          widget.eqptName == '2' ? const Text("Second Two Tray") :
                                          widget.eqptName == '3' ? const Text("Third Two Tray") :
                                          widget.eqptName == '4' ? const Text("Fourth Two Tray") :
                                          widget.eqptName == '5' ? const Text("Fifth Two Tray") :
                                          widget.eqptName == '6' ? const Text("Sixth Two Tray") :
                                          widget.eqptName == '7' ? const Text("Seventh Two Tray") :
                                          widget.eqptName == '8' ? const Text("Eighth Two Tray") :
                                          const Text("Take Tester"),
                                          backgroundColor: const Color.fromARGB(179, 52, 52, 51),
                                          icon: const Icon( // <-- Icon
                                            Icons.camera,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            if(no_of_takenphotos <= int.parse(noofphotos))
                                            {
                                              controller!.takePicture().then((capturedFile) => {
                                                takenimages.add(capturedFile),
                                                setState(() {
                                                  no_of_takenphotos ++;
                                                })
                                              });
                                            }
                                            _detectingATTEMPT();
                                          }
                                      )
                                  ),
                                ),
                              )
                            else
                             Padding(
                              padding: const EdgeInsets.only(bottom:30.0),
                              child: Center(
                                 child:Align(
                                  alignment: Alignment.bottomCenter,
                                     child: FloatingActionButton.extended(
                                           label: Text("$no_of_takenphotos of $noofphotos"), // <-- Text
                                            backgroundColor: const Color.fromARGB(179, 52, 52, 51),
                                             icon: const Icon( // <-- Icon
                                              Icons.camera,
                                               size: 24.0,
                                                ),
                                                 onPressed: () async {

                                                   if(no_of_takenphotos <= int.parse(noofphotos))
                                                    {
                                                     controller!.takePicture().then((capturedFile) => {
                                                       takenimages.add(capturedFile),
                                                       setState(() {
                                                       no_of_takenphotos ++;
                                                         }),

                                                     });
                                               }
                                                   _detectingATTEMPT();
                                              }
                                        )
                                   ),
                               ),
                          )],
                  );

             }

              else
              {
                final double screenHeight = MediaQuery.of(context).size.height;
                final double appBarHeight = AppBar().preferredSize.height;
                final double bottomNavBarHeight = kBottomNavigationBarHeight;

              double listViewHeight = screenHeight - appBarHeight - bottomNavBarHeight;
                return Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    backgroundColor: Colors.black,
                    elevation: 0.00,
                  ),
                      body: SingleChildScrollView(
                        child: Column(
                          children:<Widget> [

                            Container(
                                width: MediaQuery.of(context).size.width, // set width to screen width
                                height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight - 40,
                              child: Stack(
                                children: [
                                  ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: takenimages.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 0.0,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight,
                                          child: Image.file(
                                            File(takenimages[index].path),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
                                              SizedBox(height: 16), // add some spacing between the progress indicator and the label
                                              Text('Detecting Image...',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),), // add the label
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      bottomNavigationBar: Visibility(

                          child: BottomNavigationBar(
                             showUnselectedLabels:true,
                            backgroundColor: Colors.black87,
                            unselectedItemColor: Colors.white,
                            selectedItemColor: Colors.yellowAccent,
                            selectedLabelStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 10),
                            unselectedLabelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                backgroundColor: Colors.black87,
                                icon: Icon(Icons.camera_alt_rounded),
                                label: 'Recapture',
                              ),

                              BottomNavigationBarItem(
                                backgroundColor: Colors.black87,
                                icon: Icon(Icons.crop),
                                label: 'Crop',
                              ),
                              BottomNavigationBarItem(
                                backgroundColor: Colors.black87,
                                icon: Icon(Icons.save),
                                label: 'Submit',

                              ),
                            ],
                            currentIndex: _selectedIndex,
                            onTap: _onItemTapped,
                          ),
                      ),
                );
              }
      }
 else{
    return const Text("Loading Camera... Please wait");
    }

}

 void recapture()
{
  no_of_takenphotos = 0;
  takenimages.clear();
  // controller!.dispose();
  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => vmcamerahome.VMCaptureImage(
                    filename: widget.filename,
                    eqptId: widget.eqptId,
                    eqptCode: widget.eqptCode,
                    eqptName: widget.eqptName,
                    stid: widget.stId,
                    eqptNoOfSnaps: widget.eqptNoOfSnaps,
                    eqptType: widget.eqptType.toString(),
                    // storeId:widget.storeId.toString(),

                    )),
                );
}

Scaffold clickimage(XFile img,) {
    return const Scaffold(
      body: Text("Clicked")
    );
  }


}














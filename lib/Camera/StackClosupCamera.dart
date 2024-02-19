
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import '../Detection/DetectedImageGrid.dart';
import '../Menu/QRCodeGenerator.dart';




class CaptureClosupStack extends StatefulWidget {
  final List<List<int>> takenImages;
  final String? storeId;
  final String? equipmentId;
  final String? productCode;
  final String? equipType;
  final String? equipCode;
  final String? equipName;
  final String? snpShot;
  final String? fileName;
  final int? stackPosition;
  final ImageProvider image;
  final List<Image> imageWidget;
  const CaptureClosupStack({Key? key, required  this. storeId, this.
  equipmentId, required this. productCode, required this. stackPosition, required this.takenImages, this. equipType, this. equipCode, this. equipName,
    this. snpShot, this. fileName, required this. image, required this.imageWidget, }): super(key: key);

  @override
  _CaptureClosupStackState createState() => _CaptureClosupStackState();
}


class _CaptureClosupStackState extends State<CaptureClosupStack> {
  CameraController? cameraController;
  Future<void>? cameraInitializeFuture;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    cameraController!.stopImageStream();// Dispose the camera controller
    cameraController = null; // Break the reference to the State object
    super.dispose();

  }
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final selectedCamera = cameras.first;
    cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController!.initialize();
    cameraController!.setFlashMode(FlashMode.off);
    cameraController!.setFocusMode(FocusMode.auto);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> captureImage() async {
    if (cameraController!.value.isInitialized) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String imageName = '${DateTime.now()}.jpg';
      final String imagePath = path.join(appDirectory.path, imageName);
      await cameraController!.setFocusMode(FocusMode.locked);
      await cameraController!.setExposureMode(ExposureMode.locked);
      XFile capturedImage = await cameraController!.takePicture();
      await cameraController!.setFocusMode(FocusMode.auto);
      await cameraController!.setExposureMode(ExposureMode.auto);
      final File imageFile = File(capturedImage.path);

      await imageFile.copy(imagePath);
      // Delay before disposing the camera
       const disposeDelay = Duration(seconds: 2); // Change the duration as desired
      Future.delayed(disposeDelay, () {
        cameraController!.dispose();
        cameraController = null; // Break the reference to the State object
      });


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayImageScreen(
            imagePath: imagePath,
            takenImages: widget.takenImages,
            storeId: widget.storeId,
            equipmentId: widget.equipmentId,
            productCode: widget.productCode,
            stackPosition: widget.stackPosition,
            equipType: widget.equipType,
            equipCode: widget.equipCode,
            equipName: widget.equipName,
            snpShot: widget.snpShot,
            fileName: widget.fileName,
            image: widget.image,
            imageWidget: widget.imageWidget,
          ),
        ),
      );

    }
  }


  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    } else {
      return
        Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(cameraController!),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      captureImage();

                    },
                    backgroundColor: Colors.grey[350],
                    child: const Icon(Icons.camera, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      // );
    }
  }
}

class DisplayImageScreen extends StatefulWidget {
  final String imagePath;
  final List<List<int>> takenImages;
  final String? storeId;
  final String? equipmentId;
  final String? productCode;
  final int? stackPosition;
  final String? equipType;
  final String? equipCode;
  final String? equipName;
  final String? snpShot;
  final String? fileName;
  final ImageProvider image;
  final List<Image> imageWidget;

  const DisplayImageScreen({
    required this.imagePath,
    required this.takenImages,
    this.storeId,
    this.equipmentId,
    this.productCode,
    this.stackPosition,
    this.equipType,
    this.equipCode,
    this.equipName,
    this.snpShot,
    this.fileName,
    required this.image,
    required this.imageWidget,
  });

  @override
  State<DisplayImageScreen> createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(''),
          leading: IconButton(
            onPressed: () {
            Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    kBottomNavigationBarHeight -
                    20,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.fill,
                ),
              ),
              if (_isLoading)
                const Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Detecting Image...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                   UpdatingComplianceSize();
                },
                child: const Row(
                  children: [
                    Icon(Icons.save, color: Colors.black),
                    Text('Submit', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }



  Future<void> UpdatingComplianceSize() async {
    print("stackPosition...${widget.stackPosition}");
    setState(() {
      _isLoading = true;
    });
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    // Update the URL endpoint
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/showStackCompliance');

    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;

    // Add each image as a file field
    for (var i = 0; i < widget.takenImages.length; i++) {
      final fileName = '$index.jpg';
      request.fields['storeId'] = widget.storeId.toString();
      request.fields['equipmentId'] = widget.equipmentId.toString();
      request.fields['productCode'] = widget.productCode.toString();
      request.fields['stackPosition'] = widget.stackPosition.toString();

      request.files.add(await http.MultipartFile.fromBytes(
        'tableImage', // Use a name that matches the server's expectations
        widget.takenImages[i],
        filename: fileName,
      ));

      request.fields['fileName$index'] = fileName;
      index++;
    }
    final stackImageFile = File(widget.imagePath);
    request.files.add(await http.MultipartFile.fromPath(
      'stackImage', // Use a name that matches the server's expectations
      stackImageFile.path,
    ));
    print("Sending ${widget.takenImages!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 180));
    print(response.statusCode);
    if (response.statusCode != 200) {
      setState(() {
        _isLoading = false;
      });
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

    // Process the response data, e.g. display it in a new screen
    final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(imageData);

// Sort the files in the archive based on their names numerically
    final sortedFiles = archive.files.toList()
      ..sort((a, b) {
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

    print(
        'Extracted Image Filenames (Numeric Sorted Order): $imageFilenames'); // Print the filenames
   Navigator.of(context).pop();
   Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImage2(
          imageWidgets: imageWidgets,
          equipmentId: widget.equipmentId,
          storeId: widget.storeId,
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
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }



}





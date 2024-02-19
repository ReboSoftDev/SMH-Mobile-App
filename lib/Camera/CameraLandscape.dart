import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_alice/alice.dart';
import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:sample/Camera/VMCameraHome.dart';
import 'package:sample/TablesResultScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../Detection/DetectedImage.dart';
import '../Detection/DetectedImageForBeauty.dart';
import '../Detection/DetectedImageGrid.dart';
import '../main.dart';



class VMcameraLandscape extends StatefulWidget {
  final String filename;
  final String eqptId;
  final String eqptCode;
  final String eqptName;
  final String eqptNoOfSnaps;
  final String eqptType;
  final String stId;
  const VMcameraLandscape({Key? key,  required this.filename, required this.eqptId, required this.eqptCode, required this.eqptName, required this.eqptNoOfSnaps, required this. eqptType, required this. stId,
  }) : super(key: key);
  @override
  _VMcameraLandscapeState createState() => _VMcameraLandscapeState();
}

class _VMcameraLandscapeState extends State<VMcameraLandscape> {
  CameraController? cameraController;
  CameraImage? cameraImage;
  List? recognitionsList;
  Future<void>? cameraInitializeFuture;
  bool _isFlashOn = false;
  int no_of_takenphotos = 1;
  bool isCameraReady = false;
  DateTime currentDate = DateTime.now();
  int? aTTempt;
  int? Attempt;
  String? whichAttempt;
  String? store_id;
  int? captureAttempt;
  double _zoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool showExposureButton = false;
  bool showOpacityButton = false;
  bool showZoomButton = false;
  bool showZoomPinch = false;
  bool showBottomSheet = false;

  String? imageUrl;


  void stopCamera() {
    if( cameraController != null){
      cameraController!.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await fetchOverlayImage();
    if(widget.eqptName.toString() == 'BT1' || widget.eqptName.toString() == 'BT2' || widget.eqptName.toString() == '2' || widget.eqptName.toString() == '3' ||
        widget.eqptName.toString() == '4' || widget.eqptName.toString() == '5' || widget.eqptName.toString() == '6' || widget.eqptName.toString() == '7' ||
        widget.eqptName.toString() == '8'|| widget.eqptType.toString() == 'Mannequin' || widget.eqptType.toString() == 'WallTable' || widget.eqptType.toString() == 'MensShorts' ||
        widget.eqptType.toString() == 'Kajal' || widget.eqptCode == 'MHS1' || widget.eqptCode == 'MHS2' || widget.eqptCode == 'WHS1' || widget.eqptCode == 'WHS2' ||  widget.eqptCode == 'EHS1' ||  widget.eqptCode == 'EHS2' ||
        widget.eqptCode == 'MR7' ||
        widget.eqptCode == 'MF1' || widget.eqptCode == 'MF2' || widget.eqptCode == 'MF3' ||
        widget.eqptCode == 'B&B-1'|| widget.eqptCode == 'B&B-2'|| widget.eqptCode == 'B&B-3'|| widget.eqptCode == 'B&B-4' ||
        widget.eqptCode == 'B&B-2-SIDE1'|| widget.eqptCode == 'B&B-2-SIDE2'|| widget.eqptCode == 'B&B-2-SIDE3'|| widget.eqptCode == 'B&B-2-SIDE4' ||
        widget.eqptCode == 'B&B-3-SIDE1'|| widget.eqptCode == 'B&B-3-SIDE2'|| widget.eqptCode == 'B&B-3-SIDE3'|| widget.eqptCode == 'B&B-3-SIDE4' ||
        widget.eqptCode == 'B&B-4-SIDE1'|| widget.eqptCode == 'B&B-4-SIDE2'|| widget.eqptCode == 'B&B-4-SIDE3'|| widget.eqptCode == 'B&B-4-SIDE4') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      if(widget.eqptType == 'Table')
      {
        showOpacityButton = true;
      }
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    initializeCamera();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    cameraController?.dispose();

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
    cameraController!.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
    cameraController!.getMinZoomLevel().then((value) => _minAvailableZoom = value);
    cameraController!.getMinExposureOffset().then((value) => _minAvailableExposureOffset = value);
    cameraController!.getMaxExposureOffset().then((value) => _maxAvailableExposureOffset = value);
    cameraController!.setFlashMode(FlashMode.off);


    if (mounted) {
      setState(() {
      });
    }
  }

  List<String> capturedImagePaths = [];

  Future<void> captureImage() async {
    Uint8List? compressedImage; // Declare the variable here
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


      final imageBytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(imageBytes);
      final totalHeight = image.height;
      final totalWidth = image.width;


      if(widget.eqptName.toString() == 'BT1' || widget.eqptName.toString() == 'BT2' || widget.eqptName.toString() == '2' || widget.eqptName.toString() == '3' ||
          widget.eqptName.toString() == '4' || widget.eqptName.toString() == '5' || widget.eqptName.toString() == '6' || widget.eqptName.toString() == '7' ||
          widget.eqptName.toString() == '8'|| widget.eqptType.toString() == 'Mannequin' || widget.eqptType.toString() == 'WallTable' || widget.eqptType.toString() == 'MensShorts' ||
          widget.eqptCode == 'MHS1' || widget.eqptCode == 'MHS2' || widget.eqptCode == 'WHS1' || widget.eqptCode == 'WHS2' ||  widget.eqptCode == 'EHS1' ||  widget.eqptCode == 'EHS2' ||
          widget.eqptCode == 'MHS-E1'  || widget.eqptCode == 'MR7' ||
          widget.eqptCode == 'MF1' || widget.eqptCode == 'MF2' || widget.eqptCode == 'MF3' ||
          widget.eqptCode == 'B&B-1'|| widget.eqptCode == 'B&B-2'|| widget.eqptCode == 'B&B-3'|| widget.eqptCode == 'B&B-4' ||
          widget.eqptCode == 'B&B-2-SIDE1'|| widget.eqptCode == 'B&B-2-SIDE2'|| widget.eqptCode == 'B&B-2-SIDE3'|| widget.eqptCode == 'B&B-2-SIDE4' ||
          widget.eqptCode == 'B&B-3-SIDE1'|| widget.eqptCode == 'B&B-3-SIDE2'|| widget.eqptCode == 'B&B-3-SIDE3'|| widget.eqptCode == 'B&B-3-SIDE4' ||
          widget.eqptCode == 'B&B-4-SIDE1'|| widget.eqptCode == 'B&B-4-SIDE2'|| widget.eqptCode == 'B&B-4-SIDE3'|| widget.eqptCode == 'B&B-4-SIDE4' || widget.eqptType == 'Kajal') {

        compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
        );
      } else {
        compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          rotate: 90,
        );
      }

      // Convert the Uint8List? to a List<int>
      List<int> compressedImageData = compressedImage!.toList();
      // Save the compressed image to the app directory
      await File(imagePath).writeAsBytes(compressedImageData);
      capturedImagePaths.add(imagePath);

      setState(() {
        no_of_takenphotos++;
      });

      if (no_of_takenphotos > int.parse(widget.eqptNoOfSnaps)) {
        // print(".......mmmmm  $Attempt mmmmm");
        // Capture the desired number of images
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayCapturedImageScreen(
              imagePaths: capturedImagePaths,
              filename: widget.filename,
              eqptId: widget.eqptId,
              eqptCode: widget.eqptCode,
              eqptName: widget.eqptName,
              eqptNoOfSnaps: widget.eqptNoOfSnaps,
              eqptType: widget.eqptType,
              attempt: captureAttempt.toString(),
              stId : widget.stId.toString(),
              signageData : "399",
            ),
          ),
        );
      }
    }
  }



  /// Screen Pinch In Pinch Out (Zoom)//////////////////////////////////////////////
  void _handleScaleUpdate(ScaleUpdateDetails details) async {
    final newZoomLevel = _zoomLevel * details.scale;
    // Ensure the zoom level stays within a valid range
    final maxZoomLevel = await cameraController!.getMaxZoomLevel();
    if (newZoomLevel >= 1.0 && newZoomLevel <= maxZoomLevel) {
      setState(() {
        _zoomLevel = newZoomLevel;
        cameraController!.setZoomLevel(_zoomLevel);
      });
    }
  }
  /// Zooming Values showing screen
  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {

      showZoomPinch = true;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      showZoomPinch = false;
    });
  }
  /// /////////////////////////////////////////////////////////////


  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (cameraController == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController!.setExposurePoint(offset);
    cameraController!.setFocusPoint(offset);
  }
  double opacityValue = 0.3; // Initial opacity value

  void changeOpacity(double newValue) {
    setState(() {
      opacityValue = newValue;
    });
  }
  // Widget getImageForEqptCode(String eqptCode) {
  //   switch (eqptCode) {
  //     case 'MT2-FRONT':
  //       return Image.asset('assets/image1.png');
  //     case 'MT2-BACK':
  //       return Image.asset('assets/image1.png');
  //     case 'MT1-BACK':
  //       return Image.asset('assets/699.png');
  //     case 'MT1-FRONT':
  //       return Image.asset('assets/mtwt.png');
  //     case 'WT-FRONT':
  //       return Image.asset('assets/599.png');
  //     case 'WT-BACK':
  //       return Image.asset('assets/mtwt.png');
  //     case 'ET1-FRONT':
  //       return Image.asset('assets/299.png');
  //     case 'ET2-FRONT':
  //       return Image.asset('assets/image1.png');
  //     case 'ET1-BACK':
  //       return Image.asset('assets/499.png');
  //     case 'ET2-BACK':
  //       return Image.asset('assets/image1.png');
  //     case 'BT1-FRONT':
  //       return Image.asset('assets/kids.png');
  //     case 'BT1-BACK':
  //       return Image.asset('assets/249.png');
  //     case 'BT2-FRONT':
  //       return Image.asset('assets/169.png');
  //     case 'BT2-BACK':
  //       return Image.asset('assets/299.png');
  //     case 'GT1-FRONT':
  //       return Image.asset('assets/kids.png');
  //     case 'GT2-FRONT':
  //       return Image.asset('assets/169.png');
  //     case 'GT1-BACK':
  //       return Image.asset('assets/199.png');
  //     case 'GT2-BACK':
  //       return Image.asset('assets/249.png');
  //
  //     default:
  //       return Image.asset('assets/image1.png'); // Provide a default image or handle the case as needed
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return CameraLoadingWidget();
    } else {
      return Scaffold(
        body: GestureDetector(

          onScaleStart: _handleScaleStart,
          onScaleUpdate:  _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          onTap: (){
            setState(() {
              showExposureButton = false;
              showZoomButton = false;
              showOpacityButton = true;
            });
          } ,
          child:Stack(
            // alignment: FractionalOffset.center,
            children: <Widget>[
              Center(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: CameraPreview(cameraController!,child: LayoutBuilder(builder:(BuildContext context,BoxConstraints constraints){
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) =>
                          onViewFinderTap(details,constraints),
                    );
                  }),),
                ),
              ),
              ///overlay
              if(widget.eqptType.toString() == 'Table' && imageUrl != null)
                Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: opacityValue, // Adjust the opacity value as needed (0.0 to 1.0)
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width - 300 , // Set the desired width
                        height: MediaQuery.of(context).size.height - 20,
                        child:FittedBox(
                            fit: BoxFit.fill,
                            child: Image.memory(
                              base64Decode(imageUrl!),
                              fit: BoxFit.fill, // You can adjust the fit as needed
                            )

                        )// Set the desired height
                    ),
                  ),
                ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Opacity(
              //     opacity: opacityValue, // Adjust the opacity value as needed (0.0 to 1.0)
              //     child: SizedBox(
              //       //color:Colors.orange,
              //       // margin:const EdgeInsets.only(top:20),
              //       // width:500,
              //         width: MediaQuery.of(context).size.width - 230 , // Set the desired width
              //         height: MediaQuery.of(context).size.height - 20,
              //         child:FittedBox(
              //           fit: BoxFit.fill,
              //           child: getImageForEqptCode(widget.eqptCode),
              //         )// Set the desired height
              //     ),
              //   ),
              // ),
              if(widget.eqptType.toString() == 'Table' &&  showOpacityButton == true)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child:Container(
                      width: 300,
                      height: 50,
                      margin:const EdgeInsets.only(left:0),
                      child: Slider(
                        value: opacityValue,
                        onChanged: changeOpacity,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.white,
                        //divisions: 10, // You can adjust the number of divisions
                        label: 'Opacity: ${opacityValue.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                ),
              /// zoom in out in pinch
              if(showZoomPinch)
                Align(
                  alignment: Alignment.topCenter,
                  child:Container(
                    margin:  const EdgeInsets.only(top:130),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text('${_zoomLevel.toStringAsFixed(2)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              /// capture button beauty
              Align(
                alignment: Alignment.topLeft,
                child: Opacity(
                  opacity: 0.9,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: TextField(
                      readOnly: true,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.top,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(color: Colors.white, fontSize: 15),
                        hintText: "${widget.eqptCode} \tPlease take ${widget.eqptNoOfSnaps} Picture",
                        filled: false,
                      ),
                    ),
                  ),
                ),
              ),
              if(widget.eqptCode.toString() == 'BT2' || widget.eqptCode.toString() == 'BT1')
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Center(
                    child: Align(
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
                          if (no_of_takenphotos <= int.parse(widget.eqptNoOfSnaps)) {
                            captureImage();
                          }
                          _detectingATTEMPT();
                        },
                      ),
                    ),
                  ),
                )
              /// capture button for other equipments
              else
                Padding(
                  padding: widget.eqptType.toString() == 'Table' || widget.eqptType.toString() == 'Wall' ? const EdgeInsets.only(right: 10):const EdgeInsets.only(bottom: 30.0),
                  child: Center(
                    child: Align(
                      alignment: widget.eqptType.toString() == 'Table' || widget.eqptType.toString() == 'Wall' ? Alignment.centerRight : Alignment.bottomCenter,
                      child: FloatingActionButton.extended(
                        label: Text("$no_of_takenphotos of ${widget.eqptNoOfSnaps}"),
                        backgroundColor: const Color.fromARGB(179, 52, 52, 51),
                        icon: const Icon(
                          Icons.camera,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          if (no_of_takenphotos <= int.parse(widget.eqptNoOfSnaps)) {
                            captureImage();
                          }
                          _detectingATTEMPT();
                        },
                      ),
                    ),
                  ),
                ),





              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 120, // Set the desired width for the button
                  height: 30, // Set the desired height for the button
                  margin: const EdgeInsets.only(top: 30), // Adjust the margin as needed
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_isFlashOn == false) {
                          _isFlashOn = true;
                          cameraController!.setFlashMode(FlashMode.always);
                        } else {
                          _isFlashOn = false;
                          cameraController!.setFlashMode(FlashMode.off);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, // Set the background color to transparent
                      onPrimary: Colors.black, // Text color
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Set the border radius to zero for square shape
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isFlashOn
                            ? Icons.flash_on
                            : Icons.flash_off,
                          color: _isFlashOn
                              ? Colors.yellow // Color for Flash On icon
                              : Colors.white, // Color for Flash Off icon
                        ), // Add some spacing between the icon and text
                        Text(
                          _isFlashOn
                              ? 'Flash On'
                              : 'Flash Off',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isFlashOn
                                ? Colors.yellow // Color for Flash On text
                                : Colors.white, // Color for Flash Off text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Align(
              //   alignment: Alignment.center,
              //   child: Opacity(
              //     opacity: 0.9, // Adjust the opacity value as needed (0.0 to 1.0)
              //     child: Container(
              //       // margin:const EdgeInsets.only(top:20),
              //       width: MediaQuery.of(context).size.width, // Set the desired width
              //       height: MediaQuery.of(context).size.height, // Set the desired height
              //       child: Image.asset(
              //         'assets/image.png',
              //         fit: BoxFit.cover, // Set your desired BoxFit value
              //       ),
              //     ),
              //   ),
              // ),


              /// ZOOM IN OR ZOOM OUT  ////////////////////////////////////////////////////////////////////////////
              if (showZoomButton)
                widget.eqptType == 'Table' || widget.eqptType == 'Wall'?
                Align (
                  alignment: Alignment.bottomLeft,
                  child:RotatedBox(
                    quarterTurns: 3,
                    child:Container(
                      width: 300,
                      height: 50,
                      margin:const EdgeInsets.only(left:0),

                      child:Slider(
                        value: _currentZoomLevel,
                        min: _minAvailableZoom,
                        max: _maxAvailableZoom,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.white,
                        onChanged: (value) async {
                          setState(() {
                            _currentZoomLevel = value;
                          });
                          await cameraController!.setZoomLevel(value);
                        },
                      ),
                    ),
                  ),
                ):  Align(
                  alignment: Alignment.bottomCenter,
                  child:Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin:const EdgeInsets.only(bottom:90),

                    child:Slider(
                      value: _currentZoomLevel,
                      min: _minAvailableZoom,
                      max: _maxAvailableZoom,
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.white,
                      onChanged: (value) async {
                        setState(() {
                          _currentZoomLevel = value;
                        });
                        await cameraController!.setZoomLevel(value);
                      },
                    ),
                  ),
                ),

              if (showZoomButton)
                widget.eqptType == 'Table' || widget.eqptType == 'Wall' ?
                Align(
                  alignment: Alignment.centerLeft,
                  child:Container(
                    margin:  const EdgeInsets.only(left:40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text('${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ):Align(
                  alignment: Alignment.bottomCenter,
                  child:Container(
                    margin:  const EdgeInsets.only(bottom:130),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text('${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),


              /// EXPOSURE MODE ////////////////////////////////////////////////////////////////////////////
              if (showExposureButton)
                widget.eqptType == 'Table' || widget.eqptType == 'Wall' ?
                Align(
                  alignment: Alignment.bottomLeft,
                  child:RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      margin:  const EdgeInsets.only(left:10),
                      width: 300,
                      height: 50,
                      // color:Colors.amber,
                      child: Slider(
                        value: _currentExposureOffset,
                        min: _minAvailableExposureOffset,
                        max: _maxAvailableExposureOffset,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.white,
                        onChanged: (value) async {
                          setState(() {
                            _currentExposureOffset = value;
                          });
                          await cameraController!.setExposureOffset(value);
                        },
                      ),
                    ),
                  ),
                ) :  Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin:  const EdgeInsets.only(bottom:90),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    // color:Colors.amber,
                    child: Slider(
                      value: _currentExposureOffset,
                      min: _minAvailableExposureOffset,
                      max: _maxAvailableExposureOffset,
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.white,
                      onChanged: (value) async {
                        setState(() {
                          _currentExposureOffset = value;
                        });
                        await cameraController!.setExposureOffset(value);
                      },
                    ),
                  ),
                ),
              if (showExposureButton)
                widget.eqptType == 'Table' || widget.eqptType == 'Wall' ?
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin:  const EdgeInsets.only(left:40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${_currentExposureOffset.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ) :  Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin:  const EdgeInsets.only(bottom:130),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${_currentExposureOffset.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              /// /////////////////////////////////////////////////////////////////////////////////////////////////////////////

              /// Menu button --- Camera exposure,zoom,flash
              Align(
                alignment: Alignment.bottomRight, // Adjust alignment as needed
                child:Container(
                  margin: widget.eqptType == 'Table' || widget.eqptType == 'Wall'? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(right: 40,bottom: 30),
                  child: IconButton(
                    icon: const Icon(Icons.menu,color: Colors.white,),
                    onPressed: () {
                      _displayBottomSheet ();
                      // Your onPressed logic here
                    },
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    }
  }

  Future<void> _displayBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
          maxWidth: widget.eqptType == 'Table' || widget.eqptType == 'Wall' ? MediaQuery.of(context).size.width * 0.5 :MediaQuery.of(context).size.width
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SizedBox(
        height: widget.eqptType == 'Table' || widget.eqptType == 'Wall' ? 60 : 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 0),
              width:100,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_isFlashOn == false) {
                      _isFlashOn = true;
                      cameraController!.setFlashMode(FlashMode.always);
                    } else {
                      _isFlashOn = false;
                      cameraController!.setFlashMode(FlashMode.off);
                    }
                  });
                  Navigator.pop(context);
                  showExposureButton = false;
                  showZoomButton = false;
                  showOpacityButton = false;
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Set the background color to transparent
                  onPrimary: Colors.black, // Text color
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Set the border radius to zero for square shape
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isFlashOn
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: _isFlashOn
                          ? Colors.amber.shade900 // Color for Flash On icon
                          : Colors.black,
                      size: 30,
                    ), // Add some spacing between the icon and text
                    Text(
                      _isFlashOn
                          ? 'Flash On'
                          : 'Flash Off',
                      style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,
                        color: _isFlashOn
                            ? Colors.amber.shade900  // Color for Flash On text
                            : Colors.black, // Color for Flash Off text
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width:100,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showExposureButton = true;
                    showZoomButton = false;
                    showOpacityButton = false;

                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Set the background color to transparent
                  onPrimary: Colors.black, // Text color
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Set the border radius to zero for square shape
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exposure,size: 30,), // Add some spacing between the icon and text
                    Text('Exposure' , style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,
                      color: Colors.black, // Color for Flash Off text
                    ),
                    ),
                  ],
                ),

              ),
            ),
            SizedBox(
              width:100,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showZoomButton = true;
                    showExposureButton = false;
                    showOpacityButton = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Set the background color to transparent
                  onPrimary: Colors.black, // Text color
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Set the border radius to zero for square shape
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in,size: 30,), // Add some spacing between the icon and text
                    Text('Zoom' , style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,
                      color: Colors.black, // Color for Flash Off text
                    ),
                    ),
                  ],
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> fetchOverlayImage() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    final apiUrl = 'https://smh-app.trent-tata.com/flask/overlayimages/${widget.eqptName}.png';
    try {
      // Fetch the image data from the API
      final response = await ioClient.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          // Access the "image" field and set the image data
          imageUrl = data['base64_image'];
        });

      } else {
        // Handle error
        print('Error fetching image: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }



  ///Detecting ATTEMPT
  Future<void> _detectingATTEMPT() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    String formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    TimeOfDay formattedTime = TimeOfDay.fromDateTime(currentDate);
    String formattedTimeString = formattedTime.format(context);
    int hour = formattedTime.hour;

    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/get_which_attempt"),
          body: json.encode({"date":formattedDate.toString(), "equipment_id":widget.eqptId.toString(),"store_id":widget.stId.toString()}),
          headers: {
            "content-type": "application/json",
          });
      var AttemptResponse = jsonDecode(response.body);
      print("..............................\n"
          "Attempt..........Response..............$AttemptResponse");
      Attempt = AttemptResponse[0][0];
      Attempt = Attempt;

    } catch (e) {
      print(e.toString());
    }

    ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////
    //// MORNING ATTEMPT
    if(hour >= 8 && hour <= 14) {
      if (Attempt == null) {
        aTTempt = 1;
        setState(() {
          whichAttempt = 'MF';
          captureAttempt = aTTempt!;
        });
      }
      else if (Attempt == 1) {
        aTTempt = 2;
        setState(() {
          whichAttempt = 'MS';
          captureAttempt = aTTempt!;
        });

      }
      else {
        aTTempt = 2;
        ///Remove after testing Demo
        setState(() {
          whichAttempt = 'MS';
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
    else if(hour >= 15 && hour <= 22){
      if(Attempt == null || Attempt == 1) {
        if (Attempt == null) {
          aTTempt = 1;
          setState(() {
            whichAttempt = 'MF';
            captureAttempt = aTTempt!;
          });

        }
        else if (Attempt == 1) {
          aTTempt = 2;
          setState(() {
            whichAttempt = 'MS';
            captureAttempt = aTTempt!;
          });

        }
      }
      else {
        if (Attempt == 2) {
          //print("......hellooooooooooo");
          aTTempt = 3;
          if (!mounted) {
            return; // Avoid calling setState if the widget is disposed
          }
          setState(() {
            whichAttempt = 'EF';
            captureAttempt = aTTempt!;
            // print(".....................\n"
            //     "..........................."
            //     "............................."
            //     "..............captureAttemot..........$captureAttempt");
          });

        }
        else if (Attempt == 3) {
          aTTempt = 4;
          setState(() {
            whichAttempt = 'ES';
            captureAttempt = aTTempt!;
          });

        }
        else {
          ///Remove after testing Demo
          aTTempt = 4;
          setState(() {
            whichAttempt = 'ES';
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
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }


}


// ... DisplayImageScreen class ...
class CameraLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Loading Camera.." ,style: TextStyle(color: Colors.black),), // You can use any loading indicator here
    );
  }
}










/// display image preview


class DisplayCapturedImageScreen extends StatefulWidget {
  final List<String> imagePaths;
  final String filename;
  final String eqptId;
  final String eqptCode;
  final String eqptName;
  final String eqptNoOfSnaps;
  final String eqptType;
  final String stId;
  final String attempt;
  final String signageData;


  DisplayCapturedImageScreen({required this.imagePaths, required this.filename, required this.eqptId, required this.eqptCode,
    required this.eqptName, required this.eqptNoOfSnaps, required this.eqptType, required this. attempt, required this. stId, required this. signageData});

  @override
  _DisplayCapturedImageScreenState createState() =>
      _DisplayCapturedImageScreenState();
}

class _DisplayCapturedImageScreenState extends State<DisplayCapturedImageScreen> {
  int _selectedIndex = 0;

  bool _isLoading = false;
  List<List<int>> resizedImagesBytesList = [];
  String? equipType;
  String? beautyLabel;
  int? beautyCount;
  int beautyStatus = 1;
  int? preferenceBeautyCount;
  //Alice alice = Alice();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle button tap actions here
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VMCaptureImage(
                  filename: widget.filename,
                  eqptId: widget.eqptId,
                  eqptCode: widget.eqptCode,
                  eqptName: widget.eqptName,
                  eqptNoOfSnaps: widget.eqptNoOfSnaps,
                  eqptType: widget.eqptType,
                  stid: widget.stId,
                ),
          ),
        );
        break;
    // case 1:
    //   alice.showInspector();
    //  //cropTakenImages();
    //  break;
      case 1:
        if (widget.eqptType.toString() == 'Table') {
          _showTableCompliance();
        }
        else if (widget.eqptType.toString() == 'MensShorts') {
          _showMensShortsCompliance();
        }

        else if (widget.eqptType.toString() == 'Lipstick' || widget.eqptName.toString() == '2' || widget.eqptName.toString() == '3' ||
            widget.eqptName.toString() == '4' || widget.eqptName.toString() == '5' || widget.eqptName.toString() == '6' || widget.eqptName.toString() == '7' ||
            widget.eqptName.toString() == '8')
        {
          _showLipstickCompliance();
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
        else if (widget.eqptCode == 'MF1' || widget.eqptCode == 'MF2' || widget.eqptCode == 'MF3') {
          _showFootwearCompliance();
        }
        else if (widget.eqptCode == 'B&B-1'|| widget.eqptCode == 'B&B-2'|| widget.eqptCode == 'B&B-3'|| widget.eqptCode == 'B&B-4' ||
            widget.eqptCode == 'B&B-2-SIDE1'|| widget.eqptCode == 'B&B-2-SIDE2'|| widget.eqptCode == 'B&B-2-SIDE3'|| widget.eqptCode == 'B&B-2-SIDE4' ||
            widget.eqptCode == 'B&B-3-SIDE1'|| widget.eqptCode == 'B&B-3-SIDE2'|| widget.eqptCode == 'B&B-3-SIDE3'|| widget.eqptCode == 'B&B-3-SIDE4' ||
            widget.eqptCode == 'B&B-4-SIDE1'|| widget.eqptCode == 'B&B-4-SIDE2'|| widget.eqptCode == 'B&B-4-SIDE3'|| widget.eqptCode == 'B&B-4-SIDE4') {
          _showDeoAndPerfumeCompliance();
        }
        else if (widget.eqptType == 'WallTable') {
          _showWallTableCompliance();
        }
        else if (widget.eqptType.toString() == 'Mannequin')
        {
          _showMannequinCompliance();
        }
        else if (widget.eqptCode == 'M5') {
          _showWallComplianceJeanAndStack();
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
        else if (widget.eqptType == 'Kajal') {
          _showKajalCompliance();
        }
        _uploadMobImages();

        break;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Perform any necessary initialization tasks here
  }

  @override
  void dispose() {
    super.dispose();
  }





  ///uploadCapturedImages
  Future<void> _uploadMobImages() async {

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("SAVING IMAGES, PLEASE WAIT..."),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 1),
    ));
    if (widget.imagePaths == null) return;
    final url = Uri.parse('https://smh-app.trent-tata.com/flask/uploadMobImage');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    String name = widget.filename.toString();
    int index = 1;
    for (var imagePath in widget.imagePaths!) {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final fileName = '$name-${widget.attempt}-$index.png';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));
      request.fields['fileName$index'] = fileName;
      index++;
    }
    print("Sending ${widget.imagePaths!.length} images...");
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("SAVING SUCCESSFUL..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),

      ));
      _saveCaptureDetails();
      print("capture...attempt .................${widget.attempt}");
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("SAVING FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }

  }

  Future<void> _saveCaptureDetails() async {
    print("attempt...update ... ${widget.attempt}");
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/saveCapturedImageDetails"),
          body: json.encode({"store_id": widget.stId, "equipment_id": widget.eqptId, "image_path": widget.filename, "attempt": widget.attempt
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
  Future<void> insertAttemptIntoDetectedTable () async{
    print(widget.attempt);
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/update_attempt_into_vm_detected_table_latest"),
          body: json.encode({"storeId":widget.stId, "equipmentId": widget.eqptId, "attempt": widget.attempt
          }),
          headers: {
            "content-type": "application/json",
          });

      print('Response body: ${response.body}');
    } catch (e) {
      print(e.toString());
    }
  }


  /// update the DetectionStatus into vm_daily_images
  Future<void> insertDetectionStatusIntoVMdailyImages() async{
    print("//////////////////////////////////insertDetectionStatusIntoVMdailyImages//////////////////////${widget.attempt}");
    int detectionStatus = 0;
    if (widget.attempt == '1' || widget.attempt == '3')
    {
      detectionStatus = 1;
    }
    else if (widget.attempt == '2' || widget.attempt == '4')
    {
      detectionStatus = 2;
    }
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      final response = await ioClient.post(
          Uri.parse("https://smh-app.trent-tata.com/flask/update_detection_status"),
          body: json.encode({"store_id":widget.stId, "equipment_id": widget.eqptId, "detection_status": detectionStatus
          }),
          headers: {
            "content-type": "application/json",
          });

      print('Response body insertDetectionStatusIntoVMdailyImages : ${response.body}');
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



  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                widget.imagePaths.length,
                    (index) => Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight,
                    child: Image.file(
                      File(widget.imagePaths[index]),
                      fit: BoxFit.fill, // Fit the image within the container
                    ),
                  ),
                ),
              ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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

      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
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
          // BottomNavigationBarItem(
          //   backgroundColor: Colors.black87,
          //   icon: Icon(Icons.crop),
          //   label: 'Crop',
          // ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black87,
            icon: Icon(Icons.save),
            label: 'Submit',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }




  ///showTableCompliance
  Future<void> _showTableCompliance() async {
    try {
      setState(() {
        equipType = 'Table';
        _isLoading = true;
      });
      String storecode = widget.filename.split("-").first;
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);

      Uri urlget = Uri.parse("https://smh-app.trent-tata.com/flask/get_store_id/$storecode");
      var responseget = await ioClient.get(urlget);
     // alice.onHttpResponse(responseget);
      var storeResponse = jsonDecode(responseget.body);
      int Storeid = storeResponse[0]['id'];

      final url = Uri.parse('https://smh-app.trent-tata.com/flask/showTableCompliance');
      final request = http.MultipartRequest('POST', url);
      request.headers['Connection'] = 'Keep-Alive';


      int index = 1;
      List<File> imageFiles = widget.imagePaths!
          .map((path) => File(path))
          .toList();
      for (var imageFile in imageFiles) {
        final resizedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
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
        request.fields['signage'] = widget.signageData.toString();
        index++;
      }

      var response = await ioClient.send(request).timeout(const Duration(minutes: 2));
      // alice.onHttpResponse(response as http.Response);
     // alice.onHttpClientResponse(response as HttpClientResponse,request as HttpClientRequest);
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      String jobId = jsonResponse['job_id'];
      print('Job ID: $jobId');
      insertAttemptIntoDetectedTable();


      // if (response.statusCode != 200 && response.statusCode != 404) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   insertDetectionStatusIntoVMdailyImages();
      //   // ignore: use_build_context_synchronously
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("DETECTION FAILED"),
      //     backgroundColor: Colors.red,
      //     duration: Duration(seconds: 2),
      //   ));
      // }
      // else if (response.statusCode == 404) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   // ignore: use_build_context_synchronously
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("PLEASE RECAPTURE"),
      //     backgroundColor: Colors.red,
      //     duration: Duration(seconds: 2),
      //   ));
      // }
      // else {
      // }


      // Process the response data, e.g. display it in a new screen
      // final imageData = await response.stream.toBytes();
      // final archive = ZipDecoder().decodeBytes(imageData);
      //
      // // Sort the files in the archive based on their names numerically
      // final sortedFiles = archive.files.toList()
      //   ..sort((a, b) {
      //     final aNumeric = int.tryParse(a.name.replaceAll(RegExp('[^0-9]'), ''));
      //     final bNumeric = int.tryParse(b.name.replaceAll(RegExp('[^0-9]'), ''));
      //     if (aNumeric != null && bNumeric != null) {
      //       return aNumeric.compareTo(bNumeric);
      //     } else if (aNumeric != null) {
      //       return -1; // Place filenames with numeric values before non-numeric filenames
      //     } else if (bNumeric != null) {
      //       return 1; // Place filenames with numeric values after non-numeric filenames
      //     } else {
      //       return a.name.compareTo(b.name);
      //     }
      //   });
      //
      // final compressedImages = <Uint8List>[];
      // final imageFilenames = <String>[]; // List to store the filenames
      // for (var file in sortedFiles) {
      //   if (file.isFile) {
      //     final compressedImage = await FlutterImageCompress.compressWithList(
      //       file.content,
      //       quality: 100,
      //       // rotate: 90,
      //     );
      //     compressedImages.add(compressedImage!);
      //     imageFilenames.add(file.name); // Add filename to the list
      //   }
      // }
      //
      // final imageWidgets = compressedImages
      //     .map((compressedImage) => Image.memory(compressedImage))
      //     .toList();
      //
      // // ignore: use_build_context_synchronously
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         DetectedImage2(
      //           imageWidgets: imageWidgets,
      //           equipmentId: widget.eqptId,
      //           storeId: Storeid.toString(),
      //           takenImages: resizedImagesBytesList,
      //           equipType: equipType,
      //           filename: widget.filename,
      //           equipCode: widget.eqptCode,
      //           equipName: widget.eqptName,
      //           Snpshot: widget.eqptNoOfSnaps,
      //         ),
      //   ),
      // );
      Future.delayed(const Duration(seconds: 5), () {
        _checkTableComplianceStatus(jobId,  resizedImagesBytesList);
      });
    } catch (error) {
      print('Error: $error');
    }
  }
  // ignore: use_build_context_synchronously
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) =>
  //         tablesResult(
  //           takenImages: resizedImagesBytesList,
  //           equipType: equipType,
  //           eqId: widget.eqptId,
  //           stId: widget.stId,
  //         ),
  //   ),
  // );
  // Second API call
  Future<void> _checkTableComplianceStatus(String jobId, List<List<int>> resizedImagesBytesList, {int retryCount = 0}) async {
    const maxRetries = 15; // 12 retries * 5 seconds = 60 seconds

    // print(".......hello ... i am running....");
    try {
      final secondUrl = Uri.parse('https://smh-app.trent-tata.com/flask/checkTableComplianceStatus/$jobId');
      final secondResponse = await http.get(secondUrl);
     // alice.onHttpResponse(secondResponse);

      String responseString = secondResponse.body; // Store the response in a string variable

      if (responseString.contains("Task not finished.")) {
        if (retryCount < maxRetries) {
          //print('Task not finished. Waiting 5 seconds.... checking status again...');

          Future.delayed(const Duration(seconds: 5), () {
            _checkTableComplianceStatus(jobId, resizedImagesBytesList, retryCount: retryCount + 1);
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          //  print('Max retries reached. Task still not finished.');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("DETECTION FAILED"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        //  print('Task completed successfully. $responseString.');
        Map<String, dynamic> jsonResponse = json.decode(responseString);
        String statusValue = jsonResponse["status"];
        String filename = statusValue.split('/').last.trim();

        //  print("Filename: $filename");


        final apiUrl = Uri.parse('https://smh-app.trent-tata.com/flask/detected_zip_table_images/$filename');
        try {
          final response = await http.get(apiUrl);
         // alice.onHttpResponse(response);

          if (response.statusCode == 200) {
            final imageData = response.bodyBytes;
            final archive = ZipDecoder().decodeBytes(imageData);

            // Sort the files in the archive based on their names numerically
            archive.files.sort((a, b) {
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
            for (var file in archive.files) {
              try {
                if (file.isFile) {
                  final compressedImage = await FlutterImageCompress.compressWithList(
                    file.content,
                    quality: 100,
                    // rotate: 90,
                  );
                  if (compressedImage != null) {
                    compressedImages.add(compressedImage);
                    imageFilenames.add(file.name);
                  } else {
                    print('Failed to compress image for file: ${file.name}');
                  }
                }
              } catch (e) {
                print('Error processing file ${file.name}: $e');
              }
            }

            final imageWidgets = compressedImages
                .map((compressedImage) => Image.memory(compressedImage))
                .toList();
            // Navigate to the next screen with the processed images
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetectedImage2(
                      imageWidgets: imageWidgets,
                      equipmentId: widget.eqptId,
                      storeId: widget.stId.toString(),
                      takenImages: resizedImagesBytesList,
                      equipType: equipType,
                      filename: widget.filename,
                      equipCode: widget.eqptCode,
                      equipName: widget.eqptName,
                      Snpshot: widget.eqptNoOfSnaps,
                    ),
              ),
            );

          } else {
            print('Failed to fetch zip file. Status code: ${response.statusCode}');
          }
        } catch (error) {
          print('Error fetching zip file: $error');
        }
      }


    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error occurred while fetching status for Job ID $jobId from the second API: $error');
    }
  }









  /// show LipStick Compliance
  Future<void> _showLipstickCompliance() async {
    print("count..from api.........${widget.eqptName}");
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showLipstickCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int rotationValue = 0;
    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(const Duration(seconds: 180));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    // ignore: use_build_context_synchronously
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceJeanAndStack');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    // ignore: use_build_context_synchronously
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceStackAndJean');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceJeanAndFrontHangingWithGap');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceFrontFacingAndItemsWithGap');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles ) {
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

    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallComplianceSweaterAndStack');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    // ignore: use_build_context_synchronously
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
    if (widget.imagePaths == null) return;
    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMannequinCompliance');
    final request = http.MultipartRequest('POST', url);
    request.fields['storeId'] = Storeid.toString();
    request.fields['equipmentId'] = widget.eqptId.toString();
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
      request.fields['signage'] = widget.signageData.toString();
      index++;
    }

    // Send the request and get the response
    var responseStream = await ioClient.send(request).timeout(const Duration(seconds: 60));

    // Read the response stream
    var responseData = await responseStream.stream.toBytes();

    if(responseStream.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      print(".....................CALLING.........insertDetectionStatusIntoVMdailyImages.................");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
      setState(() {
        _isLoading = false;
      });
    }
    // Process the response data, e.g. display it in a new screen
    // final imageData = await response.stream.toBytes();
    final archive = ZipDecoder().decodeBytes(responseData);
    final imageWidgets = archive.files
        .where((file) => file.isFile)
        .map((file) => Image.memory(file.content))
        .toList();

    // Do something with the response data, e.g. display it in a new screen
    // ignore: use_build_context_synchronously
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMensShortsCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in  imageFiles) {

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
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showR2AndR4Compliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMrs1To10');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showMR7');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showWallTableCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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

    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;
    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showFootwearCompliance');
    final request = http.MultipartRequest('POST', url);
    request.fields['storeId'] = Storeid.toString();
    request.fields['equipmentId'] = widget.eqptId.toString();
    request.headers['Connection'] = 'Keep-Alive';
    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles ) {
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
    var response = await ioClient.send(request).timeout(
        const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showDeoAndPerfumeCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showNailpolishCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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


  ///showKajalCompliance
  Future<void> _showKajalCompliance() async {
    setState(() {
      equipType = 'Kajal';
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
    print("printing.....");
    print(Storeid);
    print("Calling MensShorts Compliance.......");
    if (widget.imagePaths == null) return;

    final url = Uri.parse('https://smh-app.trent-tata.com/flask/showKajalCompliance');
    final request = http.MultipartRequest('POST', url);
    request.headers['Connection'] = 'Keep-Alive';

    int index = 1;
    List<File> imageFiles = widget.imagePaths!.map((path) => File(path)).toList();
    for (var imageFile in imageFiles) {
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
    var response = await ioClient.send(request).timeout(const Duration(seconds: 60));
    print(response.statusCode);
    if(response.statusCode != 200)
    {
      setState(() {
        _isLoading = false;
      });
      insertDetectionStatusIntoVMdailyImages();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("DETECTION FAILED"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
    else{
      insertAttemptIntoDetectedTable ();
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
}




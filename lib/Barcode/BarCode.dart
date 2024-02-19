// // import 'package:camera/camera.dart';
// // import 'package:flutter/material.dart';
// //
// //
// // class CameraTextRecognition extends StatefulWidget {
// //
// //   @override
// //   _CameraTextRecognitionState createState() => _CameraTextRecognitionState();
// // }
// //
// // class _CameraTextRecognitionState extends State<CameraTextRecognition> {
// //   CameraController? _controller;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     WidgetsFlutterBinding.ensureInitialized();
// //     availableCameras().then((cameras) {
// //       final firstCamera = cameras.first;
// //       _controller = CameraController(firstCamera, ResolutionPreset.medium);
// //
// //       _controller!.initialize().then((_) {
// //         if (!mounted) {
// //           return;
// //         }
// //         setState(() {});
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller!.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_controller == null || !_controller!.value.isInitialized) {
// //       return Container();
// //     }
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Camera Text Recognition'),
// //       ),
// //       body: CameraPreview(_controller!),
// //     );
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
//
// class CameraTextRecognition extends StatelessWidget {
//   const CameraTextRecognition({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Text Recognition Flutter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
//   bool _isPermissionGranted = false;
//
//   late final Future<void> _future;
//   CameraController? _cameraController;
//
//   final textRecognizer = TextRecognizer();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _future = _requestCameraPermission();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopCamera();
//     textRecognizer.close();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }
//
//     if (state == AppLifecycleState.inactive) {
//       _stopCamera();
//     } else if (state == AppLifecycleState.resumed &&
//         _cameraController != null &&
//         _cameraController!.value.isInitialized) {
//       _startCamera();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _future,
//       builder: (context, snapshot) {
//         return Stack(
//           children: [
//             if (_isPermissionGranted)
//               FutureBuilder<List<CameraDescription>>(
//                 future: availableCameras(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     _initCameraController(snapshot.data!);
//                     return Center(child: CameraPreview(_cameraController!));
//                   } else {
//                     return const LinearProgressIndicator();
//                   }
//                 },
//               ),
//             Scaffold(
//               appBar: AppBar(
//                 title: const Text('Text Recognition Sample'),
//               ),
//               backgroundColor: _isPermissionGranted ? Colors.transparent : null,
//               body: _isPermissionGranted
//                   ? Column(
//                 children: [
//                   Expanded(
//                     child: Container(),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.only(bottom: 30.0),
//                     child: Center(
//                       child: ElevatedButton(
//                         onPressed: _scanImage,
//                         child: const Text('Scan text'),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//                   : Center(
//                 child: Container(
//                   padding: const EdgeInsets.only(left: 24.0, right: 24.0),
//                   child: const Text('Camera permission denied',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     _isPermissionGranted = status == PermissionStatus.granted;
//   }
//
//   void _startCamera() {
//     if (_cameraController != null) {
//       _cameraSelected(_cameraController!.description);
//     }
//   }
//
//   void _stopCamera() {
//     if (_cameraController != null) {
//       _cameraController?.dispose();
//     }
//   }
//
//   void _initCameraController(List<CameraDescription> cameras) {
//     if (_cameraController != null) {
//       return;
//     }
//
//     // Select the first rear camera.
//     CameraDescription? camera;
//     for (var i = 0; i < cameras.length; i++) {
//       final CameraDescription current = cameras[i];
//       if (current.lensDirection == CameraLensDirection.back) {
//         camera = current;
//         break;
//       }
//     }
//
//     if (camera != null) {
//       _cameraSelected(camera);
//     }
//   }
//
//   Future<void> _cameraSelected(CameraDescription camera) async {
//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.max,
//       enableAudio: false,
//     );
//
//     await _cameraController!.initialize();
//     await _cameraController!.setFlashMode(FlashMode.off);
//
//     if (!mounted) {
//       return;
//     }
//     setState(() {});
//   }
//
//
//   Future<void> _scanImage() async {
//     if (_cameraController == null) return;
//
//     final navigator = Navigator.of(context);
//     try {
//       final pictureFile = await _cameraController!.takePicture();
//       final file = File(pictureFile.path);
//
//       final imageBytes = await file.readAsBytes();
//       final image = await decodeImageFromList(imageBytes);
//       final totalHeight = image.height;
//       final totalWidth = image.width;
//
//       print("Total Height: $totalHeight");
//       print("Total Width: $totalWidth");
//
//
//       final inputImage = InputImage.fromFile(file);
//       final recognizedText = await textRecognizer.processImage(inputImage);
//       final jsonDataList = recognizedText.blocks
//           .where((block) => block.cornerPoints != null)
//           .map((block) {
//         final text = _extractNumbersFromText(block.text);
//         final cornerPoints = block.cornerPoints!; // Access corner points
//
//         if (text.isNotEmpty) {
//           return {
//             'Signage': text,
//             'CornerPoints': cornerPoints.map((point) {
//               return {'x': point.x, 'y': point.y};
//             }).toList(),
//           };
//         } else {
//           return null;
//         }
//       })
//           .where((element) => element != null)
//           .toList();
//
//       final jsonData = jsonEncode(jsonDataList);
//       print(jsonData);
//       // Show the captured image
//       final capturedImage = Image.file(file);
//       await navigator.push(
//         MaterialPageRoute(
//           builder: (BuildContext context) => ResultScreen(
//             capturedImage: capturedImage,
//             jsonDataList: List<Map<String, dynamic>>.from(jsonDataList),
//           ),
//         ),
//       );
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('An error occurred when scanning text'),
//         ),
//       );
//     }
//   }
//
//   String _extractNumbersFromText(String text) {
//     final RegExp regex = RegExp(r'\b\d{3}\b');
//     // Define a regex pattern for digits
//     final Iterable<Match> matches = regex.allMatches(text); // Find all matches in the text
//     final List<String> numbersList = matches
//         .map((match) {
//       String number = match.group(0)!;
//       if (number.length > 3) {
//         number = number.substring(0, 3); // Limit to the first three digits
//       }
//       return number;
//     })
//         .toList();
//     // Join the numbers with commas
//     final formattedText = numbersList.join(', ');
//     return formattedText;
//   }
// }
//
//
// class ResultScreen extends StatelessWidget {
//   final Image capturedImage;
//   final List<Map<String, dynamic>> jsonDataList;
//
//   ResultScreen({required this.capturedImage, required this.jsonDataList});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Result Screen'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: CustomPaint(
//               painter: TextRectanglesPainter(capturedImage, jsonDataList),
//               child: capturedImage,
//             ),
//           ),
//           // Add other widgets or controls as needed
//         ],
//       ),
//     );
//   }
// }
//
// class TextRectanglesPainter extends CustomPainter {
//   final Image capturedImage;
//   final List<Map<String, dynamic>> jsonDataList;
//
//   TextRectanglesPainter(this.capturedImage, this.jsonDataList);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final imageStream = capturedImage.image.resolve(ImageConfiguration.empty);
//     imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
//       final imageSize = info.image;
//       final imageWidth = imageSize.width.toDouble();
//       final imageHeight = imageSize.height.toDouble();
//
//       final scalingFactor = Size(
//         size.width / imageSize.width,
//         size.height / imageSize.height,
//       );
//
//       final paint = Paint()
//         ..color = Colors.red
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2.0; // Adjust as needed
//
//       for (final data in jsonDataList) {
//         if (data['CornerPoints'] != null) {
//           final List<Map<String, dynamic>> cornerPoints = data['CornerPoints'];
//
//           for (var i = 0; i < cornerPoints.length; i++) {
//             final x1 = cornerPoints[i]['x'] * scalingFactor.width;
//             final y1 = cornerPoints[i]['y'] * scalingFactor.height;
//
//             final x2 = cornerPoints[(i + 1) % 4]['x'] * scalingFactor.width;
//             final y2 = cornerPoints[(i + 1) % 4]['y'] * scalingFactor.height;
//
//             canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), paint);
//           }
//         }
//       }
//     }));
//   }
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
//
//
//
//
//
// // Future<void> _scanImage() async {
// //   if (_cameraController == null) return;
// //
// //   final navigator = Navigator.of(context);
// //   try {
// //     final pictureFile = await _cameraController!.takePicture();
// //     final file = File(pictureFile.path);
// //
// //     final imageBytes = await file.readAsBytes();
// //     final image = await decodeImageFromList(imageBytes);
// //     final totalHeight = image.height;
// //     final totalWidth = image.width;
// //
// //     print("Total Height: $totalHeight");
// //     print("Total Width: $totalWidth");
// //     final inputImage = InputImage.fromFile(file);
// //     final recognizedText = await textRecognizer.processImage(inputImage);
// //     final jsonDataList = recognizedText.blocks
// //         .where((block) => block.cornerPoints != null)
// //         .map((block) {
// //       final text = _extractNumbersFromText(block.text);
// //       final cornerPoints = block.cornerPoints!; // Access corner points
// //
// //       if (text.isNotEmpty) {
// //         return {
// //           'Signage': text,
// //           'CornerPoints': cornerPoints.map((point) {
// //             return {'x': point.x, 'y': point.y};
// //           }).toList(),
// //         };
// //       } else {
// //         return null;
// //       }
// //     })
// //         .where((element) => element != null)
// //         .toList();
// //
// //     final jsonData = jsonEncode(jsonDataList);
// //     print(jsonData); // Print the JSON representation of all blockData
// //
// //     // Show the captured image
// //     final capturedImage = Image.file(file);
// //     await navigator.push(
// //       MaterialPageRoute(
// //         builder: (BuildContext context) => ResultScreen(
// //           text: "jjn",
// //           capturedImage: capturedImage,
// //         ),
// //       ),
// //     );
// //   } catch (e) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('An error occurred when scanning text'),
// //       ),
// //     );
// //   }
// // }
//
//
// //  String text = _extractNumbersFromText(recognizedText.text);
// // for (TextBlock block in recognizedText.blocks) {
// //   final Rect rect = block.boundingBox;
// //   final List<Point<int>> cornerPoints = block.cornerPoints;
// //   final String text = block.text;
// //   final List<String> languages = block.recognizedLanguages;
// //
// //   print("Text: $text");
// //   print("Corner Points:");
// //   for (Point<int> point in cornerPoints) {
// //     print("X: ${point.x}, Y: ${point.y}");
// //   }
// //
// //   for (TextLine line in block.lines) {
// //     // Same getters as TextBlock
// //     for (TextElement element in line.elements) {
// //       // Same getters as TextBlock
// //     }
// //   }
// // }
//
//
//
//
//
//
//
// // Future<void> _scanImage() async {
// //   if (_cameraController == null) return;
// //
// //   final navigator = Navigator.of(context);
// //   try {
// //     final pictureFile = await _cameraController!.takePicture();
// //     final file = File(pictureFile.path);
// //
// //     final imageBytes = await file.readAsBytes();
// //     final image = await decodeImageFromList(imageBytes);
// //     final totalHeight = image.height;
// //     final totalWidth = image.width;
// //
// //     print("Total Height: $totalHeight");
// //     print("Total Width: $totalWidth");
// //
// //     final inputImage = InputImage.fromFile(file);
// //
// //     final resizedImage = await FlutterImageCompress.compressWithFile(
// //       file.path,
// //       minWidth: 1024,
// //       minHeight: 1024,
// //       quality: 100,
// //     );
// //
// //     if (resizedImage == null) {
// //       throw Exception("Image compression failed");
// //     }
// //
// //     final resizedFile = File('path_to_save_compressed_image.jpg');
// //     await resizedFile.writeAsBytes(resizedImage);
// //
// //     final resizedImageBytes = await resizedFile.readAsBytes();
// //     final resizedImageDimensions = await decodeImageFromList(resizedImageBytes);
// //     final resizedHeight = resizedImageDimensions.height;
// //     final resizedWidth = resizedImageDimensions.width;
// //     print(resizedHeight);
// //     print(resizedWidth);
// //
// //
// //     final recognizedText = await textRecognizer.processImage(inputImage);
// //
// //     final jsonDataList = recognizedText.blocks
// //         .where((block) => block.cornerPoints != null)
// //         .map((block) {
// //       final text = _extractNumbersFromText(block.text);
// //       final cornerPoints = block.cornerPoints!.map((point) {
// //         final x = (point.x / totalWidth) * resizedHeight; // Assuming new width is 1024
// //         final y = (point.y / totalHeight) * resizedWidth;
// //         return {'x': x, 'y': y};
// //       }).toList();
// //
// //       if (text.isNotEmpty) {
// //         return {
// //           'Signage': text,
// //           'CornerPoints': cornerPoints,
// //         };
// //       } else {
// //         return null;
// //       }
// //     }).where((element) => element != null).toList();
// //
// //     final jsonData = jsonEncode(jsonDataList);
// //     print(jsonData);
// //
// //     final capturedImage = Image.file(resizedFile);
// //
// //     await navigator.push(
// //       MaterialPageRoute(
// //         builder: (BuildContext context) => ResultScreen(
// //           text: "jjn",
// //           capturedImage: capturedImage,
// //         ),
// //       ),
// //     );
// //   } catch (e) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('An error occurred when scanning text'),
// //       ),
// //     );
// //   }
// // }
//
// // final inputImage = InputImage.fromFile(file);
// // final recognizedText = await textRecognizer.processImage(inputImage);
// // final jsonDataList = recognizedText.blocks
// //     .where((block) => block.cornerPoints != null)
// //     .map((block) {
// //   final text = _extractNumbersFromText(block.text);
// //   final cornerPoints = block.cornerPoints!; // Access corner points
// //
// //   // Scale down corner points based on new image dimensions
// //   final scaledCornerPoints = cornerPoints.map((point) {
// //     final x = (point.x / totalWidth) * 1024; // Assuming new width is 1024
// //     final y = (point.y / totalHeight) * 1024; // Assuming new height is 1024
// //     return {'x': x, 'y': y};
// //   }).toList();
// //
// //   if (text.isNotEmpty) {
// //     return {
// //       'Signage': text,
// //       'CornerPoints': scaledCornerPoints,
// //     };
// //   } else {
// //     return null;
// //   }
// // })
// //     .where((element) => element != null)
// //     .toList();
// //
// // final jsonData = jsonEncode(jsonDataList);
// // print(jsonData);
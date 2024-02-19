import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:image/image.dart' as img;

class tempImage extends StatefulWidget {
  const tempImage({Key? key, required this.takenImages, required this. equipType, required this. eqId, required this. stId}) : super(key: key);
  final List<List<int>> takenImages;
  final String? equipType;
  final String? eqId;
  final String? stId;

  @override
  State<tempImage> createState() => _tempImageState();
}

class _tempImageState extends State<tempImage> {
  List<Size>? imageDimensions;
  @override
  void initState() {
    super.initState();
    imageDimensions = List.filled(widget.takenImages.length, Size.zero);

    // Load image dimensions for each image
    for (int i = 0; i < widget.takenImages.length; i++) {
      _getImageDimensions(i);
    }
  }
  List<int> parsePositions(String positionsString) {
    List<String> positionList = positionsString.split(', ');
    return positionList.map((position) => int.parse(position)).toList();
  }

  Future<List<BoundingBox>> fetchBoundingBoxes() async {
    try {
      HttpClient client = HttpClient(context: await globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/get_compliance_for_text/257/234");
        //("https://smh-app.trent-tata.com/flask/get_compliance_for_text/${widget.stId}/${widget.eqId}/${widget.equipType}");
      var response = await ioClient.get(url);

      if (response.statusCode == 200) {
        var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
        int counter = 1; // Initialize the counter
        List<BoundingBox> boundingBoxes = resultsJson.map<BoundingBox>((json) {
          List<int> positionValues = parsePositions(json["positions"]);
          //List<int> signagePositionValues = parsePositions(json["signagePositions"]);

          BoundingBox boundingBox = BoundingBox(
            positionLeft: positionValues[0]?.toDouble() ?? 0.0,
            positionTop: positionValues[1]?.toDouble() ?? 0.0,
            positionRight: positionValues[2]?.toDouble() ?? 0.0,
            positionBottom: positionValues[3]?.toDouble() ?? 0.0,
            positionWidth: positionValues[4]?.toDouble() ?? 0.0,
            positionHeight: positionValues[5]?.toDouble() ?? 0.0,
            // signageLeft: signagePositionValues[0]?.toDouble() ?? 0.0,
            // signageTop: signagePositionValues[1]?.toDouble() ?? 0.0,
            // signageRight: signagePositionValues[2]?.toDouble() ?? 0.0,
            // signageBottom: signagePositionValues[3]?.toDouble() ?? 0.0,
            // signageWidth: signagePositionValues[4]?.toDouble() ?? 0.0,
            // signageHeight: signagePositionValues[5]?.toDouble() ?? 0.0,
            equipType: widget.equipType.toString(),
            count: counter.toString(),
            product: json["product"],
            position: json["position"],
            size_ratio: json["size_ratio"],
            detected_quantity: json["detected_quantity"],
            color: json["color"],
            status: json["status"],
            product_code: json["product_code"],
          );

          counter++; // Increment the counter for the next iteration
          return boundingBox;
        }).toList();

        return boundingBoxes;
      } else {
        // Handle HTTP error (e.g., display an error message)
        print("HTTP Error: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      // Handle other errors (e.g., network issues, JSON decoding issues)
      print("Error: $error");
      return [];
    }
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<void> _getImageDimensions(int index) async {
    final ByteData data = ByteData.sublistView(Uint8List.fromList(widget.takenImages[index]));
    final ui.Codec codec = await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Update the state with the image dimensions
    setState(() {
      imageDimensions?[index] = Size(frameInfo.image.width.toDouble(), frameInfo.image.height.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<BoundingBox>>(
        future: fetchBoundingBoxes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle errors
            return Text('Error: ${snapshot.error}');
          } else {
            List<BoundingBox> boundingBoxes = snapshot.data ?? [];
            final double phoneHeight = MediaQuery.of(context).size.height;
            final double phoneWidth = MediaQuery.of(context).size.width;

            return ListView.builder(

              itemCount: widget.takenImages.length,
              itemBuilder: (context, index) {
                final ui.Size? dimensions = imageDimensions?[index];

                // Print the height and width of each image
               // print('Image $index - Width: ${dimensions?.width}, Height: ${dimensions?.height}');


                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: FittedBox(
                          fit: BoxFit.fill, // Choose the fit mode according to your needs
                          child: Image.memory(Uint8List.fromList(widget.takenImages[index])),
                        ),
                      ),

                      CustomPaint(
                        painter: BoundingBoxPainter(boundingBoxes,phoneWidth,phoneHeight,dimensions!.width,dimensions!.height),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class BoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> boundingBoxes;
  final double sourceWidth;
  final double sourceHeight;
  final double targetWidth ;
  final double targetHeight;

  BoundingBoxPainter(this.boundingBoxes, this.targetWidth, this.targetHeight, this.sourceWidth, this.sourceHeight);

  @override
  void paint(Canvas canvas, Size size) {
    double widthScale = targetWidth / sourceWidth;
    double heightScale = targetHeight / sourceHeight;

    for (BoundingBox boundingBox in boundingBoxes) {
      // Scale the coordinates from the source image size to the target image size for positions
      double positionLeft = boundingBox.positionLeft * widthScale;
      double positionTop = boundingBox.positionTop * heightScale;
      double positionRight = boundingBox.positionRight * widthScale;
      double positionBottom = boundingBox.positionBottom * heightScale;
      double positionWidth = boundingBox.positionWidth * widthScale;
      double positionHeight = boundingBox.positionHeight * heightScale;

      // Scale the coordinates from the source image size to the target image size for SignagePositions
      // double signageLeft = boundingBox.signageLeft * widthScale;
      // double signageTop = boundingBox.signageTop * heightScale;
      // double signageRight = boundingBox.signageRight * widthScale;
      // double signageBottom = boundingBox.signageBottom * heightScale;
      // double signageWidth = boundingBox.signageWidth * widthScale;
      // double signageHeight = boundingBox.signageHeight * heightScale;

      // Define Paint objects for drawing the bounding boxes
      Paint positionBoxPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.0;

      Paint signageBoxPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw the bounding boxes on the canvas
      canvas.drawRect(Rect.fromLTRB(positionLeft, positionTop, positionRight, positionBottom), positionBoxPaint);
      //canvas.drawRect(Rect.fromLTRB(signageLeft, signageTop, signageRight, signageBottom), signageBoxPaint);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text:boundingBox.status == 1 ? '✔' : '✘',
          //boundingBox.count,
          style:  TextStyle(
              color: boundingBox.status == 1 ? Colors.green : Colors.red,
              fontSize: 30.0,
              fontWeight: FontWeight.bold
          ),
          children: [
            for (String line in boundingBox.product_code.split('\n'))
              TextSpan(
                text: '\n${boundingBox.count} ',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextSpan(
                text: '\nProduct: ${boundingBox.product == 1 ? 'Yes' : 'No'} ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            TextSpan(
              text: '\nPosition: ${boundingBox.position == 1 ? 'Yes' : 'No'}',
              style: const TextStyle(
                color: Colors.white,
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold
              ),
            ),
            TextSpan(
              text: '\nColor: ${boundingBox.color == 1 ? 'Yes' : 'No'}',
              style: const TextStyle(
                color: Colors.white,
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Layout the text
      textPainter.layout();
      double padding = 2.0;
      // Set the position for the text
      double textX = positionLeft + 10 ;
      double textY = positionTop + 30;


      Rect textBackgroundRect = Rect.fromPoints(
        Offset(textX - padding, textY - padding),
        Offset(textX + textPainter.width + padding, textY + textPainter.height + padding),
      );
      Paint textBackgroundPaint = Paint()..color = Colors.black54;
      canvas.drawRect(textBackgroundRect, textBackgroundPaint);

     // Draw a border around the text with a different color
      Paint borderPaint = Paint()
        ..color = Colors.black54 // Choose the border color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0; // Choose the border width

      if (boundingBox.status == 1) {
        borderPaint.color = Colors.green;
      } else if (boundingBox.status == 3) {
        borderPaint.color = Colors.red;
      } else {
        // Set a default color (e.g., white) for other statuses
        borderPaint.color = Colors.white;
      }
      canvas.drawRect(textBackgroundRect, borderPaint);
      // Draw the text inside the bounding box with padding
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class BoundingBox {
  final double positionLeft;
  final double positionRight;
  final double positionTop;
  final double positionBottom;
  final double positionWidth;
  final double positionHeight;
  // final double signageLeft;
  // final double signageRight;
  // final double signageTop;
  // final double signageBottom;
  // final double signageWidth;
  // final double signageHeight;
  final String count;
  final String equipType;
  final String product_code;
  final int color;
  final int detected_quantity;
  final int position;
  final int product;
  final int size_ratio;
  final int status;


  BoundingBox({
    required this.positionLeft,
    required this.positionRight,
    required this.positionTop,
    required this.positionBottom,
    required this.positionWidth,
    required this.positionHeight,
    // required this.signageLeft,
    // required this.signageRight,
    // required this.signageTop,
    // required this.signageBottom,
    // required this.signageWidth,
    // required this.signageHeight,
    required this.count,
    required this.color,
    required this.detected_quantity,
    required this.position,
    required this.product,
    required this.size_ratio,
    required this.status,
    required this.product_code,
    required this.equipType,

  });
}
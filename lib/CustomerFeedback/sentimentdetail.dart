import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SentimentDetail extends StatefulWidget {
  final String feedbacktype;
  final String storeid;
  final String year;
  final String month;
  final String sentimentname;
  final String sentimenttype;

  SentimentDetail({
    required this.feedbacktype,
    required this.storeid,
    required this.year,
    required this.month,
    required this.sentimentname, 
    required this.sentimenttype,
  });

  @override
  _SentimentDetailState createState() => _SentimentDetailState();
}

class _SentimentDetailState extends State<SentimentDetail> {
  List<dynamic> data = [];
  List<dynamic> alldata = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final url = (widget.feedbacktype == "BILLING")
        ? Uri.parse('https://smh-app.trent-tata.com/flask/getBillingSentiments/${widget.storeid}/${widget.year}/${widget.month}')
        : Uri.parse('https://smh-app.trent-tata.com/flask/getTrialRoomSentiments/${widget.storeid}/${widget.year}/${widget.month}');
    var response = await ioClient.get(url);
    var resultJson = json.decode(response.body);
    print("$resultJson.........fetchdata");
    if (response.statusCode == 200) {
      setState(() {
        alldata = jsonDecode(response.body);
        (widget.sentimenttype == 'total')
        ? data = alldata.where((ad) => 
        ad['waiting_time'] == widget.sentimentname ||
        ad['billing_time'] == widget.sentimentname ||
        ad['staff_behaviour'] == widget.sentimentname
        ).toList()
        : data = alldata.where((ad) => ad[widget.sentimenttype] == widget.sentimentname).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Sentiment Detail'),
      // ),
      appBar: AppBar(title: const Text(
          'Sentiment Detail', style: TextStyle(fontSize: 16,color: Colors.white)),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();

            },
            icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),

        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 50.2,
        toolbarOpacity: 0.8,
        backgroundColor: Colors.black,
        elevation: 0.00,
      ),
      body:SingleChildScrollView(
      child:Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DataTable(
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Visit Feedback')),
        DataColumn(label: Text('Feedback')),
        DataColumn(label: Text('Details')),
      ],
      rows: data
          .asMap()
          .map(
            (index, item) => MapEntry(
              index,
              DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(item['visit_feedback'] ?? 'N/A')),
                  DataCell(Text(item['feedback'] ?? 'N/A')),
                  DataCell(Text(item['details'] ?? 'N/A')),
                ],
              ),
            ),
          )
          .values
          .toList(),
    ),
          ],
        ),
      ),
      )
    );
  }
}

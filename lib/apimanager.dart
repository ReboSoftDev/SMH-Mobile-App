import 'dart:convert';

import 'package:sample/model.dart';
import 'package:http/http.dart' as http;

class ApiManager {
///popup compliance ///
  Future<List<PopupCompliance>> fetchData() async {
    // geting response from API.
    var response =
    await http.get(Uri.parse("http://192.168.52.231:5000/get_vm_guideline_vs_detected/1/1"));
    // checking if Get request is successful by 200 status.
    if (response.statusCode == 200) {
      // decoding recieved string data into JSON data.
      var result = jsonDecode(response.body);
      // getting only Contries data from whole covid data which we convert into json.
      List jsonResponse = result["productRows"] as List;
      print("popup data.................");
      print(jsonResponse);

      // return list by maping it with Country class.
      return jsonResponse.map((e) => PopupCompliance.fromJson(e)).toList();
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  ///dropdown api fethching////

  // Future<List<UserModel>> getData(filter) async {
  //   var response = await Dio().get("http://192.168.52.231:5000/get_all_equipments",
  //     queryParameters: {"filter": filter},
  //   );
  //   print("success dropdown");
  //
  //   final data = response.data;
  //   print(response.data);
  //   if (data != null) {
  //     return UserModel.fromJsonList(data);
  //   }
  //
  //   return [];
  // }
}








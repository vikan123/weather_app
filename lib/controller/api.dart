import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:whether_app/modal/weather.dart';





class APICallProvider with ChangeNotifier {



  bool _dataIsAvailable=false;
  get dataIsAvailable=>dataIsAvailable;
  set dataIsAvailable(value)
  {
    _dataIsAvailable=value;
    notifyListeners();
  }
  Future fetchApiData(String city) async {
    var response = await http.get(Uri.parse(
        'https://api.tomorrow.io/v4/weather/forecast?location=$city&apikey=AbttBN72a24jcYAJKFrBxgzOw1G1qEoo'));
    print(response.body);
    var x1 = jsonDecode(response.body);
    return WeatherResponseModel.fromJson(x1);
  }
}
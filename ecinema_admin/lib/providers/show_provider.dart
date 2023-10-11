import 'dart:convert';

import 'package:ecinema_admin/models/shows.dart';
import '../helpers/constants.dart';
import '../utils/authorzation.dart';
import 'base_provider.dart';
import 'package:http/http.dart' as http;

class ShowProvider extends BaseProvider<Shows> {
  ShowProvider() : super('Show/GetPaged');

  Future<List<Shows>> getPaged(int cinemaId) async {
    var uri = Uri.parse('$apiUrl/Show/GetPaged?cinemaId=${cinemaId}');
    var headers = Authorization.createHeaders();
    print(uri);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var items=data['items'];
      return items.map((d) => fromJson(d)).cast<Shows>().toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Shows fromJson(data) {
    return Shows.fromJson(data);
  }
}

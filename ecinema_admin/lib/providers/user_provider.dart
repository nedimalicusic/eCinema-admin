import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import '../helpers/constants.dart';
import '../models/user.dart';
import '../utils/authorzation.dart';
import 'base_provider.dart';

class UserProvider extends BaseProvider<User>  {
  UserProvider() : super('User/GetPaged');
  User? user;

  @override
  Future<List<User>> get(Map<String, String>? params) async {
    var uri = Uri.parse('$apiUrl/User/GetPaged');
    var headers = Authorization.createHeaders();
    if (params != null) {
      uri = uri.replace(queryParameters: {'name': params.values});
    }
    final response = await http.get(uri, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var items=data['items'];
      return items.map((d) => fromJson(d)).cast<User>().toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<dynamic> insert(dynamic resource) async {
    var uri = Uri.parse('$apiUrl/User');
    Map<String, String> headers = Authorization.createHeaders();

    var jsonRequest = jsonEncode(resource);
    print(jsonRequest);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception('Greška prilikom unosa');
    }
  }

  Future<dynamic> edit(dynamic resource) async {
    var uri = Uri.parse('$apiUrl/User');
    Map<String, String> headers = Authorization.createHeaders();

    var jsonRequest = jsonEncode(resource);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception('Greška prilikom unosa');
    }
  }

  Future<dynamic> delete(int id) async {
    var uri = Uri.parse('$apiUrl/User/${id}');
    Map<String, String> headers = Authorization.createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception('Greška prilikom unosa');
    }
  }

  @override
  Future<User> getById(int id) async {
    var uri = Uri.parse('$apiUrl/User/$id');

    var headers = Authorization.createHeaders();

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      return fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> insertUser(Map<String, dynamic> userData) async {
    try {
      var uri = Uri.parse('$apiUrl/User');
      Map<String, String> headers = Authorization.createHeaders();

      var request = http.MultipartRequest('POST', uri);

      var stringUserData = userData.map((key, value) => MapEntry(key, value.toString()));

      request.fields.addAll(stringUserData);

      if (userData.containsKey('ProfilePhoto')) {
        request.files.add(userData['ProfilePhoto']);
      }

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        return "OK";
      } else {
        throw Exception('Error inserting user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error inserting user: $e');
    }
  }

  Future<dynamic> updateUser(Map<String, dynamic> updatedUserData) async {
    try {
      var uri = Uri.parse('$apiUrl/User');
      Map<String, String> headers = Authorization.createHeaders();

      var request = http.MultipartRequest('PUT', uri);

      var stringUpdatedUserData = updatedUserData.map((key, value) => MapEntry(key, value.toString()));

      request.fields.addAll(stringUpdatedUserData);

      if (updatedUserData.containsKey('ProfilePhoto')) {
        request.files.add(updatedUserData['ProfilePhoto']);
      }

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        return "OK";
      } else {
        throw Exception('Error updating user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }


  @override
  fromJson(data) {
    return User.fromJson(data);
  }
}
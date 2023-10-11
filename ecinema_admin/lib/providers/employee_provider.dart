import 'dart:convert';

import 'package:ecinema_admin/models/employee.dart';

import '../helpers/constants.dart';
import '../utils/authorzation.dart';
import 'base_provider.dart';
import 'package:http/http.dart' as http;

class EmployeeProvider extends BaseProvider<Employee> {
  EmployeeProvider() : super('Employee/GetPaged');

  Future<List<Employee>> getPaged(int cinemaId) async {
    var uri = Uri.parse('$apiUrl/Employee/GetPaged?cinemaId=${cinemaId}');
    var headers = Authorization.createHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var items=data['items'];
      return items.map((d) => fromJson(d)).cast<Employee>().toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Employee fromJson(data) {
    return Employee.fromJson(data);
  }
}

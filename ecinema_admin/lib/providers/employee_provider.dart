import 'package:ecinema_admin/models/employee.dart';

import 'base_provider.dart';

class EmployeeProvider extends BaseProvider<Employee> {
  EmployeeProvider() : super('Employee/GetPaged');

  @override
  Employee fromJson(data) {
    return Employee.fromJson(data);
  }
}

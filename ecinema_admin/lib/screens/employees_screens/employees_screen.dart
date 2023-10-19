
import 'package:ecinema_admin/models/employee.dart';
import 'package:ecinema_admin/providers/employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cinema.dart';
import '../../providers/cinema_provider.dart';
import '../../utils/error_dialog.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> employees = <Employee>[];
  late EmployeeProvider _employeeProvider;
  late CinemaProvider _cinemaProvider;
  List<Cinema> cinemaList = <Cinema>[];
  int? selectedCinema;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int? selectedGender;
  int? selectedCinemaId;
  bool _isActive=false;
  @override
  void initState() {
    super.initState();
    _employeeProvider=context.read<EmployeeProvider>();
    _cinemaProvider=context.read<CinemaProvider>();
    loadCinema();
  }

  void loadCinema() async {
    try {
      var cinemasResponse = await _cinemaProvider.get(null);
      setState(() {
        cinemaList = cinemasResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void loadEmployees(int cinemaId) async {
    try {
      var employeesResponse = await _employeeProvider.getPaged(cinemaId);
      setState(() {
        employees = employeesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertEmployee() async {
    try {
      var newEmployee = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "email":_emailController.text,
        "birthDate": _birthDateController.text,
        "gender": selectedGender,
        "cinemaId":selectedCinemaId,
        "isActive":_isActive
      };
      var employee = await _employeeProvider.insert(newEmployee);
      if (employee == "OK") {
        Navigator.of(context).pop();
        loadEmployees(selectedCinemaId!);
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditEmployee(int id) async {
    try {
      var newEmployee = {
        "id":id,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "email":_emailController.text,
        "birthDate": _birthDateController.text,
        "gender": selectedGender,
        "cinemaId":selectedCinemaId,
        "isActive":_isActive
      };
      var employee = await _employeeProvider.edit(newEmployee);
      if (employee == "OK") {
        Navigator.of(context).pop();
        loadEmployees(selectedCinemaId!);
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteEmployee(int id) async {
    try {
      var employee = await _employeeProvider.delete(id);
      if (employee == "OK") {
        Navigator.of(context).pop();
        loadEmployees(1);
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Employees"),
      ),
      body: Center(
        child: Container(
          width: 1300,
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 500,
                    child: Padding(
                      padding: EdgeInsets.only(left: 136, top: 8, right: 8), // Margine za input polje
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: 'Izaberite kino',
                        ),
                        value: selectedCinema,
                        items: cinemaList.map((Cinema cinema) {
                          return DropdownMenuItem<int>(
                            value: cinema.id,
                            child: Text(cinema.name),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedCinema = newValue;
                          });
                          loadEmployees(selectedCinema!); // Pozovite funkciju sa odabranim kinom
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, right: 146), // Margine za dugme "Dodaj"
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Dodaj radnika'),
                              content: SingleChildScrollView(
                                child: AddEmployeeForm(),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Zatvori'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      InsertEmployee();
                                    }
                                  },
                                  child: Text('Spremi'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Dodaj"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDataListView()
            ],
          ),
        ),
      ),
    );
  }

  Widget AddEmployeeForm({bool isEditing = false, Employee? employeeToEdit}) {
    if (employeeToEdit != null) {
      _firstNameController.text = employeeToEdit.firstName ?? '';
      _lastNameController.text = employeeToEdit.lastName ?? '';
      _emailController.text = employeeToEdit.email ?? '';
      _birthDateController.text = employeeToEdit.birthDate ?? '';
      selectedCinemaId=employeeToEdit.cinemaId;
      selectedGender=employeeToEdit.gender;
      _isActive=employeeToEdit.isActive;
    } else {
      _firstNameController.text = '';
      _lastNameController.text = '';
      _emailController.text = '';
      _birthDateController.text = '';
      selectedGender=null;
      selectedCinemaId=null;
      _isActive=false;
    }

    return Container(
      height: 450,
      width: 900,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            SizedBox(width: 30,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedCinemaId, // Postavite odabrani grad (ID)
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedCinemaId = newValue;
                      });
                    },
                    items: cinemaList.map((Cinema cinema) {
                      return DropdownMenuItem<int>(
                        value: cinema.id, // Ovdje postavite ID grada
                        child: Text(cinema.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Kino'),
                    validator: (value) {
                      if (value == null) {
                        return 'Odaberite kino!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'Ime'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite ime!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Prezime'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite prezime!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite email!';
                      }
                      final emailPattern = RegExp(r'^\w+@[\w-]+(\.[\w-]+)+$');
                      if (!emailPattern.hasMatch(value)) {
                        return 'Unesite ispravan gmail email!';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 30,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _birthDateController,
                    decoration: InputDecoration(
                      labelText: 'Datum',
                      hintText: 'Odaberite datum', // Dodajte hintText ovde
                    ),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2101),
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite datum!';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedGender,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGender = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Odaberi spol'),
                      ),
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Muški'),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('Ženski'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Spol',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Unesite spol!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Checkbox(
                        value:_isActive,
                        onChanged: (bool? value) {
                          _isActive=!_isActive;
                        },
                      ),
                      Text('Aktivan'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columns: [
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "ID",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 5,
                      child: Text(
                        "FirstName",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "LastName",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Email",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "BirthDate",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Gender",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "isActive",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
              ],
              rows: employees
                  .map((Employee e) =>
                  DataRow(
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.firstName?.toString()  ?? "")),
                        DataCell(Text(e.lastName?.toString()  ?? "")),
                        DataCell(Text(e.email?.toString()  ?? "")),
                        DataCell(Text('${DateFormat('dd.MM.yyyy').format(DateTime.parse( e.birthDate))}' ?.toString()  ?? "")),
                        DataCell(Text( e.gender == 0 ? "Male" : "Female")),
                        DataCell(Text(e.isActive?.toString()  ?? "")),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = true;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(isEditing
                                        ? 'Uredi radnika'
                                        : 'Dodaj radnika'),
                                    content: SingleChildScrollView(
                                      child: AddEmployeeForm(
                                          isEditing: isEditing,
                                          employeeToEdit:
                                          e), // Prosleđivanje podataka o državi
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Zatvorite modal
                                        },
                                        child: Text('Zatvori'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            EditEmployee(e.id);
                                          }
                                        },
                                        child: Text('Spremi'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Edit"),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Izbrisi radnika"),
                                    content: SingleChildScrollView(
                                        child: Text(
                                            "Da li ste sigurni da zelite obisati radnika?")),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Zatvorite modal
                                        },
                                        child: Text('Odustani'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          DeleteEmployee(e.id);
                                        },
                                        child: Text('Izbrisi'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Delete"),
                          ),
                        ),
                      ]))
                  .toList() ??
                  [])
      ),
    );
  }

}

import 'package:ecinema_admin/models/user.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/error_dialog.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = <User>[];
  late UserProvider _userProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int? selectedGender;
  int? selectedCinemaId;
  int? selectedRole;
  bool _isActive=false;
  bool _isVerified=false;

  @override
  void initState() {
    super.initState();
    _userProvider=context.read<UserProvider>();
    loadUsers();
  }

  void loadUsers() async {
    try {
      var userResponse = await _userProvider.get(null);
      setState(() {
        users = userResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }
  void InsertUser() async {
    try {
      var newUser = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "email":_emailController.text,
        "birthDate": _birthDateController.text,
        "phoneNumber":_phoneNumberController.text,
        "gender": selectedGender,
        "isActive":_isActive,
        "role":selectedRole,
        "isVerified":_isVerified,
        "password":_passwordController.text
      };
      print(newUser);
      var user = await _userProvider.insert(newUser);
      if (user == "OK") {
        Navigator.of(context).pop();
        loadUsers();
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditUser(int id) async {
    try {
      var newUser = {
        "id":id,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "email":_emailController.text,
        "birthDate": _birthDateController.text,
        "phoneNumber":_phoneNumberController.text,
        "gender": selectedGender,
        "isActive":_isActive,
        "role":selectedRole,
        "isVerified":_isVerified,
        "password":_passwordController.text
      };
      var user = await _userProvider.edit(newUser);
      if (user == "OK") {
        Navigator.of(context).pop();
        loadUsers();
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteUser(int id) async {
    try {
      var user = await _userProvider.delete(id);
      if (user == "OK") {
        Navigator.of(context).pop();
        loadUsers();
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
        title: Text("Languages"),
      ),
      body: Center(
        child: Container(
            child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 380,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 136,
                          top: 8,
                          right: 8), // Margine za input polje
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Pretraga', // Placeholder za pretragu
                        ),
                        // Dodajte logiku za pretragu ovde
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8, right: 146), // Margine za dugme "Dodaj"
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Dodaj korisnika'),
                              content: SingleChildScrollView(
                                child: AddUserForm(),
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
                                      InsertUser();
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

  Widget AddUserForm({bool isEditing = false, User? userToEdit}) {
    if (userToEdit != null) {
      _firstNameController.text = userToEdit.firstName ?? '';
      _lastNameController.text = userToEdit.lastName ?? '';
      _emailController.text = userToEdit.email ?? '';
      _phoneNumberController.text= userToEdit.phoneNumber ?? '';
      _birthDateController.text=userToEdit.birthDate ?? '';
      selectedRole=userToEdit.role;
      selectedGender=userToEdit.gender;
      _isActive=userToEdit.isActive;
      _isVerified=userToEdit.isVerified;
      _passwordController.text='';
    } else {
      _firstNameController.text = '';
      _lastNameController.text = '';
      _emailController.text = '';
      _phoneNumberController.text='';
      _birthDateController.text = '';
      selectedRole=null;
      selectedGender=null;
      _isVerified=false;
      _isActive=false;
      _passwordController.text='';
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
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Broj'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite broj!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Sifra'),
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
                  DropdownButtonFormField<int>(
                    value: selectedRole,
                    onChanged: (newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Odaberi rolu'),
                      ),
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Korisnik'),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('Administrator'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Rola',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Unesite rolu!';
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
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Checkbox(
                        value:_isVerified,
                        onChanged: (bool? value) {
                          _isVerified=!_isVerified;
                        },
                      ),
                      Text('Verifikovan'),
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
                        "PhoneNumber",
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
                      flex: 4,
                      child: Text(
                        "isVerified",
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
              rows: users
                  .map((User e) =>
                  DataRow(
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.firstName?.toString()  ?? "")),
                        DataCell(Text(e.lastName?.toString()  ?? "")),
                        DataCell(Text(e.email?.toString()  ?? "")),
                        DataCell(Text(e.phoneNumber?.toString()  ?? "")),
                        DataCell(Text('${DateFormat('dd.MM.yyyy').format(DateTime.parse( e.birthDate))}' ?.toString()  ?? "")),
                        DataCell(Text( e.gender == 0 ? "Male" : "Female")),
                        DataCell(Text(e.isActive?.toString()  ?? "")),
                        DataCell(Text(e.isVerified?.toString()  ?? "")),
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
                                        ? 'Uredi korisnika'
                                        : 'Dodaj korisnika'),
                                    content: SingleChildScrollView(
                                      child: AddUserForm(
                                          isEditing: isEditing,
                                          userToEdit:
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
                                            EditUser(e.id);
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
                                    title: Text("Izbrisi korisnika"),
                                    content: SingleChildScrollView(
                                        child: Text(
                                            "Da li ste sigurni da zelite obisati korisnika?")),
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
                                          DeleteUser(e.id);
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

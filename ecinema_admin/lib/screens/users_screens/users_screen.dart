import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ecinema_admin/models/user.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../providers/photo_provider.dart';
import '../../utils/authorzation.dart';
import '../../utils/error_dialog.dart';
import 'package:http/http.dart' as http;

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = <User>[];
  late UserProvider _userProvider;
  late PhotoProvider _photoProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late ValueNotifier<bool> _isActiveNotifier;
  late ValueNotifier<bool> _isVerifiedNotifier;
  ValueNotifier<File?> _pickedFileNotifier = ValueNotifier(null);
  DateTime selectedDate = DateTime.now();
  int? selectedGender;
  int? selectedCinemaId;
  int? selectedRole;
  bool _isActive = false;
  bool _isVerified = false;

  File? _pickedFile;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _photoProvider = context.read<PhotoProvider>();
    _isActiveNotifier = ValueNotifier<bool>(_isActive);
    _isVerifiedNotifier = ValueNotifier<bool>(_isVerified);
    _pickedFileNotifier = ValueNotifier<File?>(_pickedFile);
    loadUsers('');
    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadUsers(searchQuery);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _pickedFileNotifier.value = File(pickedFile.path);
      _pickedFile = File(pickedFile.path);
    }
  }

  Future<String> loadPhoto(String guidId) async {
    return await _photoProvider.getPhoto(guidId);
  }

  void loadUsers(String? query) async {
    var params;
    try {
      if (query != null) {
        params = query;
      } else {
        params = null;
      }
      var userResponse = await _userProvider.get({'params': params});
      setState(() {
        users = userResponse;
        print(users);
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void insertUser() async {
    try {
      if (_pickedFile == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Please select an image.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      Map<String, dynamic> userData = {
        "Id": null,
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Email': _emailController.text,
        'Password': _passwordController.text,
        'PhoneNumber': _phoneNumberController.text,
        'Address': '',
        'ProfessionalTitle': '',
        'Gender': selectedGender.toString(),
        'DateOfBirth':
            DateTime.parse(_birthDateController.text).toUtc().toIso8601String(),
        'Role': '1',
        'LastSignInAt': DateTime.now().toUtc().toIso8601String(),
        'IsVerified': _isVerified.toString(),
        'IsActive': _isActive.toString(),
      };

      // Add the photo to the user data
      userData['ProfilePhoto'] = http.MultipartFile.fromBytes(
        'ProfilePhoto',
        _pickedFile!.readAsBytesSync(),
        filename: 'profile_photo.jpg',
      );

      // Send the request
      var response = await _userProvider.insertUser(userData);

      if (response == "OK") {
        // Successful response
        Navigator.of(context).pop();
        loadUsers('');
        setState(() {
          selectedGender = null;
        });
      } else {
        // Handle error
        showErrorDialog(context, 'Greška prilikom dodavanja');
      }
    } catch (e) {
      // Handle exceptions
      showErrorDialog(context, e.toString());
    }
  }

  void editUser(int id) async {
    try {
      Map<String, dynamic> userData = {
        "Id": id.toString(),
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Email': _emailController.text,
        'Password': _passwordController.text,
        'PhoneNumber': _phoneNumberController.text,
        'Address': '',
        'ProfessionalTitle': '',
        'Gender': selectedGender.toString(),
        'DateOfBirth':
            DateTime.parse(_birthDateController.text).toUtc().toIso8601String(),
        'Role': '1',
        'LastSignInAt': DateTime.now().toUtc().toIso8601String(),
        'IsVerified': _isVerified.toString(),
        'IsActive': _isActive.toString(),
      };
      if (_pickedFile != null) {
        userData['ProfilePhoto'] = http.MultipartFile.fromBytes(
          'ProfilePhoto',
          _pickedFile!.readAsBytesSync(),
          filename: 'profile_photo.jpg',
        );
      }
      // Send the request
      var response = await _userProvider.updateUser(userData);

      if (response == "OK") {
        Navigator.of(context).pop();
        loadUsers('');
        setState(() {
          selectedGender = null;
        });
      } else {
        // Handle error
        showErrorDialog(context, 'Greška prilikom uređivanja');
      }
    } catch (e) {
      // Handle exceptions
      showErrorDialog(context, e.toString());
    }
  }

  void DeleteUser(int id) async {
    try {
      var user = await _userProvider.delete(id);
      if (user == "OK") {
        Navigator.of(context).pop();
        loadUsers('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  Widget displayImage(String base64String) {
    if (base64String == null) {
      return Placeholder(); // Placeholder je samo primjer
    } else {
      List<int> bytes = base64Decode(base64String);

      return Image.memory(
        Uint8List.fromList(bytes),
        fit: BoxFit.cover, // Prilagodite način prikaza slike
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pretraga',
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
                                      insertUser();
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
      _firstNameController.text = userToEdit.firstName;
      _lastNameController.text = userToEdit.lastName;
      _emailController.text = userToEdit.email;
      _phoneNumberController.text = userToEdit.phoneNumber ?? '';
      _birthDateController.text = userToEdit.birthDate ?? '';
      selectedGender = userToEdit.gender;
      _isActive = userToEdit.isActive;
      _isVerified = userToEdit.isVerified;
      _passwordController.text = '';
      _pickedFile = null;
    } else {
      _firstNameController.text = '';
      _lastNameController.text = '';
      _emailController.text = '';
      _phoneNumberController.text = '';
      _birthDateController.text = '';
      selectedGender = null;
      _isVerified = false;
      _isActive = false;
      _passwordController.text = '';
      _pickedFile = null;
    }

    return Container(
      height: 450,
      width: 950,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
                child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(35),
                child: Column(children: [
                  ValueListenableBuilder<File?>(
                      valueListenable: _pickedFileNotifier,
                      builder: (context, pickedFile, _) {
                        return Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 180,
                          color: Colors.teal,
                          child: FutureBuilder<String>(
                            future: _pickedFile != null
                                ? Future.value(_pickedFile!.path)
                                : loadPhoto(isEditing
                                    ? (userToEdit?.profilePhoto?.guidId ?? '')
                                    : ''),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Molimo odaberite fotografiju');
                              } else {
                                final imageUrl = snapshot.data;

                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return Container(
                                    child: FadeInImage(
                                      image: _pickedFile != null
                                          ? FileImage(_pickedFile!)
                                              as ImageProvider<Object>
                                          : NetworkImage(
                                              imageUrl,
                                              headers:
                                                  Authorization.createHeaders(),
                                            ) as ImageProvider<Object>,
                                      placeholder:
                                          MemoryImage(kTransparentImage),
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      fit: BoxFit.cover,
                                      width: 230,
                                      height: 200,
                                    ),
                                  );
                                } else {
                                  // Ako uređujete korisnika, pokažite poruku za odabir slike
                                  // Inače, prikažite podrazumevanu sliku iz assetsa
                                  return isEditing
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: const Text(
                                              'Please select an image'),
                                        )
                                      : Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Image.asset(
                                            'assets/images/default_user_image.jpg',
                                            width: 230,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                }
                              }
                            },
                          ),
                        );
                      }),
                  const SizedBox(height: 35),
                  Center(
                    child: SizedBox(
                      width: 150, // Širina dugmeta
                      height: 35, // Visina dugmeta
                      child: ElevatedButton(
                        onPressed: () => _pickImage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20.0), // Zaobljenost rubova
                          ),
                        ),
                        child: Text('Select An Image',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  )
                ]),
              ),
            )),
            SizedBox(
              width: 30,
            ),
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
            SizedBox(
              width: 30,
            ),
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
                            _birthDateController.text =
                                DateFormat('yyyy-MM-dd').format(date);
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
                  SizedBox(
                    height: 20,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isActiveNotifier,
                    builder: (context, isActive, child) {
                      return Row(
                        children: [
                          Checkbox(
                            value: _isActiveNotifier.value,
                            onChanged: (bool? value) {
                              _isActiveNotifier.value =
                                  !_isActiveNotifier.value;
                              _isActive = _isActiveNotifier.value;
                            },
                          ),
                          Text('Aktivan'),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isVerifiedNotifier,
                    builder: (context, isVerified, child) {
                      return Row(
                        children: [
                          Checkbox(
                            value: _isVerifiedNotifier.value,
                            onChanged: (bool? value) {
                              _isVerifiedNotifier.value =
                                  !_isVerifiedNotifier.value;
                              _isVerified = _isVerifiedNotifier.value;
                            },
                          ),
                          Text('Verifikovan'),
                        ],
                      );
                    },
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
                    "Slika",
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
                      .map((User e) => DataRow(cells: [
                            DataCell(Text(e.id?.toString() ?? "")),
                            DataCell(
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: FutureBuilder<String>(
                                      future: loadPhoto(
                                          e.profilePhoto?.guidId ?? ''),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Greška prilikom učitavanja slike');
                                        } else {
                                          final imageUrl = snapshot.data;

                                          if (imageUrl != null &&
                                              imageUrl.isNotEmpty) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: FadeInImage(
                                                image: NetworkImage(
                                                  imageUrl,
                                                  headers: Authorization
                                                      .createHeaders(),
                                                ),
                                                placeholder: MemoryImage(
                                                    kTransparentImage),
                                                fadeInDuration: const Duration(
                                                    milliseconds: 300),
                                                fit: BoxFit.fill,
                                                width: 80,
                                                height: 105,
                                              ),
                                            );
                                          } else {
                                            null;
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Image.asset(
                                                'assets/images/user1.jpg',
                                                width: 80,
                                                height: 105,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(e.firstName?.toString() ?? "")),
                            DataCell(Text(e.lastName?.toString() ?? "")),
                            DataCell(Text(e.email?.toString() ?? "")),
                            DataCell(Text(e.phoneNumber?.toString() ?? "")),
                            DataCell(Text(
                                '${DateFormat('dd.MM.yyyy').format(DateTime.parse(e.birthDate))}'
                                        ?.toString() ??
                                    "")),
                            DataCell(Text(e.gender == 0 ? "Male" : "Female")),
                            DataCell(Text(e.isActive?.toString() ?? "")),
                            DataCell(Text(e.isVerified?.toString() ?? "")),
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
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                editUser(e.id);
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
                  [])),
    );
  }
}

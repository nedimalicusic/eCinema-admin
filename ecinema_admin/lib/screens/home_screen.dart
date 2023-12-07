import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/loginUser.dart';
import '../models/user.dart';
import '../providers/login_provider.dart';
import '../providers/user_provider.dart';
import '../utils/error_dialog.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LoginProvider _loginProvider;
  late UserProvider _userProvider;
  late LoginUser? loginUser;
  late User? user;
  Widget _currentPage = DashboardScreen();
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
  bool _isActive = false;
  bool _isVerified = false;

  File? _image;
  XFile? _pickedFile;
  final _picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loginProvider = context.read<LoginProvider>();
    loginUser = _loginProvider.loginUser;
    _userProvider = context.read<UserProvider>();
    loadUser();
  }


  void loadUser() async {
    try {
      var userResponse = await _userProvider.getById(int.parse(loginUser!.Id));
      setState(() {
        user = userResponse;
        _isLoading = false; // Postavljanje stanja učitavanja na false kad se podaci učitaju
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false; // Ažuriranje stanja učitavanja ako dođe do greške
      });
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        _image = File(pickedFile.path);
      });
    }
  }
  void _changePage(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Prikaži indikator učitavanja dok se podaci ne učitaju
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.teal,
        title:  Container(
          margin: EdgeInsets.only(left: 80),
          child: Row(
            children: const [
              Icon(Icons.movie_creation_outlined,color: Colors.white,),SizedBox(width: 10,),
              Text(
                'eCinema',
                style: TextStyle(
                    fontSize: 20, // Postavite željenu veličinu fonta
                    fontWeight: FontWeight.bold,
                    color: Colors.white // Boldirajte tekst
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 300.0), // Dodavanje margine s desne strane slike korisnika
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Uredi administratora'),
                          content: SingleChildScrollView(
                            child: EditUserForm(userToEdit: user),
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
                                  EditUserForm();
                                }
                              },
                              child: Text('Spremi'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/user.png'), // Postavite putanju do slike korisnika ovdje
                  ),
                ),
                SizedBox(width: 8), // Dodavanje razmaka između slike i teksta
                Text(
                  user!.firstName + " "+ user!.lastName, // Zamijenite ovo sa stvarnim imenom i prezimenom korisnika
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Expanded(
                child: SideMenu(onMenuItemClicked: _changePage),
              ),
            Expanded(
              flex: 5,
              child: _currentPage,
            ),
          ],
        ),
      ),
    );
  }

Widget EditUserForm({bool isEditing = false, User? userToEdit}) {
  if (userToEdit != null) {
    _firstNameController.text = userToEdit.firstName ?? '';
    _lastNameController.text = userToEdit.lastName ?? '';
    _emailController.text = userToEdit.email ?? '';
    _phoneNumberController.text = userToEdit.phoneNumber ?? '';
    _birthDateController.text = userToEdit.birthDate ?? '';
    selectedRole = userToEdit.role;
    selectedGender = userToEdit.gender;
    _isActive = userToEdit.isActive;
    _isVerified = userToEdit.isVerified;
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
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: (_pickedFile != null)
                          ? Image.file(
                        File(_pickedFile!.path),
                        width: 230,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                          : (userToEdit != null && userToEdit.profilePhoto != null)
                          ? Image.memory(
                        Uint8List.fromList(
                            base64Decode(userToEdit.profilePhoto!.data)),
                        width: 230,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                          : const Text('Please select an image'),
                    ),
                    const SizedBox(height: 35),
                    Center(
                      child: SizedBox(
                        width: 150, // Širina dugmeta
                        height: 35, // Visina dugmeta
                        child: ElevatedButton(
                          onPressed: () => _pickImage(),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal, // Boja pozadine
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Zaobljenost rubova
                            ),
                          ),
                          child: Text('Select An Image',
                              style: TextStyle(fontSize: 14)),
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isActive,
                      onChanged: (bool? value) {
                        _isActive = !_isActive;
                      },
                    ),
                    Text('Aktivan'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isVerified,
                      onChanged: (bool? value) {
                        _isVerified = !_isVerified;
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
}

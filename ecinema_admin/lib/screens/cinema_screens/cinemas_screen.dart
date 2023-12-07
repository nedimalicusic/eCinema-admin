import 'package:ecinema_admin/models/city.dart';
import 'package:ecinema_admin/providers/city_provider.dart';
import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/home_screen.dart';
import 'package:ecinema_admin/screens/movies_screens/movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cinema.dart';
import '../../providers/cinema_provider.dart';
import '../../utils/error_dialog.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({Key? key}) : super(key: key);

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  List<Cinema> cinemas = <Cinema>[];
  List<City> cities = <City>[];
  late CinemaProvider _cinemaProvider;
  late CityProvider _cityProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _numberOfSeatsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? selectedCity;

  @override
  void initState() {
    super.initState();
    _cinemaProvider=context.read<CinemaProvider>();
    _cityProvider=context.read<CityProvider>();
    loadCinema('');
    loadCities();
    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadCinema(searchQuery);
    });
  }

  void loadCinema(String? query) async {
    var params;
    try {
      if (query != null) {
        params = query;
      } else {
        params = null;
      }
      var cinemasResponse = await _cinemaProvider.get({'params': params});
      setState(() {
        cinemas = cinemasResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void loadCities() async {
    try {
      var citiesResponse = await _cityProvider.get(null);
      setState(() {
        cities = citiesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertCinema() async {
    try {
      var newCinema = {
        "name": _nameController.text,
        "address": _addressController.text,
        "description":_descriptionController.text,
        "email": _emailController.text,
        "phoneNumber": _phoneNumberController.text,
        "numberOfSeats": _numberOfSeatsController.text,
        "cityId": selectedCity
      };
      print(newCinema);
      var city = await _cinemaProvider.insert(newCinema);
      if (city == "OK") {
        Navigator.of(context).pop();
        loadCinema('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditCinema(int id) async {
    try {
      var newCinema = {
        "id":id,
        "name": _nameController.text,
        "address": _addressController.text,
        "description":_descriptionController.text,
        "email": _emailController.text,
        "phoneNumber": _phoneNumberController.text,
        "numberOfSeats": _numberOfSeatsController.text,
        "cityId": selectedCity
      };
      var city = await _cinemaProvider.edit(newCinema);
      if (city == "OK") {
        Navigator.of(context).pop();
        loadCinema('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteCinema(int id) async {
    try {
      var actor = await _cinemaProvider.delete(id);
      if (actor == "OK") {
        Navigator.of(context).pop();
        loadCinema('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
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
                    width: 500,
                    child: Padding(
                      padding: EdgeInsets.only(left: 136, top: 8, right: 8), // Margine za input polje
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
                    padding: EdgeInsets.only(top: 8, right: 146), // Margine za dugme "Dodaj"
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Dodaj kino'),
                              content: SingleChildScrollView(
                                child: AddCinemaForm(),
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
                                      InsertCinema();
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

  Widget AddCinemaForm({bool isEditing = false, Cinema? cinemaToEdit}) {
    if (cinemaToEdit != null) {
      _nameController.text = cinemaToEdit.name ?? '';
      _addressController.text = cinemaToEdit.address ?? '';
      _descriptionController.text = cinemaToEdit.description ?? '';
      _emailController.text = cinemaToEdit.email ?? '';
      _phoneNumberController.text = cinemaToEdit.phoneNumber.toString() ?? '';
      _numberOfSeatsController.text = cinemaToEdit.numberOfSeats.toString() ?? '';
      selectedCity=cinemaToEdit.cityId;
    } else {
      _nameController.text = '';
      _addressController.text = '';
      _descriptionController.text = '';
      _emailController.text = '';
      _phoneNumberController.text = '';
      _numberOfSeatsController.text = '';
      selectedCity=null;
    }

    return Container(
      height: 550,
      width: 500,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Naziv'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite naziv!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresa'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite adresu!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite opis!';
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
                final emailPattern = RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$');
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
              controller: _numberOfSeatsController,
              decoration: InputDecoration(labelText: 'Broj sjedala'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite broj sjedala!';
                }
                return null;
              },
            ),
            DropdownButtonFormField<int>(
              value: selectedCity, // Postavite odabrani grad (ID)
              onChanged: (int? newValue) {
                setState(() {
                  selectedCity = newValue;
                });
              },
              items: cities.map((City city) {
                return DropdownMenuItem<int>(
                  value: city.id, // Ovdje postavite ID grada
                  child: Text(city.name),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Grad'),
              validator: (value) {
                if (value == null) {
                  return 'Odaberite grad!';
                }
                return null;
              },
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
                      flex: 3,
                      child: Text(
                        "Name",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 3,
                      child: Text(
                        "Address",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 3,
                      child: Text(
                        "Email",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "PhoneNumber",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "NumberOfSeats",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "City",
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
              rows: cinemas
              .map((Cinema e) =>
            DataRow(
           cells: [
             DataCell(Text(e.id?.toString() ?? "")),
          DataCell(Text(e.name?.toString() ?? "")),
          DataCell(Text(e.address?.toString() ?? "")),
          DataCell(Text(e.email?.toString() ?? "")),
          DataCell(Text(e.phoneNumber?.toString() ?? "")),
          DataCell(Text(e.numberOfSeats?.toString() ?? "")),
          DataCell(Text(e.city.name?.toString() ?? "")),
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
                          ? 'Uredi kino'
                          : 'Dodaj kino'),
                      content: SingleChildScrollView(
                        child: AddCinemaForm(
                            isEditing: isEditing,
                            cinemaToEdit:
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
                              EditCinema(e.id);
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
                      title: Text("Izbrisi kino"),
                      content: SingleChildScrollView(
                          child: Text(
                              "Da li ste sigurni da zelite obisati kino?")),
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
                            DeleteCinema(e.id);
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

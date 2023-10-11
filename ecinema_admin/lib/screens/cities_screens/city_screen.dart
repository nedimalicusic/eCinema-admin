import 'package:ecinema_admin/models/city.dart';
import 'package:ecinema_admin/models/country.dart';
import 'package:ecinema_admin/providers/city_provider.dart';
import 'package:ecinema_admin/providers/country_provider.dart';
import 'package:ecinema_admin/screens/countries_screens/counry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/error_dialog.dart';


class CityScreen extends StatefulWidget {
  const CityScreen({Key? key}) : super(key: key);

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  List<City> cities = <City>[];
  List<Country> countries = <Country>[];
  late CityProvider _cityProvider;
  late CountryProvider _countryProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _isActiveController = TextEditingController();
  int? _selectedCountryId;
  bool _cityIsActive=false;
  @override
  void initState() {
    super.initState();
    _cityProvider=context.read<CityProvider>();
    _countryProvider=context.read<CountryProvider>();
    loadCities();
    loadCountries();
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

  void loadCountries() async {
    try {
      var countriesResponse = await _countryProvider.get(null);
      setState(() {
        countries = countriesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertCity() async {
    try {
      var newCity = {
        "name": _nameController.text,
        "zipCode": _zipCodeController.text,
        "countryId":_selectedCountryId,
        "isActive": _cityIsActive
      };
      var city = await _cityProvider.insert(newCity);
      if (city == "OK") {
        Navigator.of(context).pop();
        loadCities();
        setState(() {
          _selectedCountryId=null;
        });
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditCity(int id) async {
    try {
      var newCity = {
        "id":id,
        "name": _nameController.text,
        "zipCode": _zipCodeController.text,
        "countryId":_selectedCountryId,
        "isActive": _cityIsActive
      };
      var city = await _cityProvider.edit(newCity);
      if (city == "OK") {
        Navigator.of(context).pop();
        loadCities();
        setState(() {
          _selectedCountryId=null;
        });
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteCity(int id) async {
    try {
      var country = await _cityProvider.delete(id);
      if (country == "OK") {
        Navigator.of(context).pop();
        loadCities();
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Cities"),
      ),
      body: Center(
        child: Container(
          width: 1050,
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
                        decoration: InputDecoration(
                          hintText: 'Pretraga', // Placeholder za pretragu
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
                              title: Text('Dodaj grad'),
                              content: SingleChildScrollView(
                                child: AddCityForm(),
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
                                      InsertCity();
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

  Widget AddCityForm({bool isEditing = false, City? cityToEdit}) {
    if (cityToEdit != null) {
      _nameController.text = cityToEdit.name ?? '';
      _zipCodeController.text = cityToEdit.zipCode ?? '';
      _selectedCountryId=cityToEdit.countryId;
    } else {
      _nameController.text = '';
      _zipCodeController.text = '';
      _selectedCountryId=null;
      _cityIsActive=false;
    }

    return Container(
      height: 300, // Increased height to accommodate new fields
      width: 350,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Odaberite državu'),
              value: _selectedCountryId,
              items: countries.map<DropdownMenuItem<int>>((Country country) {
                return DropdownMenuItem<int>(
                  value: country.id,
                  child: Text(country.name),
                );
              }).toList(),
              onChanged: (int? selectedCountryId) {
                setState(() {
                  _selectedCountryId = selectedCountryId;
                });
              },
              validator: (int? value) {
                if (value == null) {
                  return 'Odaberite državu!'; // Error message when no country is selected
                }
                return null; // No error if a country is selected
              },
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Naziv grada'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite naziv grada!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _zipCodeController,
              decoration: InputDecoration(labelText: 'ZipCode'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite ZipCode!';
                }
                return null;
              },
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Checkbox(
                  value:_cityIsActive,
                  onChanged: (bool? value) {
                    _cityIsActive=!_cityIsActive;
                  },
                ),
                Text('Aktivan'),
              ],
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
                        "Name",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "ZipCode",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "IsActive",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Country",
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
              rows: cities
                  .map((City e) =>
                  DataRow(
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.name?.toString() ?? "")),
                        DataCell(Text(e.zipCode?.toString() ?? "")),
                        DataCell(Text(e.isActive?.toString() ?? "")),
                        DataCell(Text(e.country.abbreviation?.toString() ?? "")),
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
                                        ? 'Uredi grad'
                                        : 'Dodaj grad'),
                                    content: SingleChildScrollView(
                                      child: AddCityForm(
                                          isEditing: isEditing,
                                          cityToEdit:
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
                                            EditCity(e.id);
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
                                    title: Text("Izbrisi grad"),
                                    content: SingleChildScrollView(
                                        child: Text(
                                            "Da li ste sigurni da zelite obisati grad?")),
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
                                          DeleteCity(e.id);
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

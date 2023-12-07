import 'package:ecinema_admin/models/country.dart';
import 'package:ecinema_admin/providers/country_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../utils/error_dialog.dart';
import '../login_screen.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({Key? key}) : super(key: key);

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  List<Country> countries = <Country>[];
  late CountryProvider _countryProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _abbrevationContoller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isEditing = false;
  bool _countryIsActive = false;

  @override
  void initState() {
    super.initState();
    _countryProvider = context.read<CountryProvider>();
    loadCountries('');
    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadCountries(searchQuery);
    });
  }

  void loadCountries(String? query) async {
    var params;
    try {
      if (query != null) {
        params = query;
      } else {
        params = null;
      }
      var countriesResponse = await _countryProvider.get({'params': params});
      setState(() {
        countries = countriesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertCountry() async {
    try {
      var newCountry = {
        "name": _nameController.text,
        "abbreviation": _abbrevationContoller.text,
        "isActive": _countryIsActive,
      };
      var country = await _countryProvider.insert(newCountry);
      if (country == "OK") {
        Navigator.of(context).pop();
        loadCountries('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteCounty(int id) async {
    try {
      var country = await _countryProvider.delete(id);
      if (country == "OK") {
        Navigator.of(context).pop();
        loadCountries('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditCountry(int id) async {
    try {
      var newCountry = {
        "id": id,
        "name": _nameController.text,
        "abbreviation": _abbrevationContoller.text,
        "isActive": _countryIsActive,
      };
      var country = await _countryProvider.edit(newCountry);
      if (country == "OK") {
        Navigator.of(context).pop();
        loadCountries(null);
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
          width: 1100,
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 500,
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
                        )),
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
                              title: Text('Dodaj državu'),
                              content: SingleChildScrollView(
                                child: AddCountryForm(),
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
                                      InsertCountry();
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

  Widget AddCountryForm({bool isEditing = false, Country? countryToEdit}) {
    if (countryToEdit != null) {
      _nameController.text = countryToEdit.name ?? '';
      _abbrevationContoller.text = countryToEdit.abbreviation ?? '';
    } else {
      _nameController.text = '';
      _abbrevationContoller.text = '';
      _countryIsActive = false;
    }

    return Container(
      height: 250,
      width: 300,
      child: (Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Naziv države'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite naziv države';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _abbrevationContoller,
              decoration: InputDecoration(labelText: 'Skraćenica'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite kod države';
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
                  value: _countryIsActive,
                  onChanged: (bool? value) {
                    _countryIsActive = !_countryIsActive;
                  },
                ),
                Text('Aktivan'),
              ],
            ),
          ],
        ),
      )),
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
                    "Abbreviation",
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
              rows: countries
                      .map((Country e) => DataRow(cells: [
                            DataCell(Text(e.id?.toString() ?? "")),
                            DataCell(Text(e.name?.toString() ?? "")),
                            DataCell(Text(e.abbreviation?.toString() ?? "")),
                            DataCell(Text(e.isActive?.toString() ?? "")),
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
                                            ? 'Uredi državu'
                                            : 'Dodaj državu'),
                                        content: SingleChildScrollView(
                                          child: AddCountryForm(
                                              isEditing: isEditing,
                                              countryToEdit:
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
                                                EditCountry(e.id);
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
                                        title: Text("Izbrisi drzavu"),
                                        content: SingleChildScrollView(
                                            child: Text(
                                                "Da li ste sigurni da zelite obisati drzavu?")),
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
                                              DeleteCounty(e.id);
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

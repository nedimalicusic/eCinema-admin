import 'package:ecinema_admin/models/language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../utils/error_dialog.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List<Language> languages = <Language>[];
  late LanguageProvider _languageProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    _languageProvider = context.read<LanguageProvider>();
    loadLanguages();
  }

  void loadLanguages() async {
    try {
      var languagesResponse = await _languageProvider.get(null);
      setState(() {
        languages = languagesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertLanguage() async {
    try {
      var newLanguage = {
        "name": _nameController.text,
      };
      var language = await _languageProvider.insert(newLanguage);
      if (language == "OK") {
        Navigator.of(context).pop();
        loadLanguages();
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteLanguage(int id) async {
    try {
      var country = await _languageProvider.delete(id);
      if (country == "OK") {
        Navigator.of(context).pop();
        loadLanguages();
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditLanguage(int id) async {
    try {
      var newLanguage = {
        "id": id,
        "name": _nameController.text,
      };
      var language = await _languageProvider.edit(newLanguage);
      if (language == "OK") {
        Navigator.of(context).pop();
        loadLanguages();
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
          width: 670,
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
                              title: Text('Dodaj jezik'),
                              content: SingleChildScrollView(
                                child: AddLanguageForm(),
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
                                      InsertLanguage();
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

  Widget AddLanguageForm({bool isEditing = false, Language? languageToEdit}) {
    if (languageToEdit != null) {
      _nameController.text = languageToEdit.name ?? '';
    } else {
      _nameController.text = '';
    }

    return Container(
      height: 100,
      width: 300,
      child: (Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Naziv jezika'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite naziv jezika';
                }
                return null;
              },
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
              rows: languages
                      .map((Language e) => DataRow(cells: [
                            DataCell(Text(e.id?.toString() ?? "")),
                            DataCell(Text(e.name?.toString() ?? "")),
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
                                            ? 'Uredi jezik'
                                            : 'Dodaj jezik'),
                                        content: SingleChildScrollView(
                                          child: AddLanguageForm(
                                              isEditing: isEditing,
                                              languageToEdit:
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
                                                EditLanguage(e.id);
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
                                        title: Text("Izbrisi jezik"),
                                        content: SingleChildScrollView(
                                            child: Text(
                                                "Da li ste sigurni da zelite obisati jezik?")),
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
                                              DeleteLanguage(e.id);
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

import 'package:ecinema_admin/models/city.dart';
import 'package:ecinema_admin/models/searchObject/cinema_search.dart';
import 'package:ecinema_admin/providers/city_provider.dart';
import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/home_screen.dart';
import 'package:ecinema_admin/screens/movies_screens/movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
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
  List<Cinema> selectedCinema = <Cinema>[];
  int? selectedCity;
  bool isAllSelected = false;
  int currentPage = 1;
  int pageSize = 5;
  int hasNextPage = 0;

  @override
  void initState() {
    super.initState();
    _cinemaProvider=context.read<CinemaProvider>();
    _cityProvider=context.read<CityProvider>();
    loadCities();
    loadCinema(
        CinemaSearchObject(
            name: _searchController.text,
            PageSize: pageSize,
            PageNumber: currentPage));

    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadCinema(
          CinemaSearchObject(
              name: searchQuery, PageNumber: currentPage, PageSize: pageSize));
    });
  }

  void loadCinema(
      CinemaSearchObject searchObject) async {
    try {
      var cinemaResponse =
      await _cinemaProvider.getPaged(searchObject: searchObject);
      setState(() {
        cinemas = cinemaResponse;
        hasNextPage = cinemas.length;
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
        loadCinema(
          CinemaSearchObject(
            name: _searchController.text,
            PageNumber: currentPage,
            PageSize: pageSize,
          ),
        );
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
        loadCinema(
          CinemaSearchObject(
            name: _searchController.text,
            PageNumber: currentPage,
            PageSize: pageSize,
          ),
        );
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
        loadCinema(
          CinemaSearchObject(
            name: _searchController.text,
            PageNumber: currentPage,
            PageSize: pageSize,
          ),
        );
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text("Kina"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BuildSearchField(context),
              const SizedBox(
                height: 10,
              ),
              buildDataList(context),
              const SizedBox(
                height: 10,
              ),
              buildPagination(),
            ])));
  }

  Row BuildSearchField(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: 350,
            height: 45,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pretraga",
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                suffixIcon: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding * 0.75),
                    margin: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Search.svg",
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            )),
        const SizedBox(
          width: 20,
        ),
        buildButtons(context),
      ],
    );
  }

  Row buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text("Dodaj kino"),
                    content: SingleChildScrollView(
                      child: AddCinemaForm(),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Zatvori",
                              style: TextStyle(color: white))),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              InsertCinema();
                            }
                          },
                          child: const Text("Spremi",
                              style: TextStyle(color: white)))
                    ],
                  );
                });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.add_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
                height: 30,
              ),
              Text(
                'Dodaj',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: () {
            if (selectedCinema.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Upozorenje"),
                      content: const Text(
                          "Morate odabrati barem jedno kino za uređivanje"),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK", style: TextStyle(color: white)),
                        ),
                      ],
                    );
                  });
            } else if (selectedCinema.length > 1) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Upozorenje"),
                      content: const Text(
                          "Odaberite samo jedno kino kojeg želite urediti"),
                      actions: <Widget>[
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Ok",
                                style: TextStyle(color: white)))
                      ],
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Uredi kino"),
                      content: AddCinemaForm(
                          isEditing: true, cinemaToEdit: selectedCinema[0]),
                      actions: <Widget>[
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Zatvori",
                                style: TextStyle(color: white))),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            onPressed: () {
                              EditCinema(selectedCinema[0].id);
                              setState(() {
                                selectedCinema = [];
                              });
                            },
                            child: const Text("Spremi",
                                style: TextStyle(color: white))),
                      ],
                    );
                  });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.edit_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
                height: 30,
              ),
              Text(
                'Izmijeni',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: selectedCinema.isEmpty
              ? () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Upozorenje"),
                      content: const Text(
                          "Morate odabrati kino kojeg želite obrisati."),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK",
                              style: TextStyle(color: white)),
                        ),
                      ]);
                });
          }
              : () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Izbriši kino!"),
                    content: const SingleChildScrollView(
                      child: Text(
                          "Da li ste sigurni da želite obrisati kino?"),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Odustani",
                            style: TextStyle(color: white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          for (Cinema n in selectedCinema) {
                            DeleteCinema(n.id);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text("Obriši",
                            style: TextStyle(color: white)),
                      ),
                    ],
                  );
                });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
                height: 30,
              ),
              Text(
                'Izbriši',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
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
      height: 400,
      width: 700,
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
  Expanded buildDataList(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints:
          BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DataTable(
                dataRowHeight: 80,
                dataRowColor: MaterialStateProperty.all(
                    const Color.fromARGB(42, 241, 241, 241)),
                columns: [
                  DataColumn(
                      label: Checkbox(
                          value: isAllSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              isAllSelected = value ?? false;
                              cinemas.forEach((employeeItem) {
                                employeeItem.isSelected = isAllSelected;
                              });
                              if (!isAllSelected) {
                                selectedCinema.clear();
                              } else {
                                selectedCinema = List.from(cinemas);
                              }
                            });
                          })),
                  const DataColumn(
                    label: Expanded(child: Text('Naziv')),
                  ),
                  const DataColumn(
                    label: Text('Adresa'),
                  ),
                  const DataColumn(
                    label: Text('Broj'),
                  ),
                  const DataColumn(
                    label: Text('Broj sjedala'),
                  ),
                  const DataColumn(
                    label: Text('Grad'),
                  ),
                ],
                rows: cinemas
                    .map((Cinema cinemaItem) => DataRow(cells: [
                  DataCell(
                    Checkbox(
                      value: cinemaItem.isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          cinemaItem.isSelected = value ?? false;
                          if (cinemaItem.isSelected == true) {
                            selectedCinema.add(cinemaItem);
                          } else {
                            selectedCinema.remove(cinemaItem);
                          }
                          isAllSelected =
                              cinemas.every((u) => u.isSelected);
                        });
                      },
                    ),
                  ),
                  DataCell(Text(cinemaItem.name.toString())),
                  DataCell(Text(cinemaItem.address.toString())),
                  DataCell(Text(cinemaItem.phoneNumber.toString())),
                  DataCell(Text(cinemaItem.numberOfSeats.toString())),
                  DataCell(Text(cinemaItem.city.name.toString())),
                ]))
                    .toList() ??
                    []),
          ),
        ),
      ),
    );
  }

  Widget buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            if (currentPage > 1) {
              setState(() {
                currentPage--;
              });
              loadCinema(
                  CinemaSearchObject(
                    PageNumber: currentPage,
                    PageSize: pageSize,
                  ));
            }
          },
          child: const Icon(
            Icons.arrow_left_outlined,
            color: white,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            setState(() {
              if (hasNextPage == pageSize) {
                currentPage++;
              }
            });
            if (hasNextPage == pageSize) {
              loadCinema(
                  CinemaSearchObject(
                      PageNumber: currentPage,
                      PageSize: pageSize,
                      name: _searchController.text),);
            }
          },
          child: const Icon(
            Icons.arrow_right_outlined,
            color: white,
          ),
        ),
      ],
    );
  }
}

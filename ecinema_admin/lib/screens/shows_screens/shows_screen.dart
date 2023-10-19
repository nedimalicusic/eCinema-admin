import 'package:ecinema_admin/models/cinema.dart';
import 'package:ecinema_admin/models/movie.dart';
import 'package:ecinema_admin/models/shows.dart';
import 'package:ecinema_admin/providers/movie_provider.dart';
import 'package:ecinema_admin/providers/show_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/cinema_provider.dart';
import '../../utils/error_dialog.dart';

class ShowsScreen extends StatefulWidget {
  const ShowsScreen({Key? key}) : super(key: key);

  @override
  State<ShowsScreen> createState() => _ShowsScreenState();
}

class _ShowsScreenState extends State<ShowsScreen> {
  List<Shows> shows = <Shows>[];
  List<Movie> movies = <Movie>[];
  late ShowProvider _showProvider;
  late MovieProvider _movieProvider;
  late CinemaProvider _cinemaProvider;
  List<Cinema> cinemaList = <Cinema>[];
  int? selectedCinema;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selecteTime = DateTime.now();
  int? selectedMovieId;
  int? selectedCinemaId;
  List<String> formats = ["2D", "3D", "Extreme", "4D"];
  String? selectedFormat;
  @override
  void initState() {
    super.initState();
    _showProvider = context.read<ShowProvider>();
    _cinemaProvider = context.read<CinemaProvider>();
    _movieProvider = context.read<MovieProvider>();
    loadCinema();
    loadMovies();
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

  void loadShows(int cinemaId) async {
    try {
      var showsResponse = await _showProvider.getPaged(cinemaId);
      setState(() {
        shows = showsResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void loadMovies() async {
    try {
      var moviesResponse = await _movieProvider.get(null);
      setState(() {
        movies = moviesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void InsertShow() async {
    try {
      var newShow = {
        "date": _dateController.text,
        "startTime": _timeController.text,
        "movieId": selectedMovieId,
        "cinemaId": selectedCinemaId,
        "format": selectedFormat,
        "price": _priceController.text
      };
      print(newShow);
      var city = await _showProvider.insert(newShow);
      if (city == "OK") {
        Navigator.of(context).pop();
        selectedCinema = selectedCinemaId;
        loadShows(selectedCinemaId!);
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditShow(int id) async {
    try {
      var newShow = {
        "id": id,
        "date": _dateController.text,
        "startTime": _timeController.text,
        "movieId": selectedMovieId,
        "cinemaId": selectedCinemaId,
        "format": selectedFormat,
        "price": _priceController.text
      };
      print(newShow);
      var city = await _showProvider.edit(newShow);
      if (city == "OK") {
        Navigator.of(context).pop();
        selectedCinema = selectedCinemaId;
        loadShows(selectedCinemaId!);
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteShow(int id) async {
    try {
      var actor = await _showProvider.delete(id);
      if (actor == "OK") {
        Navigator.of(context).pop();
        loadShows(1);
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
        title: Text("Shows"),
      ),
      body: Center(
        child: Container(
          width: 1200,
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
                          loadShows(selectedCinema!); // Pozovite funkciju sa odabranim kinom
                        },
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
                              title: Text('Dodaj projekciju'),
                              content: SingleChildScrollView(
                                child: AddShowForm(),
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
                                      InsertShow();
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

  Widget AddShowForm({bool isEditing = false, Shows? showToEdit}) {
    if (showToEdit != null) {
      _priceController.text = showToEdit.price.toString() ?? '';
      _dateController.text =
          DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(showToEdit.date) ?? '';
      _timeController.text =
          DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(showToEdit.startTime) ??
              '';
      selectedCinemaId = showToEdit.cinemaId;
      selectedMovieId = showToEdit.movieId;
      selectedFormat = showToEdit.format;
    } else {
      _priceController.text = '';
      _dateController.text = '';
      _timeController.text = '';
      selectedCinemaId = null;
      selectedMovieId = null;
      selectedFormat = null;
    }

    return Container(
      height: 550, // Povećao sam visinu da bi se prilagodili novi polja
      width: 350,
      child: Form(
        key: _formKey,
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
            DropdownButtonFormField<int>(
              value: selectedMovieId, // Postavite odabrani grad (ID)
              onChanged: (int? newValue) {
                setState(() {
                  selectedMovieId = newValue;
                });
              },
              items: movies.map((Movie movie) {
                return DropdownMenuItem<int>(
                  value: movie.id, // Ovdje postavite ID grada
                  child: Text(movie.title),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Film'),
              validator: (value) {
                if (value == null) {
                  return 'Odaberite film!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Datum',
                hintText: 'Odaberite datum',
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
                      _dateController.text =
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
            TextFormField(
              controller: _timeController, // Koristite kontroler za vrijeme
              decoration: InputDecoration(
                labelText: 'Vrijeme',
                hintText: 'Odaberite vrijeme',
              ),
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      selecteTime), // Postavite početno vrijeme
                ).then((time) {
                  if (time != null) {
                    setState(() {
                      selecteTime = DateTime(
                          selecteTime.year,
                          selecteTime.month,
                          selecteTime.day,
                          time.hour,
                          time.minute);
                      _timeController.text =
                          DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ')
                              .format(selecteTime);
                    });
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite vrijeme!';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedFormat,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFormat = newValue;
                });
              },
              items: formats.map((String format) {
                return DropdownMenuItem<String>(
                  value: format,
                  child: Text(format),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Format'),
              validator: (value) {
                if (value == null) {
                  return 'Odaberite format!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Cijena'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Unesite cijenu!';
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
                  flex: 5,
                  child: Text(
                    "Date",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 4,
                  child: Text(
                    "StartTime",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 2,
                  child: Text(
                    "Movie",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 2,
                  child: Text(
                    "Format",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 2,
                  child: Text(
                    "Price",
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
              rows: shows
                      .map((Shows e) => DataRow(cells: [
                            DataCell(Text(e.id?.toString() ?? "")),
                            DataCell(Text(
                                '${DateFormat('dd.MM.yyyy').format(e.date)}'
                                        ?.toString() ??
                                    "")),
                            DataCell(Text(
                                '${DateFormat('HH:mm').format(e.startTime)}h'
                                        ?.toString() ??
                                    "")),
                            DataCell(Text(e.movie.title?.toString() ?? "")),
                            DataCell(Text(e.format?.toString() ?? "")),
                            DataCell(Text(e.price?.toString() ?? "")),
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
                                            ? 'Uredi projekciju'
                                            : 'Dodaj projekciju'),
                                        content: SingleChildScrollView(
                                          child: AddShowForm(
                                              isEditing: isEditing,
                                              showToEdit:
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
                                                EditShow(e.id);
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
                                        title: Text("Izbrisi projekciju"),
                                        content: SingleChildScrollView(
                                            child: Text(
                                                "Da li ste sigurni da zelite obisati projekciju?")),
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
                                              DeleteShow(e.id);
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

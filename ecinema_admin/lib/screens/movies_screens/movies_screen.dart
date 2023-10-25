

import 'dart:io';

import 'package:ecinema_admin/models/actor.dart';
import 'package:ecinema_admin/models/language.dart';
import 'package:ecinema_admin/models/movie.dart';
import 'package:ecinema_admin/models/production.dart';
import 'package:ecinema_admin/providers/actor_provider.dart';
import 'package:ecinema_admin/providers/genre_provider.dart';
import 'package:ecinema_admin/providers/language_provider.dart';
import 'package:ecinema_admin/providers/movie_provider.dart';
import 'package:ecinema_admin/providers/production_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/genre.dart';
import '../../utils/error_dialog.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<Movie> movies = <Movie>[];
  List<Genre> genres = <Genre>[];
  List<Language> languages = <Language>[];
  List<Production> productions = <Production>[];
  List<Actor> actors = <Actor>[];
  late MovieProvider _movieProvider;
  late GenreProvider _genreProvider;
  late LanguageProvider _languageProvider;
  late ProductionProvider _productionProvider;
  late ActorProvider _actorProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _relaseYearController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _numberOfViewsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  int? selectedLanguageId;
  int? selectedProductionId;
  int? selectedgenreId;

  @override
  void initState() {
    super.initState();
    _movieProvider=context.read<MovieProvider>();
    _genreProvider=context.read<GenreProvider>();
    _languageProvider=context.read<LanguageProvider>();
    _productionProvider=context.read<ProductionProvider>();
    _actorProvider=context.read<ActorProvider>();
    loadMovies('');
    loadGenres();
    loadLanguages();
    loadProductions();
    loadActors();
    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadMovies(searchQuery);
    });
  }



  void loadMovies(String? query) async {
    var params;
    try {
      if (query != null) {
        params = query;
      } else {
        params = null;
      }
      var moviesResponse = await _movieProvider.get({'params': params});
      setState(() {
        movies = moviesResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }
  void loadGenres() async {
    try {
      var genresResponse = await _genreProvider.get(null);
      setState(() {
        genres = genresResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
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
  void loadActors() async {
    try {
      var actorsResponse = await _actorProvider.get(null);
      setState(() {
        actors = actorsResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void loadProductions() async {
    try {
      var productionResponse = await _productionProvider.get(null);
      setState(() {
        productions = productionResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Movies"),
      ),
      body: Center(
        child: Container(
          width: 1500,
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
                              title: Text('Dodaj film'),
                              content: SingleChildScrollView(
                                child: AddMovieForm(),
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

  Widget AddMovieForm({bool isEditing = false, Movie? movieToEdit}) {
    if (movieToEdit != null) {

    } else {

    }

    return Container(
      height: 500,
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
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Naziv'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite naziv!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _relaseYearController,
                    decoration: InputDecoration(labelText: 'Godina izdavanja'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite godinu izdavanja!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(labelText: 'Autor'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite autora!';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedgenreId,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedgenreId = newValue;
                      });
                    },
                    items: genres.map((Genre genre) {
                      return DropdownMenuItem<int>(
                        value: genre.id,
                        child: Text(genre.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Žanr'),
                    validator: (value) {
                      if (value == null) {
                        return 'Odaberite žanr!';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedLanguageId,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedLanguageId = newValue;
                      });
                    },
                    items: languages.map((Language language) {
                      return DropdownMenuItem<int>(
                        value: language.id,
                        child: Text(language.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Jezik'),
                    validator: (value) {
                      if (value == null) {
                        return 'Odaberite jezik!';
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
                    controller: _durationController,
                    decoration: InputDecoration(labelText: 'Trajanje'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Unesite trajanje!';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedProductionId,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedProductionId = newValue;
                      });
                    },
                    items: productions.map((Production production) {
                      return DropdownMenuItem<int>(
                        value: production.id,
                        child: Text(production.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Produkcija'),
                    validator: (value) {
                      if (value == null) {
                        return 'Odaberite produkciju!';
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
                        "Title",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Author",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "ReleaseYear",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "Length",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "Duration",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "NumberOfViews",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 2,
                      child: Text(
                        "Production",
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
              rows: movies
                  .map((Movie e) =>
                  DataRow(
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.title?.toString()  ?? "")),
                        DataCell(Text(e.author?.toString()  ?? "")),
                        DataCell(Text(e.releaseYear?.toString()  ?? "")),
                        DataCell(Text(e.length?.toString()  ?? "")),
                        DataCell(Text(e.duration?.toString()  ?? "")),
                        DataCell(Text(e.numberOfViews?.toString()  ?? "")),
                        DataCell(Text(e.production.name?.toString()  ?? "")),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                            },
                            child: Text("Edit"),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
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

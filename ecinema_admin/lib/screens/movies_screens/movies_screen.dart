import 'package:ecinema_admin/models/movie.dart';
import 'package:ecinema_admin/providers/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/error_dialog.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<Movie> movies = <Movie>[];
  late MovieProvider _movieProvider;
  @override
  void initState() {
    super.initState();
    _movieProvider=context.read<MovieProvider>();
    loadMovies();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text("Movies")
        ),
        body: Container(
            child: Column(
              children: [
                _buildDataListView()
              ],
            )
        )
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
                      onSelectChanged: (selected) =>
                      {

                      },
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
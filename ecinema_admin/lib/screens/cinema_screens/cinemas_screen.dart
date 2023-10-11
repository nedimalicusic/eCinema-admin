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
  late CinemaProvider _cinemaProvider;
  @override
  void initState() {
    super.initState();
    _cinemaProvider=context.read<CinemaProvider>();
    loadCinema();
  }

  void loadCinema() async {
    try {
      var cinemasResponse = await _cinemaProvider.get(null);
      setState(() {
        cinemas = cinemasResponse;
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
        title: Text("Cinemas"),
      ),
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
                              title: Text('Dodaj državu'),
                              content: SingleChildScrollView(
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
            onSelectChanged: (selected) =>
            {

        },
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

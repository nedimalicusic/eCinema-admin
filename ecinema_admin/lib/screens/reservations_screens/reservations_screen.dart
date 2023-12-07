import 'package:ecinema_admin/models/reservation.dart';
import 'package:ecinema_admin/models/seats.dart';
import 'package:ecinema_admin/models/shows.dart';
import 'package:ecinema_admin/models/user.dart';
import 'package:ecinema_admin/providers/seats_provider.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reservation_provider.dart';
import '../../providers/show_provider.dart';
import '../../utils/error_dialog.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> reservations = <Reservation>[];
  late ReservationProvider _reservationProvider;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String? selectedCinema;
  String? selectedMovie;
  String? selectedUser;
  String? selectedSeat;
  int? selectedShowId;
  int? selectedSeatId;
  int? selectedUserId;
  bool isActive = false;
  bool isConfirm = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reservationProvider = context.read<ReservationProvider>();
    loadReservations('');
    _searchController.addListener(() {
      final searchQuery = _searchController.text;
      loadReservations(searchQuery);
    });

  }

  void loadReservations(String? query) async {
    var params;
    try {
      if (query != null) {
        params = query;
      } else {
        params = null;
      }
      var reservationsResponse = await _reservationProvider.get({'params': params});
      setState(() {
        reservations = reservationsResponse;
      });
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void EditReservation(int id) async {
    try {
      var editReservation = {
        "id": id,
        "showId": selectedShowId,
        "seatId": selectedSeatId,
        "userId": selectedUserId,
        "isActive": isActive,
        "isConfirm": isConfirm,
      };
      var city = await _reservationProvider.edit(editReservation);
      if (city == "OK") {
        Navigator.of(context).pop();
        loadReservations('');
      }
    } on Exception catch (e) {
      showErrorDialog(context, e.toString().substring(11));
    }
  }

  void DeleteReservation(int id) async {
    try {
      var actor = await _reservationProvider.delete(id);
      if (actor == "OK") {
        Navigator.of(context).pop();
        loadReservations('');
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
          width: 1180,
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
                        // Dodajte logiku za pretragu ovde
                      ),
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

  Widget EditReservationForm(
      {bool isEditing = false, Reservation? reservationToEdit}) {
    if (reservationToEdit != null) {
      selectedCinema = reservationToEdit.show.cinema.name;
      selectedShowId = reservationToEdit.showId;
      selectedMovie = reservationToEdit.show.movie.title;
      selectedSeatId = reservationToEdit.seatId;
      selectedUser = reservationToEdit.user.firstName + " "+ reservationToEdit.user.lastName;
      selectedUserId = reservationToEdit.userId;
      selectedSeat='${reservationToEdit.seat.row?.toString() ?? ""}${reservationToEdit.seat.column?.toString() ?? ""}';
      isActive = reservationToEdit.isActive;
      isConfirm = reservationToEdit.isConfirm;
    }

    return Container(
      height: 340,
      width: 350,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Kino'),
            enabled: false,
            initialValue: selectedCinema,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Film'),
            enabled: false,
            initialValue: selectedMovie,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Sjedalo'),
            enabled: false,
            initialValue: selectedSeat,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Korisnik'),
            enabled: false,
            initialValue: selectedUser,
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Checkbox(
                value:isActive,
                onChanged: (bool? value) {
                  isActive=!isActive;
                },
              ),
              Text('Aktivna'),
            ],
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Checkbox(
                value:isConfirm,
                onChanged: (bool? value) {
                  isConfirm=!isConfirm;
                },
              ),
              Text('Potvrdjena'),
            ],
          ),
        ]),
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
                  child: Text(
                    "ID",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  child: Text(
                    "Cinema",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  child: Text(
                    "Movie",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  child: Text(
                    "Seat",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 5,
                  child: Text(
                    "isActive",
                    style: const TextStyle(fontStyle: FontStyle.normal),
                  ),
                )),
                DataColumn(
                    label: Expanded(
                  flex: 5,
                  child: Text(
                    "isConfirm",
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
              rows: reservations
                      .map((Reservation e) => DataRow(cells: [
                            DataCell(Text(e.id?.toString() ?? "")),
                            DataCell(
                                Text(e.show.cinema.name?.toString() ?? "")),
                            DataCell(
                                Text(e.show.movie.title?.toString() ?? "")),
                            DataCell(Text(
                                '${e.seat.row?.toString() ?? ""}${e.seat.column?.toString() ?? ""}')),
                            DataCell(Text(e.isActive?.toString() ?? "")),
                            DataCell(Text(e.isConfirm?.toString() ?? "")),
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
                                            ? 'Uredi rezervaciju'
                                            : 'Dodaj rezervaciju'),
                                        content: SingleChildScrollView(
                                          child: EditReservationForm(
                                              isEditing: isEditing,
                                              reservationToEdit:
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
                                                EditReservation(e.id);
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
                                        title: Text("Izbrisi rezervaciju"),
                                        content: SingleChildScrollView(
                                            child: Text(
                                                "Da li ste sigurni da zelite obisati rezervaciju?")),
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
                                              DeleteReservation(e.id);
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

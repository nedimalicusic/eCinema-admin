import 'package:ecinema_admin/models/actor.dart';
import 'package:ecinema_admin/providers/actor_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/error_dialog.dart';

class ActorsScreen extends StatefulWidget {
  const ActorsScreen({Key? key}) : super(key: key);

  @override
  State<ActorsScreen> createState() => _ActorsScreenState();
}

class _ActorsScreenState extends State<ActorsScreen> {
  List<Actor> actors = <Actor>[];
  late ActorProvider _actorProvider;
  @override
  void initState() {
    super.initState();
    _actorProvider=context.read<ActorProvider>();
    loadActors();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text("Actors")
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
                        "FirstName",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "LastName",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Email",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "BirthDate",
                        style: const TextStyle(fontStyle: FontStyle.normal),
                      ),
                    )),
                DataColumn(
                    label: Expanded(
                      flex: 4,
                      child: Text(
                        "Gender",
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
              rows: actors
                  .map((Actor e) =>
                  DataRow(
                      onSelectChanged: (selected) =>
                      {

                      },
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.firstName?.toString()  ?? "")),
                        DataCell(Text(e.lastName?.toString()  ?? "")),
                        DataCell(Text(e.email?.toString()  ?? "")),
                        DataCell(Text('${DateFormat('dd.MM.yyyy').format(DateTime.parse( e.birthDate))}' ?.toString()  ?? "")),
                        DataCell(Text(e.gender == 0 ? "Male" : "Female")),
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

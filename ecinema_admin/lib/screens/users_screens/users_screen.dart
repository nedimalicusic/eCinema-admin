import 'package:ecinema_admin/models/user.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/error_dialog.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = <User>[];
  late UserProvider _userProvider;
  
  @override
  void initState() {
    super.initState();
    _userProvider=context.read<UserProvider>();
    loadUsers();
  }

  void loadUsers() async {
    try {
      var userResponse = await _userProvider.get(null);
      setState(() {
        users = userResponse;
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
            title: Text("Users")
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
                        "PhoneNumber",
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
              rows: users
                  .map((User e) =>
                  DataRow(
                      onSelectChanged: (selected) =>
                      {

                      },
                      cells: [
                        DataCell(Text(e.Id?.toString() ?? "")),
                        DataCell(Text(e.FirstName?.toString()  ?? "")),
                        DataCell(Text(e.LastName?.toString()  ?? "")),
                        DataCell(Text(e.Email?.toString()  ?? "")),
                        DataCell(Text(e.PhoneNumber?.toString()  ?? "")),
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

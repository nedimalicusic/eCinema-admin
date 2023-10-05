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
  @override
  void initState() {
    super.initState();
    _languageProvider=context.read<LanguageProvider>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text("Languages")
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
                  .map((Language e) =>
                  DataRow(
                      onSelectChanged: (selected) =>
                      {
                      },
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.name?.toString()  ?? "")),
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

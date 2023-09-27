import 'package:flutter/material.dart';

class AddCinemaScreen extends StatefulWidget {
  const AddCinemaScreen({Key? key}) : super(key: key);

  @override
  State<AddCinemaScreen> createState() => _AddCinemaScreenState();
}

class _AddCinemaScreenState extends State<AddCinemaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("Add Cinema")
        ),
        body: Text("Add Cinemas")
    );
  }
}

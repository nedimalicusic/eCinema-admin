import 'package:flutter/material.dart';

class ActorsScreen extends StatefulWidget {
  const ActorsScreen({Key? key}) : super(key: key);

  @override
  State<ActorsScreen> createState() => _ActorsScreenState();
}

class _ActorsScreenState extends State<ActorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text("Actors")
        ),
        body: Text("Actors")
    );
  }
}

import 'package:flutter/material.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({Key? key}) : super(key: key);

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text("Cinemas")
        ),
        body: Text("Cinemas")
    );
  }
}

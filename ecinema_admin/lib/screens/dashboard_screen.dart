import 'package:ecinema_admin/models/cinema.dart';
import 'package:ecinema_admin/screens/movies_screens/movies_screen.dart';
import 'package:ecinema_admin/screens/side_mene_cinema.dart';
import 'package:flutter/material.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key,required this.cinema }) : super(key: key);

  static const routeName = '/dashboard';
  final Cinema cinema;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Widget _currentPage = MoviesScreen();

  void _changePage(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SideMenuCinema(onMenuItemClicked: _changePage,cinema: widget.cinema,),
            ),
            Expanded(
              flex: 5,
              child: _currentPage,
            ),
          ],
        ),
      ),
    );
  }
}

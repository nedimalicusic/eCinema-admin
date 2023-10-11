import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/side_menu.dart';
import 'package:flutter/material.dart';

import 'cinema_screens/cinemas_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget _currentPage = DashboardScreen();

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
                child: SideMenu(onMenuItemClicked: _changePage),
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

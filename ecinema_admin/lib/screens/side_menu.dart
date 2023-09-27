import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

import 'cinema_screens/add_cinema_screen.dart';
import 'cinema_screens/cinemas_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
    required this.onMenuItemClicked,
  }) : super(key: key);

  final Function(Widget) onMenuItemClicked;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DrawerListTile(
                  title: "Home",
                  press: () {
                    widget.onMenuItemClicked(DashboardScreen());
                  },
                ),
                DrawerListTile(
                  title: "Cinemas",
                  press: () {
                    widget.onMenuItemClicked(CinemasScreen());
                  },
                ),
                DrawerListTile(
                  title: "Add Cinema",
                  press: () {
                    widget.onMenuItemClicked(AddCinemaScreen());
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30), // Postavite željenu marginu ovdje
            child: DrawerListTile(
              title: "Logout",
              press: () {
                // Ovdje možete implementirati logiku za odjavu
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

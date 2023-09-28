import 'package:ecinema_admin/models/cinema.dart';
import 'package:ecinema_admin/screens/actors_screens/actors_screen.dart';
import 'package:ecinema_admin/screens/employees_screens/employees_screen.dart';
import 'package:ecinema_admin/screens/genres_screens/genres_screen.dart';
import 'package:ecinema_admin/screens/movies_screens/movies_screen.dart';
import 'package:ecinema_admin/screens/productions_screens/productions_screen.dart';
import 'package:ecinema_admin/screens/reservations_screens/reservations_screen.dart';
import 'package:ecinema_admin/screens/shows_screens/shows_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';


class SideMenuCinema extends StatefulWidget {
  const SideMenuCinema({Key? key, required this.onMenuItemClicked, required this.cinema}) : super(key: key);

  final Function(Widget) onMenuItemClicked;
  final Cinema cinema;

  @override
  State<SideMenuCinema> createState() => _SideMenuCinemaState();
}

class _SideMenuCinemaState extends State<SideMenuCinema> {

  late UserProvider userProvider;
  late User? user;

  @override
  void initState() {
    super.initState();
  userProvider=context.read<UserProvider>();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 30,top: 20), // Postavite željenu marginu ovdje
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,  color: Colors.white,size: 20,),
                        SizedBox(width: 5),
                        Text(
                          widget.cinema.name.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Dodajte vertikalnu marginu ovde
                ),
                DrawerListTile(
                  title: "Production",
                  press: () {
                    widget.onMenuItemClicked(ProductionScreen());
                  },
                ),
                DrawerListTile(
                  title: "Reservations",
                  press: () {
                    widget.onMenuItemClicked(ReservationsScreen());
                  },
                ),
                DrawerListTile(
                  title: "Movies",
                  press: () {
                    widget.onMenuItemClicked(MoviesScreen());
                  },
                ),
                DrawerListTile(
                  title: "Genres",
                  press: () {
                    widget.onMenuItemClicked(GenresScreen());
                  },
                ),
                DrawerListTile(
                  title: "Actors",
                  press: () {
                    widget.onMenuItemClicked(ActorsScreen());
                  },
                ),
                DrawerListTile(
                  title: "Shows",
                  press: () {
                    widget.onMenuItemClicked(ShowsScreen());
                  },
                ),
                DrawerListTile(
                  title: "Users",
                  press: () {
                    widget.onMenuItemClicked(MoviesScreen());
                  },
                ),
                DrawerListTile(
                  title: "Employees",
                  press: () {
                    widget.onMenuItemClicked(EmployeesScreen());
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30), // Postavite željenu marginu ovdje
            child:ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: userProvider.logout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Logout')
                ],
              ),
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


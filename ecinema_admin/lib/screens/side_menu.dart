import 'package:ecinema_admin/models/loginUser.dart';
import 'package:ecinema_admin/screens/cities_screens/city_screen.dart';
import 'package:ecinema_admin/screens/countries_screens/counry_screen.dart';
import 'package:ecinema_admin/screens/languages_screens/langauge_screen.dart';
import 'package:ecinema_admin/screens/productions_screens/productions_screen.dart';
import 'package:ecinema_admin/screens/reservations_screens/reservations_screen.dart';
import 'package:ecinema_admin/screens/shows_screens/shows_screen.dart';
import 'package:ecinema_admin/screens/users_screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/login_provider.dart';
import '../providers/user_provider.dart';
import 'actors_screens/actors_screen.dart';
import 'cinema_screens/cinemas_screen.dart';
import 'dashboard_screen.dart';
import 'employees_screens/employees_screen.dart';
import 'genres_screens/genres_screen.dart';
import 'login_screen.dart';
import 'movies_screens/movies_screen.dart';

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
  late LoginProvider loginUserProvider;
  late LoginUser? loginUser;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    loginUserProvider=context.read<LoginProvider>();
  }

  @override
  Widget build(BuildContext context) {

    loginUser = context.watch<LoginProvider>().loginUser;
    if (loginUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      });
      return Container();
    }

    return Drawer(
      backgroundColor: Colors.teal,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 30,top: 20), // Postavite željenu marginu ovdje
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'eCinema',
                          style: TextStyle(
                            fontSize: 20, // Postavite željenu veličinu fonta
                            fontWeight: FontWeight.bold,
                            color: Colors.white// Boldirajte tekst
                          ),
                        )
                      ],
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Dodajte vertikalnu marginu ovde
                ),
                DrawerListTile(
                  title: "Dashboard",
                  press: () {
                    widget.onMenuItemClicked(DashboardScreen());
                  },
                ),
                ExpansionTile(
                  onExpansionChanged: (value) {
                    setState(() {
                      isExpanded = value; // Ažurirajte stanje kada se meni otvori/zatvori
                    });
                  },
                  title: Text("Referentni podaci",style: TextStyle(color: Colors.white),),
                  children: <Widget>[
                    DrawerListTile(
                      title: "Countries",
                      press: () {
                        widget.onMenuItemClicked(CountryScreen());
                      },
                    ),
                    DrawerListTile(
                      title: "Cities",
                      press: () {
                        widget.onMenuItemClicked(CityScreen());
                      },
                    ),
                    DrawerListTile(
                      title: "Languages",
                      press: () {
                        widget.onMenuItemClicked(LanguageScreen());
                      },
                    ),
                  ],
                  trailing: Icon(
                    !isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, // Ikona za strelicu
                    color: Colors.white, // Boja strelice
                  ),
                ),
                DrawerListTile(
                  title: "Cinemas",
                  press: () {
                    widget.onMenuItemClicked(CinemasScreen());
                  },
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
                    widget.onMenuItemClicked(UsersScreen());
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
            margin: EdgeInsets.only(bottom: 5), // Postavite željenu marginu ovdje
            child:ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: loginUserProvider.logout,
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

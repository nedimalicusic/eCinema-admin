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

    loginUserProvider = context.read<LoginProvider>();
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0), // Dodajte vertikalnu marginu ovde
                ),
                ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.white,),
                  title: Text("Dashboard",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(DashboardScreen());
                  },
                ),
                ExpansionTile(
                  onExpansionChanged: (value) {
                    setState(() {
                      isExpanded = value;
                    });
                  },
                  leading: Icon(Icons.category, color: Colors.white),
                  title: Text("Referentni podaci", style: TextStyle(color: Colors.white),
                  ),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.adjust_rounded, color: Colors.white,),
                      title: Text("Countries",style: TextStyle(color: Colors.white),),
                      onTap: () {
                        widget.onMenuItemClicked(CountryScreen());
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.location_city_rounded, color: Colors.white,),
                      title: Text("Cities",style: TextStyle(color: Colors.white),),
                      onTap: () {
                        widget.onMenuItemClicked(CityScreen());
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.language, color: Colors.white,),
                      title: Text("Languages",style: TextStyle(color: Colors.white),),
                      onTap: () {
                        widget.onMenuItemClicked(LanguageScreen());
                      },
                    ),
                  ],
                  trailing: Icon(
                    !isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right, // Ikona za strelicu
                    color: Colors.white, // Boja strelice
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home_outlined, color: Colors.white,),
                  title: Text("Cinemas",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(CinemasScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.production_quantity_limits, color: Colors.white,),
                  title: Text("Production",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(ProductionScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.check, color: Colors.white,),
                  title: Text("Reservation",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(ReservationsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.movie_creation_outlined, color: Colors.white,),
                  title: Text("Movies",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(MoviesScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.movie_filter_outlined, color: Colors.white,),
                  title: Text("Genres",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(GenresScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white,),
                  title: Text("Actors",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(ActorsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.slideshow, color: Colors.white,),
                  title: Text("Shows",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(ShowsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white,),
                  title: Text("Users",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(UsersScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white,),
                  title: Text("Employees",style: TextStyle(color: Colors.white),),
                  onTap: () {
                    widget.onMenuItemClicked(EmployeesScreen());
                  },
                ),
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(bottom: 5), // Postavite željenu marginu ovdje
            child: ElevatedButton(
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

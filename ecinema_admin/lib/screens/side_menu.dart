import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import 'cinema_screens/add_cinema_screen.dart';
import 'cinema_screens/cinemas_screen.dart';
import 'login_screen.dart';

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
  late UserProvider userProvider;
  late User? user;

  @override
  void initState() {
    super.initState();

    userProvider=context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {

    user = context.watch<UserProvider>().user;
    if (user == null) {
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

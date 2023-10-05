import 'package:ecinema_admin/models/cinema.dart';
import 'package:ecinema_admin/providers/actor_provider.dart';
import 'package:ecinema_admin/providers/cinema_provider.dart';
import 'package:ecinema_admin/providers/city_provider.dart';
import 'package:ecinema_admin/providers/country_provider.dart';
import 'package:ecinema_admin/providers/employee_provider.dart';
import 'package:ecinema_admin/providers/genre_provider.dart';
import 'package:ecinema_admin/providers/language_provider.dart';
import 'package:ecinema_admin/providers/movie_provider.dart';
import 'package:ecinema_admin/providers/production_provider.dart';
import 'package:ecinema_admin/providers/reservation_provider.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/home_screen.dart';
import 'package:ecinema_admin/screens/login_screen.dart';
import 'package:ecinema_admin/screens/reservations_screens/reservations_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CinemaProvider()),
          ChangeNotifierProvider(create: (_) => ProductionProvider()),
          ChangeNotifierProvider(create: (_) => ReservationProvider()),
          ChangeNotifierProvider(create: (_) => MovieProvider()),
          ChangeNotifierProvider(create: (_) => ActorProvider()),
          ChangeNotifierProvider(create: (_) => EmployeeProvider()),
          ChangeNotifierProvider(create: (_) => GenreProvider()),
          ChangeNotifierProvider(create: (_) => CountryProvider()),
          ChangeNotifierProvider(create: (_) => CityProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
          },
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    User? user = userProvider.user;
    if (user == null) {
      return const LoginScreen();
    }

    return LoginScreen();
  }
}

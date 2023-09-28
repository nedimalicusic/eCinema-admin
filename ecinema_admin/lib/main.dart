import 'package:ecinema_admin/models/cinema.dart';
import 'package:ecinema_admin/providers/cinema_provider.dart';
import 'package:ecinema_admin/providers/user_provider.dart';
import 'package:ecinema_admin/screens/dashboard_screen.dart';
import 'package:ecinema_admin/screens/home_screen.dart';
import 'package:ecinema_admin/screens/login_screen.dart';
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
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == DashboardScreen.routeName) {
              return MaterialPageRoute(
                  builder: (context) =>
                      DashboardScreen(cinema: settings.arguments as Cinema));
            }
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

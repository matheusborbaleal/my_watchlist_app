import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_watchlist_app/firebase_options.dart';

import 'package:my_watchlist_app/screens/home_screen.dart';
import 'package:my_watchlist_app/screens/auth_screen.dart';
import 'package:my_watchlist_app/screens/search_screen.dart';

import 'package:my_watchlist_app/providers/movie_series_provider.dart';
import 'package:my_auth_plugin/my_auth_plugin.dart';

import 'package:my_watchlist_app/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPluginProvider()),
        ChangeNotifierProvider(create: (_) => MovieSeriesProvider()),
        Provider<LocationService>(create: (_) => LocationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Watchlist App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthPluginProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user != null) {
            return const HomeScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/search': (context) => const SearchScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Text('Erro: Rota não encontrada!'),
        );
      },
    );
  }
}

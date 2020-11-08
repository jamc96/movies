import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/movies.dart';
import './screens/movies_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Movies()),
      ],
      child: MaterialApp(
        title: 'Movies',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => MoviesScreen(),
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stateful Changes Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.figtreeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const RestDemoScreen(),
    );
    // return MaterialApp.router(
    //   debugShowCheckedModeBanner: false,
    //   routerConfig: GlobalRouter().router,
    //   title: 'Stateful Changes Demo',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    // );
  }
}

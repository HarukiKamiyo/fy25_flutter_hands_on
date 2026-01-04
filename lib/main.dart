import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/home_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        // [差分] テーマカラーを DeepOrange に変更
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: MyHomePage(),
    );
  }
}

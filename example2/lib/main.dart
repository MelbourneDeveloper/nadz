import 'package:example2/async_snapshot_nad.dart';
import 'package:flutter/material.dart';
import 'package:nadz/nadz.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nadz Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: FutureBuilder(
              future: getText(),
              builder: (context, snapshot) => snapshot
                  .toOptionalAsyncSnapshotNad()
                  .match(
                    onLeft: (n) => const CircularProgressIndicator.adaptive(),
                    onRight: (s) => Text(s | 'Error'),
                  ),
            ),
          ),
        ),
      );
}

Future<String> getText() =>
    Future<String>.delayed(const Duration(seconds: 1), () => 'Hello, world!');

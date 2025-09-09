// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:example/core/services/routers/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ExampleRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'PayPal Integration Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home:  HomePage(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/home/home_screen.dart';
import '../../../features/splash/splash_screen.dart';
import '../../../features/transaction/screens/transaction_screen.dart';

class ExampleRouter{
  static const String splash = '/splash';
  static const String home = '/home';
  static const String transaction = '/transaction';
  static const String refund = '/refund';

  static String toName(String path) => path.replaceFirst('/', '');


  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: home,
        name: toName(home),
        builder: (BuildContext context, GoRouterState state) {
          return  HomePage();
        },
        routes: [
          GoRoute(
            path: transaction,
            name: toName(transaction),
            builder: (BuildContext context, GoRouterState state) {
              return const TransactionHistoryScreen();
            },
          ),
        ]
      ),
      GoRoute(
        path: splash,
        builder: (BuildContext context, GoRouterState state) {
          return  SplashScreen();
        },
      ),
    ],
  );
}

class DummyPage extends StatelessWidget {
  const DummyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

import 'package:flutter/material.dart';

import 'pages/desktop_home_page.dart';
import 'pages/order_page.dart';
import 'pages/settings_page.dart';

class PrntatApp extends StatelessWidget {
  const PrntatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prntat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        if (name.startsWith('/order')) {
          return MaterialPageRoute(builder: (_) => const OrderPage());
        }
        if (name == '/settings') {
          return MaterialPageRoute(builder: (_) => const SettingsPage());
        }
        return MaterialPageRoute(builder: (_) => const DesktopHomePage());
      },
    );
  }
}

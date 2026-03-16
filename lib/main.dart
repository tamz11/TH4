import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th4/providers/cart_provider.dart';
import 'package:th4/providers/order_provider.dart';
import 'package:th4/providers/product_provider.dart';
import 'package:th4/screens/home_screen.dart';

void main() {
  runApp(const Th4App());
}

class Th4App extends StatelessWidget {
  const Th4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TH4 Mini E-Commerce',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEE4D2D)),
          scaffoldBackgroundColor: const Color(0xFFF6F6F6),
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: const CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

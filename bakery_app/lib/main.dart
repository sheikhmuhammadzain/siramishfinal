import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Sheikh Bakery',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: auth.isAuth ? const HomeScreen() : const LoginScreen(),
          onGenerateRoute: (settings) {
            if (!auth.isAuth && settings.name != '/login') {
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
                settings: settings,
              );
            }
            
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                  settings: settings,
                );
              case '/cart':
                return MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                  settings: settings,
                );
              case '/checkout':
                return MaterialPageRoute(
                  builder: (_) => const CheckoutScreen(),
                  settings: settings,
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                  settings: settings,
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                  settings: settings,
                );
            }
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/admin_orders_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/account_screen.dart';
import 'screens/dashboard_screen.dart';
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
          home: null,
          onGenerateRoute: (settings) {
            if (!auth.isAuth && settings.name != '/login') {
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
                settings: settings,
              );
            }

            // Admin routes
            if (auth.isAdmin) {
              switch (settings.name) {
                case '/':
                case '/admin':
                  return MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                    settings: settings,
                  );
                case '/admin/products':
                  return MaterialPageRoute(
                    builder: (_) => const AdminProductsScreen(),
                    settings: settings,
                  );
                case '/admin/orders':
                  return MaterialPageRoute(
                    builder: (_) => const AdminOrdersScreen(),
                    settings: settings,
                  );
                case '/admin/users':
                  return MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                    settings: settings,
                  );
                case '/admin/analytics':
                  return MaterialPageRoute(
                    builder: (_) => const AdminAnalyticsScreen(),
                    settings: settings,
                  );
              }
            }

            // Regular user routes
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                  settings: settings,
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                  settings: settings,
                );
              case '/home':
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
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                  settings: settings,
                );
              case '/account':
                return MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                  settings: settings,
                );
              case '/dashboard':
                return MaterialPageRoute(
                  builder: (_) => const DashboardScreen(),
                  settings: settings,
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => auth.isAdmin 
                    ? const AdminDashboardScreen() 
                    : const HomeScreen(),
                  settings: settings,
                );
            }
          },
        ),
      ),
    );
  }
}
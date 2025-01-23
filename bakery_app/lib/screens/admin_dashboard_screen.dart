import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
	const AdminDashboardScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.primary,
				title: Text(
					'Admin Dashboard',
					style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
				),
				automaticallyImplyLeading: false,
				actions: [
					PopupMenuButton<String>(
						icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary),
						itemBuilder: (ctx) => <PopupMenuEntry<String>>[
							PopupMenuItem<String>(
								value: 'users',
								child: ListTile(
									contentPadding: EdgeInsets.zero,
									leading: const Icon(Icons.people),
									title: const Text('Users'),
								),
							),
							PopupMenuItem<String>(
								value: 'products',
								child: ListTile(
									contentPadding: EdgeInsets.zero,
									leading: const Icon(Icons.shopping_bag),
									title: const Text('Products'),
								),
							),
							PopupMenuItem<String>(
								value: 'orders',
								child: ListTile(
									contentPadding: EdgeInsets.zero,
									leading: const Icon(Icons.receipt_long),
									title: const Text('Orders'),
								),
							),
							const PopupMenuDivider(),
							PopupMenuItem<String>(
								value: 'logout',
								child: ListTile(
									contentPadding: EdgeInsets.zero,
									leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
									title: Text(
										'Logout',
										style: TextStyle(color: Theme.of(context).colorScheme.error),
									),
								),
							),
						],
						onSelected: (value) {
							switch (value) {
								case 'users':
									Navigator.pushNamed(context, '/admin/users');
									break;
								case 'products':
									Navigator.pushNamed(context, '/admin/products');
									break;
								case 'orders':
									Navigator.pushNamed(context, '/admin/orders');
									break;
								case 'logout':
									Provider.of<AuthProvider>(context, listen: false).logout();
									Navigator.of(context).pushReplacementNamed('/');
									break;
							}
						},
					),
				],
			),
			body: GridView.count(
				padding: const EdgeInsets.all(16.0),
				crossAxisCount: 2,
				crossAxisSpacing: 16.0,
				mainAxisSpacing: 16.0,
				children: [
					_buildDashboardItem(
						context,
						'Manage Products',
						Icons.cake,
						() => Navigator.pushNamed(context, '/admin/products'),
					),
					_buildDashboardItem(
						context,
						'Manage Orders',
						Icons.shopping_bag,
						() => Navigator.pushNamed(context, '/admin/orders'),
					),
					_buildDashboardItem(
						context,
						'Manage Users',
						Icons.people,
						() => Navigator.pushNamed(context, '/admin/users'),
					),
					_buildDashboardItem(
						context,
						'Analytics',
						Icons.analytics,
						() => Navigator.pushNamed(context, '/admin/analytics'),
					),
				],
			),
		);
	}

	Widget _buildDashboardItem(
		BuildContext context,
		String title,
		IconData icon,
		VoidCallback onTap,
	) {
		return Card(
			elevation: 4.0,
			child: InkWell(
				onTap: onTap,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							icon,
							size: 48.0,
							color: Theme.of(context).primaryColor,
						),
						const SizedBox(height: 16.0),
						Text(
							title,
							style: const TextStyle(
								fontSize: 16.0,
								fontWeight: FontWeight.bold,
							),
							textAlign: TextAlign.center,
						),
					],
				),
			),
		);
	}
}
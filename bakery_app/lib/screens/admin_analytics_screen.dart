import 'package:flutter/material.dart';

class AdminAnalyticsScreen extends StatelessWidget {
	const AdminAnalyticsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Analytics'),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildSummaryCard(
							'Total Sales',
							'\$15,234.50',
							Icons.attach_money,
							Colors.green,
						),
						const SizedBox(height: 16.0),
						_buildSummaryCard(
							'Total Orders',
							'156',
							Icons.shopping_bag,
							Colors.blue,
						),
						const SizedBox(height: 16.0),
						_buildSummaryCard(
							'Active Users',
							'89',
							Icons.people,
							Colors.orange,
						),
						const SizedBox(height: 24.0),
						const Text(
							'Recent Orders',
							style: TextStyle(
								fontSize: 20.0,
								fontWeight: FontWeight.bold,
							),
						),
						const SizedBox(height: 16.0),
						_buildRecentOrdersList(),
						const SizedBox(height: 24.0),
						const Text(
							'Popular Products',
							style: TextStyle(
								fontSize: 20.0,
								fontWeight: FontWeight.bold,
							),
						),
						const SizedBox(height: 16.0),
						_buildPopularProductsList(),
					],
				),
			),
		);
	}

	Widget _buildSummaryCard(
		String title,
		String value,
		IconData icon,
		Color color,
	) {
		return Card(
			elevation: 4.0,
			child: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Row(
					children: [
						Icon(
							icon,
							size: 48.0,
							color: color,
						),
						const SizedBox(width: 16.0),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: const TextStyle(
										fontSize: 16.0,
										fontWeight: FontWeight.w500,
									),
								),
								const SizedBox(height: 4.0),
								Text(
									value,
									style: TextStyle(
										fontSize: 24.0,
										fontWeight: FontWeight.bold,
										color: color,
									),
								),
							],
						),
					],
				),
			),
		);
	}

	Widget _buildRecentOrdersList() {
		// TODO: Replace with actual orders data
		return Card(
			child: ListView.builder(
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemCount: 5,
				itemBuilder: (context, index) {
					return ListTile(
						title: Text('Order #${1000 + index}'),
						subtitle: Text('Customer ${index + 1}'),
						trailing: Text('\$${(50 + index * 10).toStringAsFixed(2)}'),
					);
				},
			),
		);
	}

	Widget _buildPopularProductsList() {
		// TODO: Replace with actual products data
		return Card(
			child: ListView.builder(
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemCount: 5,
				itemBuilder: (context, index) {
					return ListTile(
						leading: const CircleAvatar(
							child: Icon(Icons.cake),
						),
						title: Text('Product ${index + 1}'),
						subtitle: Text('${20 - index} orders'),
						trailing: Text('\$${(15 + index * 5).toStringAsFixed(2)}'),
					);
				},
			),
		);
	}
}
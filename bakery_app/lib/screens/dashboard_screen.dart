import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildDashboardCard(
                  title: 'Total Orders',
                  value: '12',
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  title: 'Active Orders',
                  value: '2',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _buildDashboardCard(
                  title: 'Completed',
                  value: '10',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  title: 'Cancelled',
                  value: '0',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Order #${1000 + index}'),
                    subtitle: Text(
                      index % 2 == 0 ? 'Delivered' : 'Processing',
                      style: TextStyle(
                        color: index % 2 == 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                    trailing: Text('\$${(index + 1) * 10}.00'),
                    onTap: () {
                      // TODO: Navigate to order details
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class Order {
  final int id;
  final String customerName;
  final double total;
  final DateTime date;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.total,
    required this.date,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      var totalAmount = json['total_amount'];
      if (totalAmount == null) {
        throw Exception('total_amount is null');
      }
      return Order(
        id: json['id'] ?? 0,
        customerName: json['user']?['username'] ?? 'Unknown',
        total: (totalAmount is int) ? totalAmount.toDouble() : double.parse(totalAmount.toString()),
        date: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'Pending',
        items: ((json['items'] as List?) ?? [])
            .map((item) => OrderItem.fromJson(item))
            .toList(),
      );
    } catch (e) {
      print('Error parsing order JSON: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      var price = json['price'];
      if (price == null) {
        throw Exception('price is null');
      }
      return OrderItem(
        productName: json['product']?['name'] ?? 'Unknown Product',
        quantity: json['quantity'] ?? 1,
        price: (price is int) ? price.toDouble() : double.parse(price.toString()),
      );
    } catch (e) {
      print('Error parsing order item JSON: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(context);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _apiService.getOrders();
      print('Received orders data: $orders'); // Debug print
      setState(() {
        _orders = orders.map((order) {
          print('Processing order: $order'); // Debug print
          return Order.fromJson(order);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadOrders: $e'); // Debug print
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(order.id, newStatus);
      _loadOrders(); // Refresh the orders list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (ctx, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ExpansionTile(
                    title: Text('Order #${order.id}'),
                    subtitle: Text(
                      '${order.customerName} - \$${order.total.toStringAsFixed(2)}',
                    ),
                    trailing: _buildStatusChip(order.status),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${_formatDate(order.date)}',
                            ),
                            const SizedBox(height: 8.0),
                            Text('Status: ${order.status}'),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    '${item.quantity}x ${item.productName} - \$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  ),
                                )),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _updateOrderStatus(order, 'Processing'),
                                  child: const Text('Process'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      _updateOrderStatus(order, 'Completed'),
                                  child: const Text('Complete'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      _updateOrderStatus(order, 'Cancelled'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
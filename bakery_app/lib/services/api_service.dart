import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final BuildContext context;

  ApiService(this.context);

  String? get _token => Provider.of<AuthProvider>(context, listen: false).token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<http.Response> _get(String url) async {
    return await http.get(Uri.parse(baseUrl + url), headers: _headers);
  }

  Future<http.Response> _post(String url, dynamic data) async {
    return await http.post(Uri.parse(baseUrl + url), headers: _headers, body: json.encode(data));
  }

  Future<http.Response> _patch(String url, dynamic data) async {
    return await http.patch(Uri.parse(baseUrl + url), headers: _headers, body: json.encode(data));
  }

  Future<http.Response> _delete(String url) async {
    return await http.delete(Uri.parse(baseUrl + url), headers: _headers);
  }

  // Products API
  Future<List<Product>> getProducts(String category) async {
    final url = category == 'all' 
        ? '$baseUrl/products/' 
        : '$baseUrl/products/?category=$category';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> createProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: _headers,
      body: json.encode(product),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create product');
  }

  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id/'),
      headers: _headers,
      body: json.encode(product),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  // Users API
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _get('/users/');
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await _post('/users/', userData);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      await _patch('/users/$userId/', userData);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _delete('/users/$userId/');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Orders API
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _get('/orders/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to load orders: Status ${response.statusCode}');
    } catch (e) {
      print('Error in getOrders: $e'); // Add logging
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _patch(
        '/orders/$orderId/',
        {'status': status},
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}

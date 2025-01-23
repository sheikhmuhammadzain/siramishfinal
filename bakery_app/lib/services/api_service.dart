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
    try {
      final url = category == 'all' ? '/products/' : '/products/?category=$category';
      final response = await _get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products: Status ${response.statusCode}');
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> product) async {
    try {
      final response = await _post('/products/', product);
      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      }
      print('Create product error: ${response.body}');
      throw Exception('Failed to create product: Status ${response.statusCode}');
    } catch (e) {
      print('Error in createProduct: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    try {
      final response = await _patch('/products/$id/', product);
      if (response.statusCode != 200) {
        print('Update product error: ${response.body}');
        throw Exception('Failed to update product: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateProduct: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await _delete('/products/$id/');
      if (response.statusCode != 204) {
        print('Delete product error: ${response.body}');
        throw Exception('Failed to delete product: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteProduct: $e');
      throw Exception('Failed to delete product: $e');
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

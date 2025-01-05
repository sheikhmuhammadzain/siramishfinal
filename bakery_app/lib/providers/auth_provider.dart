import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _refreshToken;
  String? _userId;

  bool get isAuth {
    print('isAuth called: token = $_token');
    return _token != null;
  }
  String? get token => _token;
  String? get userId => _userId;

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    try {
      final url = 'http://127.0.0.1:8000/api/$urlSegment/';
      
      final Map<String, String> requestData = {
        'username': email.split('@')[0],
        'email': email,
        'password': password,
      };

      print('Making request to: $url');
      print('Request data: $requestData');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 400) {
        try {
          final responseData = json.decode(response.body);
          if (responseData is Map<String, dynamic>) {
            final errorMessage = responseData['detail'] ?? 
                               responseData['error'] ?? 
                               responseData['message'] ??
                               'Authentication failed';
            throw Exception(errorMessage);
          }
          throw Exception('Authentication failed');
        } catch (e) {
          throw Exception('Authentication failed. Please try again.');
        }
      }

      final responseData = json.decode(response.body);
      print('Parsed response data: $responseData');

      if (urlSegment == 'register') {
        print('Registration successful, proceeding to login');
        return await _authenticate(email, password, 'login');
      }

      // Handle JWT response format
      if (responseData['access'] != null) {
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        
        // Extract user_id from the JWT token
        final payloadBase64 = _token!.split('.')[1];
        final payloadPadded = base64Url.normalize(payloadBase64);
        final payload = json.decode(utf8.decode(base64Url.decode(payloadPadded)));
        _userId = payload['user_id'].toString();

        print('Setting access token: $_token');
        print('Setting refresh token: $_refreshToken');
        print('Setting userId: $_userId');

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'refreshToken': _refreshToken,
          'userId': _userId,
        });
        await prefs.setString('userData', userData);
        print('Saved user data to SharedPreferences');

        notifyListeners();
        print('Notified listeners of auth state change');
      } else {
        throw Exception('No access token received from server');
      }

    } catch (error) {
      print('Authentication error: $error');
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Failed to connect to server. Please check your internet connection.');
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'register');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'login');
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _userId = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    
    notifyListeners();
    print('Logged out, tokens and userId cleared');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')!);
    _token = extractedUserData['token'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    
    notifyListeners();
    return true;
  }

  // Add method to refresh token when needed
  Future<bool> refreshToken() async {
    if (_refreshToken == null) {
      return false;
    }

    try {
      final url = 'http://127.0.0.1:8000/api/token/refresh/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'refresh': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['access'];
        
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'refreshToken': _refreshToken,
          'userId': _userId,
        });
        await prefs.setString('userData', userData);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}

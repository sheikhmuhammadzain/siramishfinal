import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _refreshToken;
  String? _userId;
  bool _isAdmin = false;

  bool get isAuth {
    return _token != null;
  }
  
  bool get isAdmin => _isAdmin;
  String? get token => _token;
  String? get userId => _userId;

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    try {
      final url = 'http://127.0.0.1:8000/api/$urlSegment/';
      
      final Map<String, String> requestData = urlSegment == 'register'
          ? {
              'email': email,
              'password': password,
            }
          : {
              'username': email.split('@')[0],
              'password': password,
            };

      print('Sending request to $url with data: ${json.encode(requestData)}'); // Debug log

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode >= 400) {
        try {
          final responseData = json.decode(response.body);
          if (responseData is Map<String, dynamic>) {
            final errorMessage = responseData['detail'] ?? 
                               responseData['error'] ?? 
                               responseData['message'] ??
                               responseData.values.first is List ? 
                               responseData.values.first.first :
                               'Authentication failed';
            throw Exception(errorMessage);
          }
          throw Exception('Authentication failed');
        } catch (e) {
          throw Exception('Authentication failed. Please try again.');
        }
      }

      final responseData = json.decode(response.body);

      if (urlSegment == 'register') {
        // For registration response, check if user is admin
        _isAdmin = responseData['is_staff'] ?? false;
        // After successful registration, login
        return await _authenticate(email, password, 'login');
      }

      if (responseData['access'] != null) {
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        
        // Parse JWT token to get user info
        final payloadBase64 = _token!.split('.')[1];
        final payloadPadded = base64Url.normalize(payloadBase64);
        final payload = json.decode(utf8.decode(base64Url.decode(payloadPadded)));
        
        _userId = payload['user_id'].toString();
        // Check both is_staff and is_superuser for admin status
        _isAdmin = payload['is_staff'] == true || payload['is_superuser'] == true;
        print('JWT Payload: $payload'); // Debug log
        print('User is admin: $_isAdmin'); // Debug log

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'isAdmin': _isAdmin,
        });
        await prefs.setString('userData', userData);

        notifyListeners();
      } else {
        throw Exception('No access token received from server');
      }
    } catch (error) {
      print('Authentication error: $error'); // Debug log
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
    _isAdmin = false;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    
    notifyListeners();
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
    _isAdmin = extractedUserData['isAdmin'] ?? false;
    
    notifyListeners();
    return true;
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      const url = 'http://127.0.0.1:8000/api/login/refresh/';
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
          'isAdmin': _isAdmin,
        });
        await prefs.setString('userData', userData);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      print('Token refresh error: $error'); // Debug log
      return false;
    }
  }
}

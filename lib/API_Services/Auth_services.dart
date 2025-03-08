import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.3:5000/api/auth';
  static const String _tokenKey = 'auth_token';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Cached token
  String? _cachedToken;
  
  // Get the stored token (uses cache if available)
  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }
  
  // Store token and update cache
  Future<bool> setToken(String token) async {
    _cachedToken = token;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_tokenKey, token);
  }
  
  // Clear token (for logout)
  Future<bool> clearToken() async {
    _cachedToken = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_tokenKey);
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Register a new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Verify email with token
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Email verification failed: ${e.toString()}'};
    }
  }

  // Login user with automatic token storage
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      // Automatically store token if login successful
      if (responseData['access_token'] != null) {
        await setToken(responseData['access_token']);
      }
      
      return responseData;
    } catch (e) {
      return {'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Request password reset
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Password reset request failed: ${e.toString()}'};
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Password reset failed: ${e.toString()}'};
    }
  }

  // Get user information with automatic token handling
  Future<Map<String, dynamic>> getUserInfo({String? token}) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await getToken() ?? '');
      
      if (authToken.isEmpty) {
        return {'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Failed to get user info: ${e.toString()}'};
    }
  }
  
  // Add authorization header to any request
  Map<String, String> getAuthHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
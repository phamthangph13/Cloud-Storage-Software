import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class CollectionService {
  String get baseUrl {
    // Xác định URL phù hợp dựa trên nền tảng
    if (kIsWeb) {
      return 'http://localhost:5000/api/collections';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/collections'; // Android emulator
    } else {
      return 'http://localhost:5000/api/collections'; // iOS simulator và các trường hợp khác
    }
    // Nếu chạy trên thiết bị thật, bạn nên sử dụng IP máy chủ thật thay vì localhost
    // return 'http://192.168.1.xxx:5000/api/collections';
  }
  
  // Create a new collection
  Future<Map<String, dynamic>> createCollection(String name, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message']);
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo bộ sưu tập: $e');
    }
  }
  
  // Get all collections for the current user
  Future<List<dynamic>> getAllCollections(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['collections'] ?? [];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message']);
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bộ sưu tập: $e');
    }
  }
  
  // Get details of a specific collection
  Future<Map<String, dynamic>> getCollectionDetails(String collectionId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$collectionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message']);
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy chi tiết bộ sưu tập: $e');
    }
  }
  
  // Get all files in a collection
  Future<Map<String, dynamic>> getCollectionFiles(String collectionId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$collectionId/files'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Không thể tải danh sách tệp tin');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách tệp tin trong bộ sưu tập: $e');
    }
  }
} 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;
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
  
  // For debugging purposes
  void _printDebugInfo(String url, http.Response response) {
    print('DEBUG: Called URL: $url');
    print('DEBUG: Status code: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');
    
    // Check if response is HTML
    if (response.body.trim().toLowerCase().startsWith('<!doctype html>') || 
        response.body.trim().toLowerCase().startsWith('<html>')) {
      print('DEBUG: Response appears to be HTML, not JSON');
    }
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

  // Move a collection to trash
  Future<Map<String, dynamic>> moveCollectionToTrash(String collectionId, String token) async {
    try {
      // Check if collectionId is valid
      if (collectionId == null || collectionId.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid collection ID: ID cannot be empty',
          'status_code': 400
        };
      }
      
      // Try the alternative API endpoint format for trash
      // According to API documentation, DELETE /api/collections/{collection_id} moves a collection to trash
      // So let's construct the URL using the base URL without collection-specific part
      final baseApiUrl = kIsWeb 
          ? 'http://localhost:5000/api' 
          : Platform.isAndroid 
              ? 'http://10.0.2.2:5000/api' 
              : 'http://localhost:5000/api';
              
      final url = '$baseApiUrl/collections/$collectionId';
      print('Trying to move collection to trash with alternative URL: $url');
      
      // Print the input parameters for debugging
      print('Collection ID: $collectionId');
      print('Token length: ${token.length}');
      print('Token starts with: ${token.substring(0, math.min(10, token.length))}...');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      // Print debugging information
      _printDebugInfo(url, response);

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error decoding success response: $e');
          return {'message': 'Collection moved to trash successfully'};
        }
      } else if (response.statusCode == 400) {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Bad request: Invalid collection data';
          print('Server returned 400 error: $errorMessage');
          
          // Special handling for specific error messages
          if (errorMessage.contains('Invalid collection ID')) {
            return {
              'success': false,
              'message': 'Invalid collection ID: The server could not process this ID',
              'status_code': 400,
              'original_message': errorMessage
            };
          }
          
          return {
            'success': false,
            'message': errorMessage,
            'status_code': 400
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Bad request: ${response.body}',
            'status_code': 400
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Collection not found',
          'status_code': 404
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to move collection to trash',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to move collection to trash: ${response.body}',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      print('Error moving collection to trash: $e');
      return {
        'success': false,
        'message': 'Error moving collection to trash: $e',
        'status_code': 500
      };
    }
  }
} 
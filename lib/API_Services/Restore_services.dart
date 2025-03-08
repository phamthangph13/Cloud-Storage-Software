import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class RestoreService {
  String get baseUrl {
    // Determine appropriate URL based on platform
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000'; // Android emulator
    } else {
      return 'http://localhost:5000'; // iOS simulator and other cases
    }
    // For real devices, you should use the actual server IP
    // return 'http://192.168.1.xxx:5000/api';
  }
  
  // For debugging purposes
  void _printDebugInfo(String url, http.Response response) {
    print('DEBUG: Called URL: $url');
    print('DEBUG: Status code: ${response.statusCode}');
    print('DEBUG: Response starts with: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
    
    // Check if response is HTML
    if (response.body.trim().toLowerCase().startsWith('<!doctype html>') || 
        response.body.trim().toLowerCase().startsWith('<html>')) {
      print('DEBUG: Response appears to be HTML, not JSON');
    }
  }
  
  // Get all items in trash
  Future<List<Map<String, dynamic>>> getTrashItems(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trash'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 401) {
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to fetch trash items');
      }
    } catch (e) {
      print('Trash API error: $e');
      // If we can't parse the error, show a more generic message
      if (e.toString().contains('FormatException')) {
        throw Exception('Could not connect to trash service. The server might be unavailable.');
      }
      throw Exception('Error fetching trash items: $e');
    }
  }
  
  // Restore a file from trash
  Future<Map<String, dynamic>> restoreFile(String fileId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trash/file/$fileId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to restore file');
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('Could not connect to restore service. The server might be unavailable.');
      }
      throw Exception('Error restoring file: $e');
    }
  }
  
  // Restore a collection from trash
  Future<Map<String, dynamic>> restoreCollection(String collectionId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trash/collection/$collectionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to restore collection');
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('Could not connect to restore service. The server might be unavailable.');
      }
      throw Exception('Error restoring collection: $e');
    }
  }
  
  // Permanently delete an item from trash
  Future<Map<String, dynamic>> permanentlyDeleteItem(String itemId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/trash/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to permanently delete item');
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('Could not connect to trash service. The server might be unavailable.');
      }
      throw Exception('Error permanently deleting item: $e');
    }
  }
  
  // Add this fallback method for handling demo mode items
  bool isDemoItem(String itemId) {
    return itemId.startsWith('demo-');
  }
} 
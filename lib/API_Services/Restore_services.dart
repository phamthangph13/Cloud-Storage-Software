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
    print('DEBUG: Response body: ${response.body}');
    
    // Check if response is HTML
    if (response.body.trim().toLowerCase().startsWith('<!doctype html>') || 
        response.body.trim().toLowerCase().startsWith('<html>')) {
      print('DEBUG: Response appears to be HTML, not JSON');
    }
  }
  
  // Get all items in trash
  Future<List<Map<String, dynamic>>> getTrashItems(String token) async {
    try {
      final url = '$baseUrl/api/trash';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      _printDebugInfo(url, response);

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
        try {
          final errorBody = jsonDecode(response.body);
          print('Error fetching trash items: ${errorBody['message']}');
          return [{
            'success': false,
            'message': errorBody['message'] ?? 'Failed to fetch trash items',
            'status_code': response.statusCode
          }];
        } catch (e) {
          return [{
            'success': false,
            'message': 'Failed to fetch trash items: ${response.body}',
            'status_code': response.statusCode
          }];
        }
      }
    } catch (e) {
      print('Trash API error: $e');
      // If we can't parse the error, show a more generic message
      if (e.toString().contains('FormatException')) {
        return [{
          'success': false,
          'message': 'Could not connect to trash service. The server might be unavailable.',
          'status_code': 500
        }];
      }
      return [{
        'success': false,
        'message': 'Error fetching trash items: $e',
        'status_code': 500
      }];
    }
  }
  
  // Restore a file from trash
  Future<Map<String, dynamic>> restoreFile(String fileId, String token) async {
    try {
      final url = '$baseUrl/api/restore/file/$fileId';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      _printDebugInfo(url, response);

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error decoding successful response: $e');
          return {'message': 'File restored successfully'};
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
          'message': 'File not found in trash',
          'status_code': 404
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to restore file',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to restore file: ${response.body}',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      print('Error restoring file: $e');
      if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Could not connect to restore service. The server might be unavailable.',
          'status_code': 500
        };
      }
      return {
        'success': false,
        'message': 'Error restoring file: $e',
        'status_code': 500
      };
    }
  }
  
  // Restore a collection from trash
  Future<Map<String, dynamic>> restoreCollection(String collectionId, String token) async {
    try {
      // According to API documentation, we can use either /api/restore/collection/{collection_id} 
      // or /api/trash/collection/{collection_id}
      // Let's try both endpoints if one fails
      
      final url1 = '$baseUrl/api/restore/collection/$collectionId';
      final url2 = '$baseUrl/api/trash/collection/$collectionId';
      
      print('Trying to restore collection from trash using primary endpoint: $url1');
      
      // Try first endpoint
      var response = await http.post(
        Uri.parse(url1),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      // If first endpoint fails with 404, try the alternative endpoint
      if (response.statusCode == 404) {
        print('First restore endpoint returned 404, trying alternative endpoint: $url2');
        response = await http.post(
          Uri.parse(url2),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      
      _printDebugInfo(response.statusCode == 404 ? url2 : url1, response);

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error decoding successful response: $e');
          return {'message': 'Collection restored successfully'};
        }
      } else if (response.statusCode == 400) {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Bad request: Invalid collection data',
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
          'message': 'Collection not found in trash',
          'status_code': 404
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to restore collection',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to restore collection: ${response.body}',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      print('Error restoring collection: $e');
      if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Could not connect to restore service. The server might be unavailable.',
          'status_code': 500
        };
      }
      return {
        'success': false,
        'message': 'Error restoring collection: $e',
        'status_code': 500
      };
    }
  }
  
  // Permanently delete an item from trash
  Future<Map<String, dynamic>> permanentlyDeleteItem(String itemId, String token) async {
    try {
      final url = '$baseUrl/api/trash/$itemId';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      _printDebugInfo(url, response);

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error decoding successful response: $e');
          return {'message': 'Item deleted permanently'};
        }
      } else if (response.statusCode == 400) {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Bad request: Invalid item data',
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
          'message': 'Item not found in trash',
          'status_code': 404
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to permanently delete item',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to permanently delete item: ${response.body}',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      print('Error permanently deleting item: $e');
      if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Could not connect to trash service. The server might be unavailable.',
          'status_code': 500
        };
      }
      return {
        'success': false,
        'message': 'Error permanently deleting item: $e',
        'status_code': 500
      };
    }
  }
  
  // Add this fallback method for handling demo mode items
  bool isDemoItem(String itemId) {
    return itemId.startsWith('demo-');
  }
} 
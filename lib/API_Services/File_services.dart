import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'Auth_services.dart'; 

class FileService {
  // URL definitions
  static const String baseApiUrl = 'http://10.0.2.2:5000/api';
  static const String uploadUrl = '$baseApiUrl/files/upload';
  static const String filesUrl = '$baseApiUrl/files/files';
  static const String downloadBaseUrl = '$baseApiUrl/files/download';
  static const String deleteBaseUrl = '$baseApiUrl/files';
  
  // Static instance for singleton pattern
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();
   
  // Reference to auth service
  final AuthService _authService = AuthService();
  
  // Demo mode control
  static bool _forceShowDemoMode = false;
  
  // Debug mode for logging
  bool _debugMode = true;
  
  // Add file to collection
  Future<Map<String, dynamic>> addFileToCollection(String fileId, String collectionId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/files/files/$fileId/add-to-collection'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'collection_id': collectionId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to add file to collection');
      }
    } catch (e) {
      throw Exception('Error adding file to collection: $e');
    }
  }
  
  // Remove file from collection
  Future<Map<String, dynamic>> removeFileFromCollection(String fileId, String collectionId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseApiUrl/files/files/$fileId/remove-from-collection/$collectionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to remove file from collection');
      }
    } catch (e) {
      throw Exception('Error removing file from collection: $e');
    }
  }
  
  // Upload a single file with optional tags and storage path
  Future<Map<String, dynamic>> uploadFile(
    File file, 
    {String? token, List<String>? tags, String? storagePath}
  ) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      // Validate token
      if (authToken.isEmpty || !authToken.startsWith('ey')) {
        return {
          'success': false,
          'message': 'Invalid or missing authentication token'
        };
      }
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add authorization header with proper formatting
      final authHeader = 'Bearer $authToken';
      request.headers['Authorization'] = authHeader;
      
      // Get file information
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(file.path).replaceAll('.', '');
      
      // Determine content type based on file extension
      final contentType = _getContentType(fileExtension);
      
      // Add file to request
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: contentType,
      );
      
      request.files.add(multipartFile);
      
      // Add optional parameters
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }
      
      if (storagePath != null) {
        request.fields['storage_path'] = storagePath;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'File upload failed: ${e.toString()}'
      };
    }
  }

  // Upload multiple files
  Future<List<Map<String, dynamic>>> uploadMultipleFiles(
    List<File> files, 
    {String? token, List<String>? tags, String? storagePath}
  ) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      // Validate token
      if (authToken.isEmpty || !authToken.startsWith('ey')) {
        return [{
          'success': false,
          'message': 'Authentication token is required'
        }];
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $authToken';
      
      // Add each file to request
      for (var file in files) {
        final fileName = path.basename(file.path);
        final fileExtension = path.extension(file.path).replaceAll('.', '');
        final contentType = _getContentType(fileExtension);
        
        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();
        
        final multipartFile = http.MultipartFile(
          'file',
          fileStream,
          fileLength,
          filename: fileName,
          contentType: contentType,
        );
        
        request.files.add(multipartFile);
      }
      
      // Add optional parameters
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }
      
      if (storagePath != null) {
        request.fields['storage_path'] = storagePath;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 401) {
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      }
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['files'] != null) {
        return List<Map<String, dynamic>>.from(responseData['files']);
      } else if (responseData['success'] != null && !responseData['success']) {
        return [{
          'success': false,
          'message': responseData['message'] ?? 'Upload failed'
        }];
      }
      
      return [];
    } catch (e) {
      return [{
        'success': false,
        'message': 'Multiple files upload failed: ${e.toString()}'
      }];
    }
  }

  // Get only image files
  Future<List<Map<String, dynamic>>> getImageFiles({String? token, int page = 1, int perPage = 20}) async {
    if (_forceShowDemoMode) {
      return [];
    }
    
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final fullUrl = '$filesUrl?type=image&page=$page&per_page=$perPage';
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _authService.getAuthHeaders(authToken),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['files'] != null) {
          return List<Map<String, dynamic>>.from(responseData['files']);
        }
      } else if (response.statusCode == 401) {
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      } else {
        _forceShowDemoMode = true;
      }
      
      return [];
    } catch (e) {
      _forceShowDemoMode = true;
      return [];
    }
  }
  
  // Get only video files
  Future<List<Map<String, dynamic>>> getVideoFiles({String? token, int page = 1, int perPage = 20}) async {
    if (_forceShowDemoMode) {
      return [];
    }
    
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final fullUrl = '$filesUrl?type=video&page=$page&per_page=$perPage';
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _authService.getAuthHeaders(authToken),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['files'] != null) {
          return List<Map<String, dynamic>>.from(responseData['files']);
        }
      } else if (response.statusCode == 401) {
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      }
      
      return [];
    } catch (e) {
      _forceShowDemoMode = true;
      return [];
    }
  }
  
  // Get document files
  Future<List<Map<String, dynamic>>> getDocumentFiles({String? token, int page = 1, int perPage = 20}) async {
    if (_forceShowDemoMode) {
      return [];
    }
    
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final fullUrl = '$filesUrl?type=document&page=$page&per_page=$perPage';
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _authService.getAuthHeaders(authToken),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['files'] != null) {
          return List<Map<String, dynamic>>.from(responseData['files']);
        }
      } else if (response.statusCode == 401) {
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      }
      
      return [];
    } catch (e) {
      _forceShowDemoMode = true;
      return [];
    }
  }
  
  // Helper method to determine content type
  MediaType _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
      case 'docx':
        return MediaType('application', 'msword');
      case 'xls':
      case 'xlsx':
        return MediaType('application', 'vnd.ms-excel');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // Download a file
  Future<File?> downloadFile(String fileId, {String? token, required String savePath}) async {
    // If it's a demo file, just return null
    if (fileId.startsWith('demo-')) {
      return null;
    }
    
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final downloadUrl = '$downloadBaseUrl/$fileId';
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); 
      
      if (response.statusCode == 200) {
        final File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else if (response.statusCode == 401) {
        print('Authentication failed: 401 Unauthorized');
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete a file
  Future<bool> deleteFile(String fileId, {String? token}) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final deleteUrl = '$deleteBaseUrl/$fileId';
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get image bytes for display
  Future<Uint8List?> getImageBytes(String fileId, {String? token}) async {
    if (fileId.startsWith('demo-')) {
      return null; // For demo images, return null to use URL instead
    }
    
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final downloadUrl = '$downloadBaseUrl/$fileId';
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        print('Authentication failed when fetching image. Check token validity.');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Phương thức trả về URL hiển thị ảnh demo
  String getDemoImageUrl(String fileId) {
    if (fileId.startsWith('demo-')) {
      int randomId = int.parse(fileId.split('-')[1]) % 5;
      return 'https://source.unsplash.com/random/300x300/?nature,${randomId + 1}';
    }
    return '';
  }

  // Phương thức tạo URL hiển thị video demo
  String getDemoVideoUrl(String fileId) {
    if (fileId.startsWith('demo-')) {
      int randomId = int.parse(fileId.split('-')[1]) % 5;
      // Sử dụng các video demo miễn phí
      List<String> demoVideos = [
        'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
        'https://assets.mixkit.co/videos/preview/mixkit-spinning-around-the-earth-29351-large.mp4'
      ];
      return demoVideos[randomId];
    }
    return '';
  }
  
  // Phương thức trợ giúp để xác định file video dựa trên tên file
  bool _isVideoFile(String filename) {
    final lowerCaseFilename = filename.toLowerCase();
    return lowerCaseFilename.endsWith('.mp4') ||
           lowerCaseFilename.endsWith('.avi') ||
           lowerCaseFilename.endsWith('.mov') ||
           lowerCaseFilename.endsWith('.wmv') ||
           lowerCaseFilename.endsWith('.flv') ||
           lowerCaseFilename.endsWith('.mkv') ||
           lowerCaseFilename.endsWith('.webm');
  }

  // Improve the moveFileToTrash method to handle the specific file_path error
  Future<Map<String, dynamic>> moveFileToTrash(String fileId, {String? token}) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      final deleteUrl = '$filesUrl/$fileId';
      
      if (_debugMode) {
        print('Moving file to trash: $deleteUrl');
        print('Token available: ${authToken.isNotEmpty}');
      }
      
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      if (_debugMode) {
        print('Trash API response code: ${response.statusCode}');
        print('Trash API response body: ${response.body}');
      }
      
      // Known server bug: The server returns 500 with 'file_path' error
      // We'll handle this as a special case
      if (response.statusCode == 500 && response.body.contains("'file_path'")) {
        return {
          'success': true, // Treat as success despite server error
          'message': 'File moved to trash with storage warning',
          'client_handled': true,
        };
      }
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to move file to trash',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to move file to trash: Unknown error',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error moving file to trash: ${e.toString()}'
      };
    }
  }

  // Rename a file
  Future<Map<String, dynamic>> renameFile(String fileId, String newFilename, {String? token, bool force = false}) async {
    try {
      // Get token if not provided
      final String authToken = token ?? (await _authService.getToken() ?? '');
      
      if (_debugMode) {
        print('Renaming file: $fileId to $newFilename');
        print('Token available: ${authToken.isNotEmpty}');
      }
      
      final renameUrl = '$filesUrl/$fileId';
      
      final response = await http.put(
        Uri.parse(renameUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'new_filename': newFilename,
          'force': force,
        }),
      );
      
      if (_debugMode) {
        print('Rename API response code: ${response.statusCode}');
        print('Rename API response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        // Handle conflict - file with same name exists
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'A file with this name already exists',
          'suggestion': errorData['suggestion'],
          'requires_confirmation': true,
          'status_code': 409
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        };
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to rename file',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to rename file: Unknown error',
            'status_code': response.statusCode
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error renaming file: ${e.toString()}'
      };
    }
  }
}
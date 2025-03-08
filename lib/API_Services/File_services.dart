import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class FileService {
  static const String baseUrl = 'http://192.168.1.3:5000/api/files/upload';

  // Upload a single file with optional tags and storage path
  Future<Map<String, dynamic>> uploadFile(File file, String token, {List<String>? tags, String? storagePath}) async {
  try {
    print("Token being used: ${token.isEmpty ? 'EMPTY' : (token.substring(0, token.length > 20 ? 20 : token.length) + '...')}");
    
    // Validate token
    if (token.isEmpty || !token.startsWith('ey')) {
      return {
        'success': false,
        'message': 'Invalid or missing authentication token'
      };
    }
    
    // Create multipart request
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    
    // Add authorization header with proper formatting
    final authHeader = 'Bearer $token';
    request.headers['Authorization'] = authHeader;
    print('Authorization header: $authHeader');
    print('Request URL: ${request.url}');
    
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
    String token,
    {List<String>? tags, String? storagePath}
  ) async {
    List<Map<String, dynamic>> results = [];
    
    try {
      // Validate token
      if (token.isEmpty) {
        return [{
          'success': false,
          'message': 'Authentication token is required'
        }];
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
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
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['files'] != null) {
        for (var fileData in responseData['files']) {
          results.add(fileData);
        }
      }
      
      return results;
    } catch (e) {
      return [{
        'success': false,
        'message': 'Multiple files upload failed: ${e.toString()}'
      }];
    }
  }

  // Get all files with metadata
  Future<List<Map<String, dynamic>>> getAllFiles(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:5000/api/files'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final responseData = jsonDecode(response.body);
      
      if (responseData['files'] != null) {
        return List<Map<String, dynamic>>.from(responseData['files']);
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Download a file
  Future<File?> downloadFile(String fileId, String token, String savePath) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:5000/api/files/download/$fileId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ); 
      
      if (response.statusCode == 200) {
        final File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete a file
  Future<bool> deleteFile(String fileId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.3:5000/api/files/$fileId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper method to determine content type based on file extension
  MediaType _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      // Images
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      
      // Videos
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'webm':
        return MediaType('video', 'webm');
      
      // Documents
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case 'pptx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.presentationml.presentation');
      case 'txt':
        return MediaType('text', 'plain');
      case 'csv':
        return MediaType('text', 'csv');
      case 'json':
        return MediaType('application', 'json');
      case 'xml':
        return MediaType('application', 'xml');
      
      // Default
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
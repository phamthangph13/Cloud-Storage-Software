import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class FileService {
  // Các URL API đã được xác định là hoạt động từ logs
  static const String baseApiUrl = 'http://10.0.2.2:5000/api';
  static const String uploadUrl = '$baseApiUrl/files/upload';
  static const String filesUrl = '$baseApiUrl/files/files';
  static const String downloadBaseUrl = '$baseApiUrl/files/download';
  static const String deleteBaseUrl = '$baseApiUrl/files';
  
  // Biến kiểm soát chế độ demo
  static bool _forceShowDemoMode = false;
  
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
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
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
      if (token.isEmpty || !token.startsWith('ey')) {
        return [{
          'success': false,
          'message': 'Authentication token is required'
        }];
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
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
      
      return results;
    } catch (e) {
      return [{
        'success': false,
        'message': 'Multiple files upload failed: ${e.toString()}'
      }];
    }
  }

  // Get only image files - sử dụng API đã xác định hoạt động
  Future<List<Map<String, dynamic>>> getImageFiles(String token, {int page = 1, int perPage = 20}) async {
    // Nếu đã cố thử kết nối quá nhiều lần và thất bại, chuyển sang chế độ demo ngay lập tức
    if (_forceShowDemoMode) {
      print('⚠️ Using demo mode due to previous connection failures');
      return [];
    }
    
    try {
      // Sử dụng URL đã được xác định là hoạt động từ logs
      final fullUrl = '$filesUrl?type=image&page=$page&per_page=$perPage';
      print('Using API endpoint: $fullUrl');
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['files'] != null) {
          print('API response received: ${responseData['files'].length} images');
          return List<Map<String, dynamic>>.from(responseData['files']);
        }
      } else if (response.statusCode == 401) {
        print('Authentication failed: 401 Unauthorized');
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      } else {
        print('API returned error status: ${response.statusCode}');
        _forceShowDemoMode = true;
      }
      
      return [];
    } catch (e) {
      print('Error getting image files: $e');
      _forceShowDemoMode = true;
      return [];
    }
  }
  
  // Get only video files - sử dụng API đã xác định hoạt động
  Future<List<Map<String, dynamic>>> getVideoFiles(String token, {int page = 1, int perPage = 20}) async {
    // Nếu đã cố thử kết nối quá nhiều lần và thất bại, chuyển sang chế độ demo ngay lập tức
    if (_forceShowDemoMode) {
      print('⚠️ Using demo mode due to previous connection failures');
      return [];
    }
    
    try {
      // Sử dụng URL đã được xác định là hoạt động từ logs
      final fullUrl = '$filesUrl?type=video&page=$page&per_page=$perPage';
      print('Using API endpoint for videos: $fullUrl');
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['files'] != null) {
          print('API response received: ${responseData['files'].length} videos');
          return List<Map<String, dynamic>>.from(responseData['files']);
        }
      } else if (response.statusCode == 401) {
        print('Authentication failed: 401 Unauthorized');
        return [{
          'success': false,
          'message': 'Authentication failed. Your session may have expired. Please log in again.',
          'status_code': 401
        }];
      } else {
        print('API returned error status: ${response.statusCode}');
        _forceShowDemoMode = true;
      }
      
      return [];
    } catch (e) {
      print('Error getting video files: $e');
      _forceShowDemoMode = true;
      return [];
    }
  }
  
  // Phương thức trợ giúp để xác định file hình ảnh dựa trên tên file
  bool _isImageFile(String filename) {
    final lowerCaseFilename = filename.toLowerCase();
    return lowerCaseFilename.endsWith('.jpg') ||
           lowerCaseFilename.endsWith('.jpeg') ||
           lowerCaseFilename.endsWith('.png') ||
           lowerCaseFilename.endsWith('.gif') ||
           lowerCaseFilename.endsWith('.bmp') ||
           lowerCaseFilename.endsWith('.webp');
  }

  // Download a file
  Future<File?> downloadFile(String fileId, String token, String savePath) async {
    // Nếu là file demo, chỉ trả về null
    if (fileId.startsWith('demo-')) {
      print('Requested demo file download - this is not a real file');
      return null;
    }
    
    try {
      final downloadUrl = '$downloadBaseUrl/$fileId';
      print('Attempting to download file from: $downloadUrl');
      print('Using token: ${token.isEmpty ? 'EMPTY' : (token.substring(0, 10) + '...')}');
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); 
      
      if (response.statusCode == 200) {
        final File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Download failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  // Delete a file
  Future<bool> deleteFile(String fileId, String token) async {
    try {
      final deleteUrl = '$deleteBaseUrl/$fileId';
      final response = await http.delete(
        Uri.parse(deleteUrl),
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

  // Lấy byte data của hình ảnh để hiển thị
  Future<Uint8List?> getImageBytes(String fileId, String token) async {
    if (fileId.startsWith('demo-')) {
      return null; // Với demo image, trả về null để sử dụng URL
    }
    
    try {
      final downloadUrl = '$downloadBaseUrl/$fileId';
      print('Fetching image bytes from: $downloadUrl');
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('Successfully fetched image bytes for $fileId');
        return response.bodyBytes;
      } else {
        print('Failed to fetch image bytes: ${response.statusCode}');
        if (response.statusCode == 401) {
          print('Authentication failed when fetching image. Check token validity.');
        }
        return null;
      }
    } catch (e) {
      print('Error fetching image bytes: $e');
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
}
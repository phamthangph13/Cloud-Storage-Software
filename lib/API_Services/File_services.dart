import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FileService {
  static const String baseUrl = 'http://192.168.1.3:5000/api/files';

  Future<Map<String, dynamic>> uploadFiles(List<File> files, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';

      for (var file in files) {
        try {
          var stream = http.ByteStream(file.openRead());
          var length = await file.length();

          var multipartFile = http.MultipartFile(
            'file',
            stream,
            length,
            filename: file.path.split('/').last,
          );

          request.files.add(multipartFile);
        } catch (e) {
          throw Exception('Error preparing file ${file.path}: $e');
        }
      }

      try {
        var response = await request.send().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timeout - Is the server running at $baseUrl?');
          },
        );
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);

        if (response.statusCode == 200) {
          return decodedResponse;
        } else {
          throw Exception(decodedResponse['message'] ?? 'Upload failed with status code ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('Connection refused')) {
          throw Exception('Could not connect to server at $baseUrl - Is it running?');
        }
        throw Exception('Network error during upload: $e');
      }
    } catch (e) {
      throw Exception('Error uploading files: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFiles(String token, {String? type, int page = 1, int perPage = 10}) async {
    try {
      var queryParams = {
        if (type != null) 'type': type,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      var uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      var response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        return List<Map<String, dynamic>>.from(decodedResponse['files']);
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Error getting files: $e');
    }
  }

  Future<void> deleteFile(String fileId, String token) async {
    try {
      var response = await http.delete(
        Uri.parse('$baseUrl/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete file');
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}
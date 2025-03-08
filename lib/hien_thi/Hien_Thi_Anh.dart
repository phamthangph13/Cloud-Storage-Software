import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../hien_thi/utils/display_utils.dart';
import '../API_Services/File_services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageViewScreen extends StatefulWidget { 
  final bool showBackButton;
  final String? token;
  
  const ImageViewScreen({
    super.key, 
    this.showBackButton = true,
    this.token,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}
 
class _ImageViewScreenState extends State<ImageViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;
  final FileService _fileService = FileService();
  final _storage = const FlutterSecureStorage();
  
  // Data for images
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _debugMode = true; // Set to true to show more debug info
  bool _allowDemoMode = true; // Cho phép sử dụng dữ liệu demo khi gặp lỗi
  
  // Phương thức trợ giúp để lấy token
  Future<String> _getToken() async {
    // Ưu tiên sử dụng token từ widget
    if (widget.token != null && widget.token!.isNotEmpty) {
      print('Using token from widget: ${widget.token!.substring(0, widget.token!.length > 10 ? 10 : widget.token!.length)}...');
      return widget.token!;
    }
    
    String token = '';
    
    // Thử đọc token từ secure storage trước
    try {
      token = await _storage.read(key: 'auth_token').catchError((e) {
        print('Error loading auth token from secure storage: $e');
        return '';
      }) ?? '';
      
      if (token.isNotEmpty) {
        print('Using token from secure storage: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
        return token;
      }
    } catch (e) {
      print('Error loading auth token from secure storage: $e');
    }
    
    // Nếu không thành công, thử đọc từ SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token') ?? '';
      if (token.isNotEmpty) {
        print('Loading token from SharedPreferences: ${token.substring(0, token.length > 15 ? 15 : token.length)}...');
        return token;
      }
    } catch (e) {
      print('Cannot load token from SharedPreferences: $e');
    }
    
    print('No token found in storage');
    return '';
  }
  
  @override
  void initState() {
    super.initState();
    _loadImages();
  }
  
  // Force demo mode for testing
  void _forceDemoMode() {
    setState(() {
      _images = List.generate(
        8,
        (index) => {
          'id': 'demo-$index',
          'filename': 'Demo Image ${index + 1}.jpg',
          'upload_date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'download_url': '/demo-image-$index.jpg',
        }
      );
      _isLoading = false;
      _hasError = false;
    });
  }
  
  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Get token from widget or try secure storage with fallback
      String token = await _getToken();
      if (_debugMode) {
        print('Token status: ${token.isEmpty ? 'EMPTY' : 'NOT EMPTY'}');
        if (token.isNotEmpty) {
          print('Token preview: ${token.substring(0, token.length > 15 ? 15 : token.length)}...');
        }
      }
      
      if (token.isEmpty) {
        // Hiển thị thông báo rỗng và lý do cụ thể
        if (_debugMode) print('No valid token available, showing empty state');
        setState(() {
          _images = [];
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Không thể truy cập tài khoản của bạn.\n'
              'Điều này có thể do lỗi đăng nhập hoặc bạn chưa đăng nhập.\n'
              'Vui lòng đăng nhập và thử lại, hoặc sử dụng dữ liệu demo để xem trước.';
        });
        return;
      }
      
      // Fetch images from API with timeout
      if (_debugMode) print('Attempting to fetch images from API...');
      
      Future<List<Map<String, dynamic>>> imageFilesFuture = _fileService.getImageFiles(token: token, page: _currentPage);
      final imageFiles = await imageFilesFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (_debugMode) print('API request timed out after 15 seconds');
          throw TimeoutException('Network request timed out');
        },
      );
      
      if (_debugMode) {
        print('API response received: ${imageFiles.length} images');
        if (imageFiles.isNotEmpty) {
          print('First image ID: ${imageFiles[0]['id']}');
        }
      }
      
      // Check for authentication error
      if (imageFiles.isNotEmpty && imageFiles[0]['status_code'] == 401) {
        if (_debugMode) print('Authentication error: ${imageFiles[0]['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = 'Lỗi xác thực. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }
      
      if (imageFiles.isEmpty) {
        if (_debugMode) print('No images found from API, showing empty state');
        
        setState(() {
          _images = [];
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _images = imageFiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading images: ${e.toString()}');
      
      setState(() {
        _hasError = true;
        if (e.toString().contains('timeout')) {
          _errorMessage = 'Kết nối mạng chậm hoặc không có mạng. Vui lòng thử lại sau.';
        } else {
          _errorMessage = 'Không thể tải ảnh: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }
  
  List<Map<String, dynamic>> get _filteredAndSortedImages {
    // First filter by search query
    List<Map<String, dynamic>> result = _searchQuery.isEmpty
        ? List.from(_images)
        : _images.where((image) =>
            image['filename'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Then sort according to selected option
    switch (_currentSortOption) {
      case SortOption.nameAZ:
        result.sort((a, b) => a['filename'].toString().compareTo(b['filename'].toString()));
        break;
      case SortOption.nameZA:
        result.sort((a, b) => b['filename'].toString().compareTo(a['filename'].toString()));
        break;
      case SortOption.dateNewest:
        result.sort((a, b) => DateTime.parse(b['upload_date']).compareTo(DateTime.parse(a['upload_date'])));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => DateTime.parse(a['upload_date']).compareTo(DateTime.parse(b['upload_date'])));
        break;
    }
    
    return result;
  }
  
  String _formatTimeAgo(String dateTimeString) {
    final DateTime uploadDate = DateTime.parse(dateTimeString);
    final Duration difference = DateTime.now().difference(uploadDate);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa mới đây';
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleSearch(bool value) {
    setState(() {
      _isSearching = value;
      if (!value) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }
  
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  void _changeSortOption(SortOption option) {
    setState(() {
      _currentSortOption = option;
    });
  }
  
  Future<void> _refreshImages() async {
    await _loadImages();
  }

  // Chuyển sang chế độ demo khi người dùng yêu cầu
  void _enableDemoMode() {
    setState(() {
      _forceDemoMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredAndSortedImages;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: DisplayUtils.buildSearchSortAppBar(
        context: context,
        title: 'Ảnh',
        isSearching: _isSearching,
        searchController: _searchController,
        currentSortOption: _currentSortOption,
        onSearchToggle: _toggleSearch,
        onSearchChanged: _updateSearchQuery,
        onSortChanged: _changeSortOption,
        showBackButton: widget.showBackButton,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _refreshImages,
                            child: const Text('Thử lại'),
                          ),
                          if (_allowDemoMode) ...[
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: _enableDemoMode,
                              child: const Text('Dùng dữ liệu demo'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshImages,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Chưa có ảnh nào được tải lên'
                                      : 'Không tìm thấy ảnh nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  const SizedBox(height: 8),
                                if (_searchQuery.isNotEmpty)
                                  Text(
                                    'Thử tìm kiếm với từ khóa khác',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return DisplayUtils.animateGridItem(
                                _buildImageItem(index, item),
                                index,
                              );
                            },
                          ),
                  ),
                ),
    );
  }

  Widget _buildImageItem(int index, Map<String, dynamic> item) {
    // Handle the image URL safely
    String imageUrl = '';
    final token = widget.token ?? ''; // Lấy token từ widget
    
    if (item['id'] != null) {
      // Check if it's a demo image
      if (item['id'].toString().startsWith('demo-')) {
        // For demo images, use a placeholder with random nature images
        imageUrl = _fileService.getDemoImageUrl(item['id']);
      } else {
        // Sử dụng URL từ API, hình ảnh thực tế sẽ được tải thông qua Image.network với custom imageProvider
        imageUrl = ''; // Chỉ là placeholder, sẽ sử dụng Future Builder để tải ảnh
      }
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 64,
            color: Colors.blue[100],
            child: item['id'].toString().startsWith('demo-')
              ? Image.network(
                  _fileService.getDemoImageUrl(item['id']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    if (_debugMode) print('Error loading demo image: $error');
                    return const Center(
                      child: Icon(Icons.broken_image, size: 32, color: Colors.blue),
                    );
                  },
                )
              : FutureBuilder<Uint8List?>(
                  future: _fileService.getImageBytes(item['id'], token: token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      if (_debugMode) print('Error or no data: ${snapshot.error}');
                      return const Center(
                        child: Icon(Icons.broken_image, size: 32, color: Colors.blue),
                      );
                    } else {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          if (_debugMode) print('Error displaying image from memory: $error');
                          return const Center(
                            child: Icon(Icons.broken_image, size: 32, color: Colors.blue),
                          );
                        },
                      );
                    }
                  },
                ),
          ),
        ),
        title: Text(
          item['filename'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.access_time, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _formatTimeAgo(item['upload_date']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String choice) async {
            // Handle menu item selection
            final token = await _getToken();
            if (token.isEmpty && !item['id'].toString().startsWith('demo-')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn cần đăng nhập để thực hiện thao tác này')),
              );
              return;
            }
            
            switch (choice) {
              case 'rename':
                // Implement rename functionality
                break;
              case 'collection':
                // Implement save to collection
                break;
              case 'favorite':
                // Implement favorite
                break;
              case 'trash':
                // Implement move to trash
                break;
              case 'download':
                final tempDir = await getTemporaryDirectory();
                final savePath = '${tempDir.path}/${item['filename']}';
                
                // Sử dụng token đã lấy ở trên
                if (token.isEmpty && !item['id'].toString().startsWith('demo-')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn cần đăng nhập để tải xuống')),
                  );
                  return;
                }
                
                try {
                  // Nếu là demo data, giả lập việc tải xuống thành công
                  if (item['id'].toString().startsWith('demo-')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã tải xuống: ${item['filename']}')),
                    );
                  } else {
                    final file = await _fileService.downloadFile(
                      item['id'], 
                      token: token, 
                      savePath: savePath
                    );
                    if (file != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã tải xuống: ${item['filename']}')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không thể tải xuống tệp tin')),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Đổi tên'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'collection',
              child: Row(
                children: [
                  Icon(Icons.collections_bookmark),
                  SizedBox(width: 8),
                  Text('Lưu vào collection'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 8),
                  Text('Yêu thích'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'trash',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Đưa vào thùng rác'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Tải xuống'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Implement viewing the image in full screen
          _viewImageFullScreen(context, item);
        },
      ),
    );
  }
  
  void _viewImageFullScreen(BuildContext context, Map<String, dynamic> item) {
    final token = widget.token ?? ''; // Lấy token từ widget
    
    if (item['id'] == null) {
      // If no valid ID, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể hiển thị hình ảnh này')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              item['filename'] ?? 'Xem ảnh',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng chia sẻ đang được phát triển')),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: item['id'].toString().startsWith('demo-')
                ? Image.network(
                    _fileService.getDemoImageUrl(item['id']),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không thể tải hình ảnh',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      );
                    },
                  )
                : FutureBuilder<Uint8List?>(
                    future: _fileService.getImageBytes(item['id'], token: token),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không thể tải hình ảnh',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      } else {
                        return Image.memory(
                          snapshot.data!,
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.white60,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Không thể hiển thị hình ảnh',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
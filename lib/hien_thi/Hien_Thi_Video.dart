import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/display_utils.dart';
import 'utils/collection_dialog.dart';
import '../API_Services/File_services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoViewScreen extends StatefulWidget {
  final bool showBackButton;
  final String token;

  const VideoViewScreen({
    super.key,
    this.showBackButton = true,
    required this.token,
  });

  @override
  State<VideoViewScreen> createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;
  final FileService _fileService = FileService();
  final _storage = const FlutterSecureStorage();

  // Data for videos
  List<Map<String, dynamic>> _videos = [];
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
    if (widget.token.isNotEmpty) {
      print('Using token from widget: ${widget.token.substring(0, widget.token.length > 10 ? 10 : widget.token.length)}...');
      return widget.token;
    }

    String token = '';

    // Thử đọc token từ secure storage trước
    try {
      token = await _storage.read(key: 'auth_token').catchError((e) {
        print('Lỗi đọc token: $e');
        return '';
      }) ?? '';

      if (token.isNotEmpty) {
        print('Using token from secure storage: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
        return token;
      }
    } catch (e) {
      print('Không thể đọc token từ secure storage: $e');
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
      print('Không thể đọc token từ SharedPreferences: $e');
    }

    print('No token found in storage');
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  // Force demo mode for testing
  void _forceDemoMode() {
    setState(() {
      _videos = List.generate(
          5,
              (index) => {
            'id': 'demo-$index',
            'filename': 'Demo Video ${index + 1}.mp4',
            'upload_date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
            'download_url': '/demo-video-$index.mp4',
            'file_size': Random().nextInt(10000000) + 1000000, // Random file size between 1-10MB
            'duration': Random().nextInt(300) + 30, // Random duration between 30-330 seconds
          }
      );
      _isLoading = false;
      _hasError = false;
    });
  }

  Future<void> _loadVideos() async {
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
          _videos = [];
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Không thể truy cập tài khoản của bạn.\n'
              'Điều này có thể do lỗi đăng nhập hoặc bạn chưa đăng nhập.\n'
              'Vui lòng đăng nhập và thử lại, hoặc sử dụng dữ liệu demo để xem trước.';
        });
        return;
      }

      // Fetch videos from API with timeout
      if (_debugMode) print('Attempting to fetch videos from API...');
      print('Using API endpoint for videos: ${FileService.filesUrl}?type=video&page=$_currentPage&per_page=20');

      Future<List<Map<String, dynamic>>> videoFilesFuture = _fileService.getVideoFiles(token: token, page: _currentPage);
      final videoFiles = await videoFilesFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (_debugMode) print('API request timed out after 15 seconds');
          throw TimeoutException('Network request timed out');
        },
      );

      if (_debugMode) {
        print('API response received: ${videoFiles.length} videos');
        if (videoFiles.isNotEmpty) {
          print('First video ID: ${videoFiles[0]['id']}');
        }
      }

      // Check for authentication error
      if (videoFiles.isNotEmpty && videoFiles[0]['status_code'] == 401) {
        if (_debugMode) print('Authentication error: ${videoFiles[0]['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = 'Lỗi xác thực. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      if (videoFiles.isEmpty) {
        if (_debugMode) print('No videos found from API, showing empty state');

        setState(() {
          _videos = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _videos = videoFiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading videos: ${e.toString()}');

      setState(() {
        _hasError = true;
        if (e.toString().contains('timeout')) {
          _errorMessage = 'Kết nối mạng chậm hoặc không có mạng. Vui lòng thử lại sau.';
        } else {
          _errorMessage = 'Không thể tải video: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedVideos {
    // First filter by search query
    List<Map<String, dynamic>> result = _searchQuery.isEmpty
        ? List.from(_videos)
        : _videos.where((video) =>
        video['filename'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

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

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int remainingSeconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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

  Future<void> _refreshVideos() async {
    await _loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredAndSortedVideos;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: DisplayUtils.buildSearchSortAppBar(
        context: context,
        title: 'Video',
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
                  onPressed: _refreshVideos,
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
        onRefresh: _refreshVideos,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: filteredItems.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Chưa có video nào được tải lên'
                      : 'Không tìm thấy video nào',
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
                _buildVideoItem(index, item),
                index,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(int index, Map<String, dynamic> item) {
    final token = widget.token; // Lấy token từ widget

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
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail hoặc icon cho video
                item['id'].toString().startsWith('demo-')
                    ? Image.network(
                  'https://picsum.photos/seed/${item['id']}/200/200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.movie, size: 40, color: Colors.blue);
                  },
                )
                    : FutureBuilder<Uint8List?>(
                  future: _fileService.getImageBytes(item['id'], token: token), // Get thumbnail
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Icon(Icons.movie, size: 40, color: Colors.blue);
                    }
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.movie, size: 40, color: Colors.blue);
                      },
                    );
                  },
                ),

                // Play icon overlay
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 36,
                    color: Colors.white,
                  ),
                ),

                // Video duration overlay
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['duration'] != null
                          ? _formatDuration(item['duration'])
                          : '00:30', // Default duration
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          item['filename'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(item['upload_date']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.sd_storage, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  item['file_size'] != null
                      ? _formatFileSize(item['file_size'])
                      : item['size'] != null
                      ? _formatFileSize(item['size'])
                      : '8.5 MB', // Default size
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
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
                _showRenameDialog(context, item);
                break;
              case 'collection':
              // Implement save to collection
                _getToken().then((token) {
                  if (token.isNotEmpty) {
                    showCollectionDialog(
                      context,
                      fileId: item['id'],
                      token: token,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unable to authenticate. Please log in again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
                break;
              case 'favorite':
              // Implement favorite
                break;
              case 'trash':
              // Move file to trash
                if (item['id'].toString().startsWith('demo-')) {
                  // Handle demo mode
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã chuyển video vào thùng rác (chế độ demo)')),
                  );

                  // Remove from current list
                  setState(() {
                    _videos.removeWhere((vid) => vid['id'] == item['id']);
                  });
                } else {
                  // Show confirmation dialog
                  final shouldTrash = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Chuyển vào thùng rác'),
                      content: Text('Bạn có chắc chắn muốn chuyển "${item['filename']}" vào thùng rác?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Đồng ý'),
                        ),
                      ],
                    ),
                  ) ?? false;

                  if (!shouldTrash) return;

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang chuyển vào thùng rác...'),
                        ],
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  try {
                    final result = await _fileService.moveFileToTrash(item['id'], token: token);

                    if (result['success'] == false) {
                      if (result['status_code'] == 401) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${result['message'] ?? "Không thể chuyển vào thùng rác"}')),
                        );
                      }
                      return;
                    }

                    // Successfully moved to trash
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chuyển "${item['filename']}" vào thùng rác'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () {
                            // Implement undo functionality if desired
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chức năng hoàn tác đang được phát triển')),
                            );
                          },
                        ),
                      ),
                    );

                    // Remove from current list
                    setState(() {
                      _videos.removeWhere((vid) => vid['id'] == item['id']);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                }
                break;
              case 'download':
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
                      SnackBar(content: Text('Đã tải xuống (chế độ demo)')),
                    );
                    return;
                  }
                  
                  // Tải xuống video vào thư mục tạm
                  _downloadToTempFolder(item, token);
                } catch (e) {
                  print('Lỗi khi tải xuống: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
                break;
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
          // Play video khi người dùng nhấn vào
          _playVideo(context, item);
        },
      ),
    );
  }

  void _playVideo(BuildContext context, Map<String, dynamic> item) {
    final token = widget.token;

    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể phát video này')),
      );
      return;
    }

    String videoUrl = '';

    if (item['id'].toString().startsWith('demo-')) {
      // Sử dụng demo video
      videoUrl = _fileService.getDemoVideoUrl(item['id']);
    } else {
      // Sử dụng video thật từ API
      videoUrl = '${FileService.downloadBaseUrl}/${item['id']}';
    }

    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tìm URL video')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: videoUrl,
          title: item['filename'] ?? 'Video Player',
          token: token,
          isDemo: item['id'].toString().startsWith('demo-'),
        ),
      ),
    );
  }

  // Chuyển sang chế độ demo khi người dùng yêu cầu
  void _enableDemoMode() {
    setState(() {
      _forceDemoMode();
    });
  }

  // Rename dialog implementation
  void _showRenameDialog(BuildContext context, Map<String, dynamic> item) {
    // Get current filename without extension
    final String currentFilename = item['filename'] ?? '';
    final String fileExtension = currentFilename.contains('.')
        ? currentFilename.substring(currentFilename.lastIndexOf('.'))
        : '';
    final String filenameWithoutExt = currentFilename.contains('.')
        ? currentFilename.substring(0, currentFilename.lastIndexOf('.'))
        : currentFilename;
    
    // Create the controller inside the dialog to ensure proper lifecycle management
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: _buildRenameDialogContent(dialogContext, item, filenameWithoutExt, fileExtension),
          ),
        );
      },
    );
  }
  
  Widget _buildRenameDialogContent(BuildContext dialogContext, Map<String, dynamic> item, 
      String filenameWithoutExt, String fileExtension) {
    final TextEditingController renameController = TextEditingController(text: filenameWithoutExt);
    bool isButtonEnabled = true;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Đổi tên file',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Current file info
                      Row(
                        children: [
                          Icon(
                            item['id'].toString().startsWith('demo-') ? Icons.videocam : Icons.videocam,
                            color: Colors.grey.shade600, 
                            size: 16
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tên hiện tại: $filenameWithoutExt$fileExtension',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // New name input
                      TextField(
                        controller: renameController,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            isButtonEnabled = value.trim().isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Tên mới',
                          hintText: 'Nhập tên mới cho file',
                          prefixIcon: const Icon(Icons.text_fields, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Extension info
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Đuôi mở rộng: $fileExtension',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cancel button
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Save button
                          ElevatedButton(
                            onPressed: isButtonEnabled ? () {
                              final newName = renameController.text.trim() + fileExtension;
                              Navigator.of(dialogContext).pop();
                              _processRename(item, newName);
                            } : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Lưu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 300.ms, curve: Curves.easeInOut),
        );
      }
    );
  }
  
  // Separate method to process the rename after dialog is closed
  Future<void> _processRename(Map<String, dynamic> item, String newFilename, {bool force = false}) async {
    // If filename is empty, do nothing
    if (newFilename.isEmpty) {
      return;
    }
    
    // Check if demo mode
    if (item['id'].toString().startsWith('demo-')) {
      // Handle rename in demo mode
      setState(() {
        item['filename'] = newFilename;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi tên thành: $newFilename (chế độ demo)')),
      );
      return;
    }
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Đang đổi tên...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );
    
    try {
      final token = await _getToken();
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập để thực hiện thao tác này')),
        );
        return;
      }
      
      final result = await _fileService.renameFile(item['id'], newFilename, token: token, force: force);
      
      if (result['success'] == false) {
        if (result['status_code'] == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.')),
          );
        } else if (result['status_code'] == 409 && result['requires_confirmation']) {
          // Handle name conflict
          _showNameConflictDialog(item, newFilename, result['suggestion']);
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${result['message'] ?? "Không thể đổi tên file"}')),
          );
        }
        return;
      }
      
      // Update the filename in the local list
      setState(() {
        if (result['file'] != null && result['file']['filename'] != null) {
          item['filename'] = result['file']['filename'];
        } else {
          item['filename'] = newFilename;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi tên thành: ${item['filename']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
  
  // Show dialog for name conflict
  void _showNameConflictDialog(Map<String, dynamic> item, String originalName, String suggestedName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: _buildNameConflictDialogContent(dialogContext, item, originalName, suggestedName),
          ),
        );
      },
    );
  }
  
  Widget _buildNameConflictDialogContent(BuildContext dialogContext, Map<String, dynamic> item,
      String originalName, String suggestedName) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with warning icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Trùng tên file',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current filename with conflict
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline, 
                        color: Colors.orange.shade800, 
                        size: 20
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã tồn tại file có tên "$originalName"',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Suggested name
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tên đề xuất:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.text_fields, color: Colors.blue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestedName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options text
                  Text(
                    'Bạn muốn:',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons in a column for better spacing
                  Column(
                    children: [
                      // Use suggested name button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Dùng tên đề xuất'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _processRename(item, suggestedName);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 200.ms),
                      
                      const SizedBox(height: 8),
                      
                      // Use another name
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Đổi tên khác'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _showRenameDialog(context, item);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 200.ms),
                      
                      const SizedBox(height: 8),
                      
                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text('Hủy'),
                        ),
                      ).animate().fadeIn(delay: 250.ms, duration: 200.ms),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms, curve: Curves.easeInOut),
    );
  }

  // Method to download video to temporary folder
  Future<void> _downloadToTempFolder(Map<String, dynamic> item, String token) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${item['filename']}';
      
      // Hiển thị đang tải
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Đang tải xuống ${item['filename']}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Sử dụng tải xuống tối ưu cho thiết bị di động
      final file = await _fileService.mobileDownloadFile(
        item['id'], 
        token: token, 
        savePath: savePath
      );
      
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tải xuống: ${item['filename']}'),
            action: SnackBarAction(
              label: 'Chia sẻ',
              onPressed: () async {
                // Thử mở tệp tin bằng khả năng của nền tảng
                try {
                  Share.shareXFiles([XFile(file.path)], text: 'Chia sẻ video: ${item['filename']}');
                } catch (e) {
                  print('Lỗi khi chia sẻ tệp tin: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể chia sẻ tệp tin')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải xuống tệp tin')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải xuống: ${e.toString()}')),
      );
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String token;
  final bool isDemo;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.token,
    this.isDemo = false,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.isDemo) {
        // Sử dụng URL trực tiếp cho video demo
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        // Với video thật, cần thêm header token
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          httpHeaders: {
            'Authorization': 'Bearer ${widget.token}',
            'Accept': '*/*',
          },
        );
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Không thể phát video: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _hasError
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Không thể phát video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra kết nối mạng hoặc thử lại sau',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        )
            : !_isInitialized
            ? const CircularProgressIndicator(color: Colors.white)
            : Chewie(controller: _chewieController!),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/display_utils.dart';
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
  final String? token;
  
  const VideoViewScreen({
    super.key, 
    this.showBackButton = true,
    this.token,
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
    if (widget.token != null && widget.token!.isNotEmpty) {
      print('Using token from widget: ${widget.token!.substring(0, widget.token!.length > 10 ? 10 : widget.token!.length)}...');
      return widget.token!;
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
      
      Future<List<Map<String, dynamic>>> videoFilesFuture = _fileService.getVideoFiles(token, page: _currentPage);
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
    final token = widget.token ?? ''; // Lấy token từ widget
    
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
                        future: _fileService.getImageBytes(item['id'], token), // Sử dụng getImageBytes để lấy thumbnail
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
                    final file = await _fileService.downloadFile(item['id'], token, savePath);
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
          // Play video khi người dùng nhấn vào
          _playVideo(context, item);
        },
      ),
    );
  }
  
  void _playVideo(BuildContext context, Map<String, dynamic> item) {
    final token = widget.token ?? '';
    
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
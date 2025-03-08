import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/display_utils.dart';
import 'utils/collection_dialog.dart';
import '../API_Services/File_services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class DocumentViewScreen extends StatefulWidget {
  final bool showBackButton;
  final String token;
  
  const DocumentViewScreen({super.key, this.showBackButton = true, required this.token});

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;
  final FileService _fileService = FileService();
  final _storage = const FlutterSecureStorage();
  
  // Data for documents
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _debugMode = true; // Set to true to show more debug info
  bool _allowDemoMode = true; // Allow demo mode when errors occur
  
  // Helper method to get token
  Future<String> _getToken() async {
    // Prioritize using token from widget
    if (widget.token.isNotEmpty) {
      print('Using token from widget: ${widget.token.substring(0, widget.token.length > 10 ? 10 : widget.token.length)}...');
      return widget.token;
    }
    
    String token = '';
    
    // Try reading token from secure storage first
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
    
    // If unsuccessful, try reading from SharedPreferences
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
    _loadDocuments();
  }
  
  // Force demo mode for testing
  void _forceDemoMode() {
    setState(() {
      _documents = List.generate(
        10,
        (index) => {
          'id': 'demo-$index',
          'filename': 'Document ${index + 1}.${['pdf', 'docx', 'txt', 'xlsx', 'pptx'][index % 5]}',
          'upload_date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'file_size': 1024 * 1024 * (index + 1), // Random file size
          'download_url': '/demo-document-$index.pdf',
        }
      );
      _isLoading = false;
      _hasError = false;
    });
  }
  
  Future<void> _loadDocuments() async {
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
        // Show empty notification and specific reason
        if (_debugMode) print('No valid token available, showing empty state');
        setState(() {
          _documents = [];
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Cannot access your account.\n'
              'This could be due to a login error or you are not logged in.\n'
              'Please log in and try again, or use demo data to preview.';
        });
        return;
      }
      
      // Fetch documents from API with timeout
      if (_debugMode) print('Attempting to fetch documents from API...');
      
      Future<List<Map<String, dynamic>>> documentFilesFuture = _fileService.getDocumentFiles(token: token, page: _currentPage);
      final documentFiles = await documentFilesFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (_debugMode) print('API request timed out after 15 seconds');
          throw TimeoutException('Network request timed out');
        },
      );
      
      if (_debugMode) {
        print('API response received: ${documentFiles.length} documents');
        if (documentFiles.isNotEmpty) {
          print('First document ID: ${documentFiles[0]['id']}');
        }
      }
      
      // Check for authentication error
      if (documentFiles.isNotEmpty && documentFiles[0]['status_code'] == 401) {
        if (_debugMode) print('Authentication error: ${documentFiles[0]['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication error. Please log in again.';
          _isLoading = false;
        });
        return;
      }
      
      if (documentFiles.isEmpty) {
        if (_debugMode) print('No documents found from API, showing empty state');
        
        setState(() {
          _documents = [];
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _documents = documentFiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading documents: ${e.toString()}');
      
      setState(() {
        _hasError = true;
        if (e.toString().contains('timeout')) {
          _errorMessage = 'Slow or no network connection. Please try again later.';
        } else {
          _errorMessage = 'Cannot load documents: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }
  
  List<Map<String, dynamic>> get _filteredAndSortedDocuments {
    // First filter by search query
    List<Map<String, dynamic>> result = _searchQuery.isEmpty
        ? List.from(_documents)
        : _documents.where((doc) =>
            doc['filename'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
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
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
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
  
  Future<void> _refreshDocuments() async {
    await _loadDocuments();
  }

  // Switch to demo mode when user requests
  void _enableDemoMode() {
    setState(() {
      _forceDemoMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredAndSortedDocuments;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: DisplayUtils.buildSearchSortAppBar(
        context: context,
        title: 'Documents',
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
                            onPressed: _refreshDocuments,
                            child: const Text('Try Again'),
                          ),
                          if (_allowDemoMode) ...[
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: _enableDemoMode,
                              child: const Text('Use Demo Data'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshDocuments,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No documents have been uploaded yet'
                                      : 'No documents found',
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
                                    'Try searching with different keywords',
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
                                _buildDocumentItem(index, item),
                                index,
                              );
                            },
                          ),
                  ),
                ),
    );
  }

  Widget _buildDocumentItem(int index, Map<String, dynamic> item) {
    final token = widget.token; // Use token from widget
    final fileName = item['filename'] ?? 'Unknown';
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getDocumentColor(fileExtension),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              _getDocumentIcon(fileExtension),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
                      : '2.5 MB', // Default size
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
                const SnackBar(content: Text('You need to be logged in to perform this action')),
              );
              return;
            }
            
            switch (choice) {
              case 'rename':
                // Implement rename functionality
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
                // Implement move to trash
                break;
              case 'download':
                final tempDir = await getTemporaryDirectory();
                final savePath = '${tempDir.path}/${item['filename']}';
                
                // Use token retrieved above
                if (token.isEmpty && !item['id'].toString().startsWith('demo-')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You need to be logged in to download')),
                  );
                  return;
                }
                
                try {
                  // If demo data, simulate successful download
                  if (item['id'].toString().startsWith('demo-')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloaded: ${item['filename']}')),
                    );
                  } else {
                    final file = await _fileService.downloadFile(
                      item['id'], 
                      token: token,
                      savePath: savePath
                    );
                    if (file != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloaded: ${item['filename']}')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not download file')),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
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
                  Text('Rename'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'collection',
              child: Row(
                children: [
                  Icon(Icons.collections_bookmark),
                  SizedBox(width: 8),
                  Text('Save to collection'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 8),
                  Text('Favorite'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'trash',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Move to trash'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Open document viewer or download
          _previewDocument(context, item);
        },
      ),
    );
  }

  IconData _getDocumentIcon(String fileExtension) {
    switch (fileExtension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  Color _getDocumentColor(String fileExtension) {
    switch (fileExtension) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'txt':
        return Colors.grey.shade600;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green.shade600;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      default:
        return Colors.purple.shade600;
    }
  }
  
  void _previewDocument(BuildContext context, Map<String, dynamic> item) {
    final token = widget.token;
    
    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xem tài liệu này')),
      );
      return;
    }

    // Hiển thị options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            const Text(
              'Tùy chọn tài liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.visibility,
                color: Colors.indigo,
              ),
              title: const Text('Xem tài liệu'),
              subtitle: const Text('Xem trước nội dung'),
              onTap: () {
                // Đóng bottom sheet trước, sau đó xử lý việc xem tài liệu
                Navigator.pop(bottomSheetContext);
                
                // Gọi hàm riêng biệt để xử lý việc xem tài liệu
                _handleDocumentPreview(context, item);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share,
                color: Colors.green,
              ),
              title: const Text('Share Document Link'),
              subtitle: const Text('Copy or share document link'),
              onTap: () {
                Navigator.pop(context);
                // Share document link
                final String docLink = item['id'].toString().startsWith('demo-')
                    ? 'https://example.com/demo-document/${item['id']}'
                    : 'https://yourdomain.com/documents/${item['id']}';
                    
                Share.share('Check out this document: ${item['filename']}\n$docLink');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.purple,
              ),
              title: const Text('Document Details'),
              subtitle: const Text('View information about this document'),
              onTap: () {
                Navigator.pop(context);
                _showDocumentDetails(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tách biệt logic xem tài liệu vào một hàm riêng
  Future<void> _handleDocumentPreview(BuildContext context, Map<String, dynamic> item) async {
    final token = widget.token;
    final fileName = item['filename'] ?? 'document';
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    // Sử dụng BuildContext ổn định từ tham số
    BuildContext? dialogContext;
    
    // Hiển thị loading dialog với cách xử lý context an toàn hơn
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Đang tải tài liệu..."),
              ],
            ),
          ),
        );
      },
    );
    
    // Hàm an toàn để đóng dialog loading
    void closeLoadingDialog() {
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
    }
    
    try {
      // Thêm log hiển thị id và token (che bớt token)
      print('Đang tải tài liệu với ID: ${item['id']}');
      print('Token length: ${token.length}');
      
      final tempDir = await getTemporaryDirectory();
      File? fileToPreview;
      
      if (item['id'].toString().startsWith('demo-')) {
        // Xử lý file demo
        if (['txt', 'md', 'json'].contains(fileExtension)) {
          // Tạo file text đơn giản
          final tempPath = '${tempDir.path}/demo_document.$fileExtension';
          fileToPreview = File(tempPath);
          await fileToPreview.writeAsString(
            'Đây là nội dung demo cho tài liệu ${item['filename']}.\n\n'
            'Tài liệu này được tạo tự động để mục đích minh họa.\n\n'
            'Trong ứng dụng thực tế, nội dung tài liệu sẽ được tải từ máy chủ.'
          );
        } else {
          // Với các định dạng khác, hiển thị placeholder
          closeLoadingDialog();
          if (context.mounted) {
            _showDocumentPreviewPlaceholder(context, fileName, fileExtension);
          }
          return;
        }
      } else {
        // Tải file thực từ server
        final savePath = '${tempDir.path}/${item['filename']}';
        
        if (token.isEmpty) {
          closeLoadingDialog();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn cần đăng nhập để xem tài liệu')),
            );
          }
          return;
        }
        
        final file = await _fileService.downloadFile(
          item['id'],
          token: token,
          savePath: savePath
        );
        
        print('Kết quả tải file: ${file?.path ?? "null"}');
        
        if (file != null && await file.exists()) {
          fileToPreview = file;
        } else {
          closeLoadingDialog();
          if (context.mounted) {
            // Hiển thị thông báo lỗi chi tiết hơn
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể tải tài liệu. Kiểm tra kết nối mạng hoặc quyền truy cập.'),
                duration: Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Thử lại',
                  onPressed: () {
                    // Thử lại việc tải tài liệu
                    _handleDocumentPreview(context, item);
                  },
                ),
              ),
            );
          }
          return;
        }
      }
      
      closeLoadingDialog();
      
      // Chỉ mở file nếu context vẫn hợp lệ
      if (context.mounted && fileToPreview != null) {
        // Mở file theo định dạng
        if (['txt', 'md', 'json', 'html', 'xml', 'csv'].contains(fileExtension)) {
          _openTextViewer(context, fileToPreview, fileName);
        } else {
          _showDocumentPreviewPlaceholder(context, fileName, fileExtension);
        }
      }
    } catch (e) {
      closeLoadingDialog();
      print('Lỗi khi tải tài liệu: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showDocumentDetails(BuildContext context, Map<String, dynamic> item) {
    final fileName = item['filename'] ?? 'Unknown';
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getDocumentColor(fileExtension).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getDocumentIcon(fileExtension),
                      color: _getDocumentColor(fileExtension),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', fileExtension.toUpperCase()),
              _buildDetailRow(
                'Size', 
                item['file_size'] != null 
                  ? _formatFileSize(item['file_size']) 
                  : item['size'] != null
                    ? _formatFileSize(item['size'])
                    : '2.5 MB'
              ),
              _buildDetailRow('Uploaded', _formatTimeAgo(item['upload_date'])),
              _buildDetailRow('ID', item['id']),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTextViewer(BuildContext context, File file, String fileName) {
    try {
      final content = file.readAsStringSync();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(fileName),
              actions: [
                IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép nội dung')),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'Chia sẻ tài liệu: $fileName'),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SelectableText(
                  content,
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể đọc nội dung file: $e')),
      );
    }
  }

  void _showDocumentPreviewPlaceholder(BuildContext context, String fileName, String fileExtension) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(fileName),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDocumentIcon(fileExtension),
                    size: 80,
                    color: _getDocumentColor(fileExtension),
                  ),
                  SizedBox(height: 24),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Định dạng .$fileExtension không thể xem trực tiếp trên ứng dụng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.file_download),
                    label: Text('Tải về để xem'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Gọi lại hàm download từ modal sheet ban đầu
                      // Hoặc hiển thị thông báo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vui lòng chọn tùy chọn "Tải tài liệu" để tải về')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
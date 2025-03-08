import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../API_Services/Collection_services.dart';
import '../../API_Services/File_services.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class CollectionViewScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName;
  final String token;

  const CollectionViewScreen({
    Key? key,
    required this.collectionId,
    required this.collectionName,
    required this.token,
  }) : super(key: key);

  @override
  State<CollectionViewScreen> createState() => _CollectionViewScreenState();
}

class _CollectionViewScreenState extends State<CollectionViewScreen> {
  final CollectionService _collectionService = CollectionService();
  final FileService _fileService = FileService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _files = [];
  bool _isGridView = true;
  
  @override
  void initState() {
    super.initState();
    _loadCollectionFiles();
  }

  Future<void> _loadCollectionFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Get collection files
      final response = await _collectionService.getCollectionFiles(
        widget.collectionId, 
        widget.token
      );
      
      setState(() {
        _files = response['files'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFileFromCollection(String fileId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _fileService.removeFileFromCollection(
        fileId, 
        widget.collectionId, 
        widget.token
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa khỏi bộ sưu tập'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
      
      // Reload files
      _loadCollectionFiles();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }
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

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'document':
        return Icons.article;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'document':
        return Colors.green;
      case 'pdf':
        return Colors.orange;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.blue.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.collectionName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade500, Colors.blue.shade800],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemCount: 20,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Icon(
                              Icons.folder,
                              color: Colors.white,
                              size: 40,
                            );
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.collections_bookmark,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadCollectionFiles,
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection info
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade700],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_files.length} files',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Files list or grid
          _isLoading
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _errorMessage != null
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Không thể tải danh sách tệp tin',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(_errorMessage ?? 'Đã xảy ra lỗi'),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCollectionFiles,
                              child: Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _files.isEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Bộ sưu tập trống',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Thêm tệp tin vào bộ sưu tập này từ các màn hình khác',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(),
                        )
                      : _isGridView
                          ? SliverPadding(
                              padding: EdgeInsets.all(16),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final file = _files[index];
                                    final fileType = file['file_type'] ?? 'unknown';
                                    final fileName = file['filename'] ?? 'Unknown file';
                                    final fileId = file['id'] ?? '';
                                    final uploadDate = file['upload_date'] ?? DateTime.now().toIso8601String();
                                    final fileSize = file['file_size'] ?? 0;
                                    
                                    return _buildGridFileItem(
                                      fileId, 
                                      fileName, 
                                      fileType, 
                                      uploadDate, 
                                      fileSize,
                                      index,
                                    );
                                  },
                                  childCount: _files.length,
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final file = _files[index];
                                  final fileType = file['file_type'] ?? 'unknown';
                                  final fileName = file['filename'] ?? 'Unknown file';
                                  final fileId = file['id'] ?? '';
                                  final uploadDate = file['upload_date'] ?? DateTime.now().toIso8601String();
                                  final fileSize = file['file_size'] ?? 0;
                                  
                                  return _buildListFileItem(
                                    fileId, 
                                    fileName, 
                                    fileType, 
                                    uploadDate, 
                                    fileSize,
                                    index,
                                  );
                                },
                                childCount: _files.length,
                              ),
                            ),
        ],
      ),
      
    );
  }

  Widget _buildGridFileItem(
    String fileId, 
    String fileName, 
    String fileType, 
    String uploadDate, 
    int fileSize,
    int index,
  ) {
    final bool isImage = fileType.toLowerCase() == 'image';
    final bool isVideo = fileType.toLowerCase() == 'video';
    final isDemoFile = fileId.startsWith('demo-');
    
    return InkWell(
      onTap: () {
        // Handle file tap - open the file
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File preview
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getFileColor(fileType).withOpacity(0.1),
                  ),
                  width: double.infinity,
                  child: isImage || isVideo
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image preview
                            if (isImage)
                              isDemoFile
                                  ? Image.network(
                                      _fileService.getDemoImageUrl(fileId),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 48,
                                            color: _getFileColor(fileType),
                                          ),
                                        );
                                      },
                                    )
                                  : FutureBuilder<Uint8List?>(
                                      future: _fileService.getImageBytes(fileId, token: widget.token),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          );
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                          return Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 48,
                                              color: _getFileColor(fileType),
                                            ),
                                          );
                                        } else {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 48,
                                                  color: _getFileColor(fileType),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    
                            // Video icon overlay
                            if (isVideo)
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Center(
                          child: Icon(
                            _getFileIcon(fileType),
                            size: 48,
                            color: _getFileColor(fileType),
                          ),
                        ),
                ),
              ),
            ),
            
            // File info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatTimeAgo(uploadDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatFileSize(fileSize),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _showFileOptions(fileId, fileName);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1, end: 0);
  }

  Widget _buildListFileItem(
    String fileId, 
    String fileName, 
    String fileType, 
    String uploadDate, 
    int fileSize,
    int index,
  ) {
    final bool isImage = fileType.toLowerCase() == 'image';
    final bool isVideo = fileType.toLowerCase() == 'video';
    final isDemoFile = fileId.startsWith('demo-');
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Handle file tap - open the file
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // File preview/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getFileColor(fileType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isDemoFile
                            ? Image.network(
                                _fileService.getDemoImageUrl(fileId),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 28,
                                      color: _getFileColor(fileType),
                                    ),
                                  );
                                },
                              )
                            : FutureBuilder<Uint8List?>(
                                future: _fileService.getImageBytes(fileId, token: widget.token),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                    return Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 28,
                                        color: _getFileColor(fileType),
                                      ),
                                    );
                                  } else {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 28,
                                            color: _getFileColor(fileType),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                      )
                    : isVideo
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              Icon(
                                Icons.video_file,
                                size: 28,
                                color: _getFileColor(fileType),
                              ),
                              Icon(
                                Icons.play_circle_fill,
                                size: 24,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              _getFileIcon(fileType),
                              size: 28,
                              color: _getFileColor(fileType),
                            ),
                          ),
              ),
              
              SizedBox(width: 16),
              
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatFileSize(fileSize),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(uploadDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  _showFileOptions(fileId, fileName);
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05, end: 0);
  }

  void _showFileOptions(String fileId, String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tùy chọn tệp tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      fileName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Options
            ListTile(
              leading: Icon(Icons.visibility, color: Colors.blue),
              title: Text('Xem tệp tin'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement view file
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Xóa khỏi bộ sưu tập'),
              onTap: () {
                Navigator.pop(context);
                _removeFileFromCollection(fileId);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Tải xuống'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download
              },
            ),
            
            SizedBox(height: 16),
            
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} 
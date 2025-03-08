import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../API_Services/Collection_services.dart';
import 'collection_view.dart';

class StorageScreen extends StatefulWidget {
  final bool showBackButton;
  final String token;
  
  const StorageScreen({super.key, this.showBackButton = true, required this.token});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final CollectionService _collectionService = CollectionService();
  List<dynamic> _collections = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final collections = await _collectionService.getAllCollections(widget.token);
      
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createCollection(BuildContext context) async {
    final nameController = TextEditingController();
    bool isCreating = false;
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => StatefulBuilder(
        builder: (context, setState) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: 1.0,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 320,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.create_new_folder_outlined,
                          size: 50,
                          color: Colors.white,
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(delay: 200.ms),
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Text(
                        'Tạo bộ sưu tập mới',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ).animate()
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, delay: 100.ms),
                    ),
                    
                    // Description
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Text(
                        'Nhập tên cho bộ sưu tập của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, delay: 200.ms),
                    ),
                    
                    // Input field
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Tên bộ sưu tập',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.folder, color: Colors.blue.shade400),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                      ).animate()
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, delay: 300.ms),
                    ),
                    
                    // Buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel button
                          TextButton(
                            onPressed: isCreating 
                                ? null 
                                : () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .moveX(begin: -10, end: 0, delay: 400.ms),
                          
                          // Submit button with loading indicator
                          ElevatedButton(
                            onPressed: isCreating 
                                ? null 
                                : () async {
                                    if (nameController.text.trim().isNotEmpty) {
                                      setState(() {
                                        isCreating = true;
                                      });
                                      
                                      try {
                                        await _collectionService.createCollection(
                                          nameController.text.trim(), 
                                          widget.token
                                        );
                                        
                                        // Close dialog with animation
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          
                                          // Show success indicator
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle, color: Colors.white),
                                                  const SizedBox(width: 10),
                                                  Text('Đã tạo "${nameController.text.trim()}"'),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                          
                                          // Refresh collections list
                                          _loadCollections();
                                        }
                                      } catch (e) {
                                        setState(() {
                                          isCreating = false;
                                        });
                                        
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Lỗi: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isCreating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Tạo',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .moveX(begin: 10, end: 0, delay: 400.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.5),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBackButton ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: const Text(
          'Bộ sưu tập của tôi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _createCollection(context),
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Không thể tải bộ sưu tập',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage ?? 'Đã xảy ra lỗi'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCollections,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _collections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.collections, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có bộ sưu tập nào',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _createCollection(context),
                            child: const Text('Tạo bộ sưu tập mới'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCollections,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _collections.length + 1, // +1 for header
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Header row
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Bộ sưu tập của tôi',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ).animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideX(begin: -0.2, end: 0),
                                  IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.red),
                                    onPressed: () {
                                      // Navigate to favorites screen
                                    },
                                  ).animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideX(begin: 0.2, end: 0),
                                ],
                              ),
                            );
                          }
                          
                          // Collection items
                          final collection = _collections[index - 1];
                          final collectionName = collection['name'] ?? 'Không có tên';
                          final collectionId = collection['id'] ?? '';
                          final createdAt = collection['created_at'] ?? '';
                          
                          // Format date
                          String formattedDate = '';
                          try {
                            if (createdAt.isNotEmpty) {
                              final date = DateTime.parse(createdAt);
                              formattedDate = '${date.day}/${date.month}/${date.year}';
                            }
                          } catch (e) {
                            formattedDate = 'Không rõ';
                          }
                          
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent
                              ),
                              child: ExpansionTile(
                                onExpansionChanged: (expanded) {
                                  if (!expanded) {
                                    // When tile is tapped but not expanding, navigate to collection
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CollectionViewScreen(
                                          collectionId: collectionId,
                                          collectionName: collectionName,
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, 
                                        vertical: 6
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade400, 
                                            Colors.blue.shade700
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        collectionName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (formattedDate.isNotEmpty)
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          color: Colors.grey
                                        ),
                                      ),
                                  ],
                                ),
                                leading: Icon(
                                  Icons.folder, 
                                  color: Colors.blue.shade400, 
                                  size: 28
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CollectionViewScreen(
                                                  collectionId: collectionId,
                                                  collectionName: collectionName,
                                                  token: widget.token,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.visibility),
                                          label: Text('Xem tất cả tệp tin'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Đổi tên'),
                                        onPressed: () {
                                          // TODO: Implement rename functionality
                                        },
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          // TODO: Implement delete functionality
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.2, end: 0);
                        },
                      ),
                    ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  final String type;
  final String date;
  final String thumbnail;
  final bool isFavorite;

  const _MediaItem({
    required this.type,
    required this.date,
    required this.thumbnail,
    required this.isFavorite,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Sửa tên'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement rename functionality
              },
            ),
            ListTile(
              leading: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              title: Text(isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add/remove favorites
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Tải xuống'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xoá'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              if (isFavorite)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                    .scale(
                      duration: 800.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                    )
                    .then()
                    .scale(
                      duration: 800.ms,
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1, 1),
                    ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    type == 'video' ? Icons.play_circle : Icons.image,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

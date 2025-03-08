import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/display_utils.dart';
import '../API_Services/Restore_services.dart';
import 'package:intl/intl.dart';

class TrashScreen extends StatefulWidget {
  final bool showBackButton;
  final String token;

  const TrashScreen({super.key, this.showBackButton = true, required this.token});

  @override 
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _selectedItems = [];
  bool _isSelectionMode = false;
  
  // Access token from widget
  String get _authToken => widget.token;
  
  // Search and sort functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;
  
  // Trash data
  final RestoreService _restoreService = RestoreService();
  List<Map<String, dynamic>> _trashItems = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Demo mode for testing when API fails
  bool _allowDemoMode = true;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTrashItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  // Force demo mode
  void _forceDemoMode() {
    final demoItems = [
      {
        'id': 'demo-trash-file-1',
        'name': 'Vacation Photo.jpg',
        'type': 'file',
        'deleted_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'size': 1024 * 1024 * 3, // 3 MB
      },
      {
        'id': 'demo-trash-file-2',
        'name': 'Project Presentation.pdf',
        'type': 'file',
        'deleted_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'size': 1024 * 1024 * 5, // 5 MB
      },
      {
        'id': 'demo-trash-file-3',
        'name': 'Family Reunion.mp4',
        'type': 'file',
        'deleted_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'size': 1024 * 1024 * 25, // 25 MB
      },
      {
        'id': 'demo-trash-collection-1',
        'name': 'Travel Plans',
        'type': 'collection',
        'deleted_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'demo-trash-collection-2',
        'name': 'Work Documents',
        'type': 'collection',
        'deleted_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];

    setState(() {
      _demoMode = true;
      _trashItems = demoItems;
      _isLoading = false;
      _hasError = false;
    });
  }
  
  Future<void> _loadTrashItems() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      if (_demoMode) {
        _forceDemoMode();
        return;
      }
      
      try {
        final items = await _restoreService.getTrashItems(_authToken);
        
        if (items.isNotEmpty && items[0]['status_code'] == 401) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Lỗi xác thực. Vui lòng đăng nhập lại.';
            _isLoading = false;
          });
          return;
        }
        
        setState(() {
          _trashItems = items;
          _isLoading = false;
        });
      } catch (e) {
        print('API error, falling back to demo mode: $e');
        _forceDemoMode();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Lỗi không xác định: ${e.toString()}';
        _isLoading = false;
      });
    }
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
  
  void _toggleSelectionMode(bool value) {
    setState(() {
      _isSelectionMode = value;
      if (!value) {
        _selectedItems.clear();
      }
    });
  }
  
  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
      
      if (_selectedItems.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }
  
  List<Map<String, dynamic>> get _filteredAndSortedItems {
    // First filter by search query
    List<Map<String, dynamic>> result = _searchQuery.isEmpty
        ? List.from(_trashItems)
        : _trashItems.where((item) =>
            item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Then sort according to selected option
    switch (_currentSortOption) {
      case SortOption.nameAZ:
        result.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case SortOption.nameZA:
        result.sort((a, b) => b['name'].toString().compareTo(a['name'].toString()));
        break;
      case SortOption.dateNewest:
        result.sort((a, b) => DateTime.parse(b['deleted_at']).compareTo(DateTime.parse(a['deleted_at'])));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => DateTime.parse(a['deleted_at']).compareTo(DateTime.parse(b['deleted_at'])));
        break;
    }
    
    return result;
  }
  
  String _formatTimeAgo(String dateTimeString) {
    final DateTime deletedDate = DateTime.parse(dateTimeString);
    final Duration difference = DateTime.now().difference(deletedDate);
    
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
  
  Future<void> _restoreItems() async {
    if (_selectedItems.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<String> failedItems = [];
      
      // Process demo mode differently
      if (_demoMode) {
        // In demo mode, just remove items from list
        setState(() {
          _trashItems.removeWhere((item) => _selectedItems.contains(item['id']));
          _selectedItems.clear();
          _isSelectionMode = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khôi phục các mục đã chọn (chế độ demo)')),
        );
        return;
      }
      
      // Process each selected item
      for (String itemId in _selectedItems) {
        final item = _trashItems.firstWhere((element) => element['id'] == itemId);
        
        try {
          if (item['type'] == 'file') {
            await _restoreService.restoreFile(itemId, _authToken);
          } else if (item['type'] == 'collection') {
            await _restoreService.restoreCollection(itemId, _authToken);
          }
        } catch (e) {
          failedItems.add(item['name']);
        }
      }
      
      // Reload items after restore
      await _loadTrashItems();
      
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });
      
      if (failedItems.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể khôi phục: ${failedItems.join(", ")}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khôi phục các mục đã chọn')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _permanentlyDeleteItems() async {
    if (_selectedItems.isEmpty) return;
    
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa vĩnh viễn'),
        content: const Text(
          'Các mục đã chọn sẽ bị xóa vĩnh viễn và không thể khôi phục. Bạn có chắc chắn muốn tiếp tục?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa vĩnh viễn'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
    
    if (!shouldDelete) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<String> failedItems = [];
      
      // Process demo mode differently
      if (_demoMode) {
        // In demo mode, just remove items from list
        setState(() {
          _trashItems.removeWhere((item) => _selectedItems.contains(item['id']));
          _selectedItems.clear();
          _isSelectionMode = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa vĩnh viễn các mục đã chọn (chế độ demo)')),
        );
        return;
      }
      
      // Process each selected item
      for (String itemId in _selectedItems) {
        final item = _trashItems.firstWhere((element) => element['id'] == itemId);
        
        try {
          await _restoreService.permanentlyDeleteItem(itemId, _authToken);
        } catch (e) {
          failedItems.add(item['name']);
        }
      }
      
      // Reload items after delete
      await _loadTrashItems();
      
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });
      
      if (failedItems.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa: ${failedItems.join(", ")}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa vĩnh viễn các mục đã chọn')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _refreshTrash() async {
    await _loadTrashItems();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredAndSortedItems;
    
    // Create a custom app bar when in selection mode
    final appBar = _isSelectionMode
        ? AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => _toggleSelectionMode(false),
            ),
            title: Text(
              '${_selectedItems.length} đã chọn',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.blue),
                onPressed: _restoreItems,
                tooltip: 'Khôi phục',
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: _permanentlyDeleteItems,
                tooltip: 'Xóa vĩnh viễn',
              ),
            ],
          )
        : DisplayUtils.buildSearchSortAppBar(
            context: context,
            title: 'Thùng rác',
            isSearching: _isSearching,
            searchController: _searchController,
            currentSortOption: _currentSortOption,
            onSearchToggle: _toggleSearch,
            onSearchChanged: _updateSearchQuery,
            onSortChanged: _changeSortOption,
            showBackButton: widget.showBackButton,
          );
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: appBar,
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
                            onPressed: _refreshTrash,
                            child: const Text('Thử lại'),
                          ),
                          if (_allowDemoMode) ...[
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: _forceDemoMode,
                              child: const Text('Dùng dữ liệu demo'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshTrash,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Selection mode actions - only show when in selection mode
                        if (_isSelectionMode)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: _restoreItems,
                                  icon: const Icon(Icons.restore),
                                  label: const Text('Khôi phục'),
                                ),
                                TextButton.icon(
                                  onPressed: _permanentlyDeleteItems,
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text('Xóa vĩnh viễn'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        
                        // Item list
                        Expanded(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 80,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isEmpty
                                            ? 'Thùng rác trống'
                                            : 'Không tìm thấy kết quả',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
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
                                    final isSelected = _selectedItems.contains(item['id']);
                                    
                                    return _buildTrashItem(index, item, isSelected);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTrashItem(int index, Map<String, dynamic> item, bool isSelected) {
    final itemType = item['type'] ?? 'unknown';
    final itemName = item['name'] ?? 'Unknown Item';
    final itemId = item['id'] ?? '';
    final deletedAt = item['deleted_at'] ?? DateTime.now().toIso8601String();
    final itemSize = item['size'] != null ? _formatFileSize(item['size']) : null;
    
    return DisplayUtils.animateGridItem(
      Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                itemType == 'file' ? Icons.insert_drive_file : Icons.folder,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
                size: 28,
              ),
            ),
          ),
          title: Text(
            itemName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? Colors.blue.shade700 : Colors.black87,
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
                    'Đã xóa ${_formatTimeAgo(deletedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (itemSize != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.data_usage, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      itemSize,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleItemSelection(itemId),
                  activeColor: Colors.blue,
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String choice) {
                    switch (choice) {
                      case 'restore':
                        // Single item restore
                        setState(() {
                          _selectedItems.clear();
                          _selectedItems.add(itemId);
                        });
                        _restoreItems();
                        break;
                      case 'delete':
                        // Single item delete
                        setState(() {
                          _selectedItems.clear();
                          _selectedItems.add(itemId);
                        });
                        _permanentlyDeleteItems();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.restore),
                          SizedBox(width: 8),
                          Text('Khôi phục'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
          onTap: () {
            if (_isSelectionMode) {
              _toggleItemSelection(itemId);
            } else {
              // Enable selection mode with first item
              setState(() {
                _isSelectionMode = true;
                _selectedItems.add(itemId);
              });
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedItems.add(itemId);
              });
            }
          },
        ),
      ),
      index,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TrashScreen extends StatefulWidget {
  final bool showBackButton;

  const TrashScreen({super.key, this.showBackButton = true});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<int> _selectedItems = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(int index) {
    setState(() {
      if (_selectedItems.contains(index)) {
        _selectedItems.remove(index);
      } else {
        _selectedItems.add(index);
      }

      if (_selectedItems.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          _isSelectionMode
              ? '${_selectedItems.length} đã chọn'
              : 'Thùng rác',
          style: TextStyle(
            color: _isSelectionMode ? Colors.blue.shade700 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ).animate(target: _isSelectionMode ? 1 : 0).fade().scale(),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: _toggleSelectionMode,
            ).animate().fadeIn(duration: 200.ms),
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Xóa tất cả'),
                    content: const Text(
                      'Bạn có chắc muốn xóa vĩnh viễn tất cả các mục trong thùng rác?',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Xóa tất cả',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          // TODO: Implement permanent delete all
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa tất cả mục trong thùng rác'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.black87),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            'Các mục sẽ bị xóa vĩnh viễn sau 30 ngày',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
          child: _buildTrashGrid(),
        ),
      ],
    );
  }

  Widget _buildTrashGrid() {
    final itemCount = 8; // Demo with 8 items
    
    if (itemCount == 0) {
      return Center(
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
              'Thùng rác trống',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return _buildTrashItem(index)
              .animate()
              .fadeIn(duration: 300.ms, delay: (50 * index).ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: (50 * index).ms);
        },
      ),
    );
  } 

  Widget _buildTrashItem(int index) {
    final bool isSelected = _selectedItems.contains(index);
    final daysLeft = 30 - (index % 25); // Random days left for demo
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleItemSelection(index);
        } else {
          // Preview item
          _showItemPreview(index);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleSelectionMode();
          _toggleItemSelection(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.blue.shade400, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item thumbnail
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: _getItemColor(index).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      _getItemIcon(index),
                      size: 50,
                      color: _getItemColor(index),
                    ),
                  ),
                ),
                // Item info
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getItemName(index),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: daysLeft < 7 ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$daysLeft ngày còn lại',
                            style: TextStyle(
                              fontSize: 13,
                              color: daysLeft < 7 ? Colors.red : Colors.grey.shade600,
                              fontWeight: daysLeft < 7 ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Selection indicator
            if (_isSelectionMode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ).animate().scale(duration: 200.ms),
            // Restore button
            if (!_isSelectionMode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showRestoreDialog(index),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.restore_rounded,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showItemPreview(int index) {
    // TODO: Implement item preview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem trước ${_getItemName(index)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRestoreDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Khôi phục'),
        content: Text(
          'Bạn có muốn khôi phục "${_getItemName(index)}" về vị trí ban đầu?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Khôi phục',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              // TODO: Implement restore logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã khôi phục ${_getItemName(index)}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.delete_forever,
            label: 'Xóa vĩnh viễn',
            color: Colors.red,
            onTap: () {
              if (_selectedItems.isEmpty) return;
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Xóa vĩnh viễn'),
                  content: Text(
                    'Bạn có chắc muốn xóa vĩnh viễn ${_selectedItems.length} mục đã chọn?',
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Xóa vĩnh viễn',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        // TODO: Implement permanent delete
                        Navigator.pop(context);
                        setState(() {
                          _isSelectionMode = false;
                          _selectedItems.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xóa vĩnh viễn các mục đã chọn'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.restore_rounded,
            label: 'Khôi phục',
            color: Colors.blue,
            onTap: () {
              if (_selectedItems.isEmpty) return;
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Khôi phục'),
                  content: Text(
                    'Bạn có muốn khôi phục ${_selectedItems.length} mục đã chọn về vị trí ban đầu?',
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Khôi phục',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        // TODO: Implement restore logic
                        Navigator.pop(context);
                        setState(() {
                          _isSelectionMode = false;
                          _selectedItems.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã khôi phục các mục đã chọn'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getItemColor(int index) {
    final List<Color> colors = [
      Colors.blue,      // Folder
      Colors.green,     // Document
      Colors.orange,    // Image
      Colors.purple,    // Video
      Colors.teal,      // Audio
      Colors.pink,      // Archive
      Colors.amber,     // Code
      Colors.indigo,    // Other
    ];
    return colors[index % colors.length];
  }

  IconData _getItemIcon(int index) {
    final List<IconData> icons = [
      Icons.folder_rounded,           // Folder
      Icons.description_rounded,      // Document
      Icons.image_rounded,            // Image
      Icons.video_file_rounded,       // Video
      Icons.audio_file_rounded,       // Audio
      Icons.archive_rounded,          // Archive
      Icons.code_rounded,             // Code
      Icons.insert_drive_file_rounded, // Other
    ];
    return icons[index % icons.length];
  }

  String _getItemName(int index) {
    final List<String> prefixes = [
      'Thư mục',
      'Tài liệu', 
      'Ảnh', 
      'Video',
      'Âm thanh',
      'Nén',
      'Mã nguồn',
      'Tệp',
    ];
    return '${prefixes[index % prefixes.length]} ${(index + 1)}';
  }
}
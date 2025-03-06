import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../hien_thi/utils/display_utils.dart';

class DocumentViewScreen extends StatefulWidget {
  final bool showBackButton;
  
  const DocumentViewScreen({super.key, this.showBackButton = true});

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;
  
  // Demo data for documents
  final List<Map<String, dynamic>> _documents = List.generate(
    10,
    (index) => {
      'name': 'Document ${index + 1}',
      'date': DateTime.now().subtract(Duration(hours: index * 1)),
      'timeAgo': '${index + 1} giờ trước',
      'type': ['PDF', 'DOCX', 'TXT', 'XLS', 'PPT'][index % 5],
    },
  );
  
  List<Map<String, dynamic>> get _filteredAndSortedDocuments {
    // First filter by search query
    List<Map<String, dynamic>> result = _searchQuery.isEmpty
        ? List.from(_documents)
        : _documents.where((doc) =>
            doc['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Then sort according to selected option
    switch (_currentSortOption) {
      case SortOption.nameAZ:
        result.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case SortOption.nameZA:
        result.sort((a, b) => b['name'].toString().compareTo(a['name'].toString()));
        break;
      case SortOption.dateNewest:
        result.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => a['date'].compareTo(b['date']));
        break;
    }
    
    return result;
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

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredAndSortedDocuments;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: DisplayUtils.buildSearchSortAppBar(
        context: context,
        title: 'Tài liệu',
        isSearching: _isSearching,
        searchController: _searchController,
        currentSortOption: _currentSortOption,
        onSearchToggle: _toggleSearch,
        onSearchChanged: _updateSearchQuery,
        onSortChanged: _changeSortOption,
        showBackButton: widget.showBackButton,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: filteredItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy tài liệu nào',
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
                  return DisplayUtils.animateGridItem(
                    _buildDocumentItem(index, item),
                    index,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDocumentItem(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              _getDocumentIcon(item['type']),
              color: Colors.blue,
              size: 24,
            ),
          ),
        ),
        title: Text(
          item['name'],
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
              item['timeAgo'],
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['type'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String choice) {
            // Handle menu item selection
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
                // Implement download
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
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
        return Icons.description;
      case 'TXT':
        return Icons.text_snippet;
      case 'XLS':
        return Icons.table_chart;
      case 'PPT':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}
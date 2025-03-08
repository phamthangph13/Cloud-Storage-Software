import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/display_utils.dart';

class TrashScreen extends StatefulWidget {
  final bool showBackButton;
  final String token;

  const TrashScreen({super.key, this.showBackButton = true, required this.token});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<int> _selectedItems = [];
  bool _isSelectionMode = false;
  
  // Access token from widget
  String get _authToken => widget.token;
  
  // Search and sort functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateNewest;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: DisplayUtils.buildSearchSortAppBar(
        context: context,
        title: 'Thùng rác',
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
        child: Column(
          children: [
            // Empty state
            if (_selectedItems.isEmpty)
              Expanded(
                child: Center(
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
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Selection mode actions
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.all(16),
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
                      onPressed: () {
                        // Implement restore functionality
                        setState(() {
                          _selectedItems.clear();
                          _isSelectionMode = false;
                        });
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Khôi phục'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Implement delete functionality
                        setState(() {
                          _selectedItems.clear();
                          _isSelectionMode = false;
                        });
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Xóa vĩnh viễn'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
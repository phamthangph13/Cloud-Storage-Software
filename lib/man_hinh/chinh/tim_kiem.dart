import 'package:flutter/material.dart';
import 'dart:math' as math;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _helpCategories = ['All', 'Getting Started', 'FAQ', 'Tutorials', 'Tips & Tricks'];
  String _selectedCategory = 'All';
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Sample help topics for demonstration
  final List<HelpItem> _helpItems = [
    HelpItem(
      title: 'How to upload files',
      category: 'Getting Started',
      icon: Icons.cloud_upload,
      content: 'To upload files, tap the + button at the bottom of your screen and select the files you want to upload.',
    ),
    HelpItem(
      title: 'Managing shared files',
      category: 'Tutorials',
      icon: Icons.folder_shared,
      content: 'Access your shared files by navigating to the "Shared" tab. From there, you can manage permissions and view who has access.',
    ),
    HelpItem(
      title: 'What is file versioning?',
      category: 'FAQ',
      icon: Icons.history,
      content: 'File versioning allows you to restore previous versions of your files. Our cloud storage keeps track of changes for up to 30 days.',
    ),
    HelpItem(
      title: 'Storage limits',
      category: 'FAQ',
      icon: Icons.storage,
      content: 'Free accounts have 15GB of storage. Premium plans offer 100GB, 1TB, or unlimited storage options depending on your subscription.',
    ),
    HelpItem(
      title: 'How to create folders',
      category: 'Getting Started',
      icon: Icons.create_new_folder,
      content: 'To create a new folder, tap the + button and select "New Folder". Give your folder a name and tap "Create".',
    ),
    HelpItem(
      title: 'Offline access',
      category: 'Tips & Tricks',
      icon: Icons.offline_pin,
      content: 'Mark files for offline access by tapping the "Available Offline" option in the file menu. These files will be accessible without an internet connection.',
    ),
    HelpItem(
      title: 'Backup settings',
      category: 'Tutorials',
      icon: Icons.backup,
      content: 'Configure automatic backups in Settings > Backup & Sync. You can choose which folders to back up and how often.',
    ),
    HelpItem(
      title: 'Security features',
      category: 'Tips & Tricks',
      icon: Icons.security,
      content: 'Enable two-factor authentication in Settings > Security for additional protection of your cloud storage account.',
    ),
  ];

  List<HelpItem> get _filteredItems {
    if (_searchQuery.isEmpty && _selectedCategory == 'All') {
      return _helpItems;
    } else if (_searchQuery.isEmpty) {
      return _helpItems.where((item) => item.category == _selectedCategory).toList();
    } else {
      var filtered = _helpItems.where(
        (item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                 item.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      
      if (_selectedCategory != 'All') {
        filtered = filtered.where((item) => item.category == _selectedCategory).toList();
      }
      
      return filtered;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Animated header with search
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 180 : 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: Text(
                    'How can we help you today?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Hero(
                    tag: 'searchBar',
                    child: Material(
                      color: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              if (value.isNotEmpty && !_isExpanded) {
                                _isExpanded = true;
                                _animationController.forward();
                              } else if (value.isEmpty && _isExpanded) {
                                _isExpanded = false;
                                _animationController.reverse();
                              }
                            });
                          },
                          onTap: () {
                            setState(() {
                              _isExpanded = true;
                              _animationController.forward();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for help topics',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.search, color: Colors.blue),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _isExpanded = false;
                                        _animationController.reverse();
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Category chips
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.vertical,
                      child: child!,
                    );
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: _helpCategories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: _selectedCategory == category ? Colors.white : Colors.grey.shade700,
                                fontWeight: _selectedCategory == category ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            selectedColor: Colors.blue.shade600,
                            backgroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return AnimatedHelpCard(
                        helpItem: item,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String category;
  final IconData icon;
  final String content;
  bool isExpanded;

  HelpItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.content,
    this.isExpanded = false,
  });
}

class AnimatedHelpCard extends StatefulWidget {
  final HelpItem helpItem;
  final int index;

  const AnimatedHelpCard({
    Key? key,
    required this.helpItem,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedHelpCard> createState() => _AnimatedHelpCardState();
}

class _AnimatedHelpCardState extends State<AnimatedHelpCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.helpItem.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: widget.helpItem.isExpanded ? 4 : 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              widget.helpItem.isExpanded = !widget.helpItem.isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getCategoryColor(widget.helpItem.category).withOpacity(0.2),
                      child: Icon(
                        widget.helpItem.icon,
                        color: _getCategoryColor(widget.helpItem.category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.helpItem.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.helpItem.content,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.video_library, size: 18),
                              label: const Text('Watch Tutorial'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video tutorial coming soon!'))
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                              label: const Text('Helpful'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thank you for your feedback!'))
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                side: BorderSide(color: Colors.green.shade200),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: widget.helpItem.isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Getting Started':
        return Colors.green.shade600;
      case 'FAQ':
        return Colors.orange.shade600;
      case 'Tutorials':
        return Colors.purple.shade600;
      case 'Tips & Tricks':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
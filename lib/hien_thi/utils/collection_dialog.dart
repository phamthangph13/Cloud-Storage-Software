import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../API_Services/Collection_services.dart';
import '../../API_Services/File_services.dart';

class CollectionDialog extends StatefulWidget {
  final String fileId;
  final String token;
  final Function? onSuccess;

  const CollectionDialog({
    Key? key,
    required this.fileId,
    required this.token,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<CollectionDialog> {
  final CollectionService _collectionService = CollectionService();
  final FileService _fileService = FileService();
  List<dynamic> _collections = [];
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;
  TextEditingController _newCollectionNameController = TextEditingController();
  bool _showNewCollectionField = false;
  int? _selectedCollectionIndex;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final collections = await _collectionService.getAllCollections(widget.token);
      
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewCollection() async {
    final name = _newCollectionNameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final result = await _collectionService.createCollection(name, widget.token);
      _newCollectionNameController.clear();
      
      setState(() {
        _showNewCollectionField = false;
        _isSubmitting = false;
      });
      
      // Reload the collections
      await _loadCollections();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }

  Future<void> _addToCollection(String collectionId) async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      await _fileService.addFileToCollection(widget.fileId, collectionId, widget.token);
      
      setState(() {
        _isSubmitting = false;
      });
      
      // Call onSuccess callback if provided
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
      
      Navigator.of(context).pop(true);
      
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File added to collection successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
              ? [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black38
                : Colors.black12,
              blurRadius: 20.0,
              offset: Offset(0.0, 10.0),
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.collections_bookmark,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Save to Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              
              // Content
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(delay: Duration(milliseconds: 200)),
                    
                    if (_isLoading)
                      Container(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading collections...',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 300))
                    else if (_collections.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.collections_outlined,
                              size: 56,
                              color: isDarkMode ? Colors.white30 : Colors.black26,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No collections found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create a new one to get started',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white54 : Colors.black45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 200))
                    else
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          shrinkWrap: true,
                          itemCount: _collections.length,
                          itemBuilder: (context, index) {
                            final collection = _collections[index];
                            final bool isSelected = _selectedCollectionIndex == index;
                            
                            return InkWell(
                              onTap: _isSubmitting 
                                ? null 
                                : () {
                                    setState(() {
                                      _selectedCollectionIndex = index;
                                    });
                                  },
                              borderRadius: BorderRadius.circular(16),
                              child: Material(
                                elevation: isSelected ? 4 : 1,
                                animationDuration: Duration(milliseconds: 200),
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected 
                                  ? primaryColor.withOpacity(0.1)
                                  : isDarkMode ? Colors.grey[800] : Colors.white,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected 
                                        ? primaryColor
                                        : isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                            ? primaryColor.withOpacity(0.2)
                                            : isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.folder,
                                          color: isSelected
                                            ? primaryColor
                                            : isDarkMode ? Colors.white70 : Colors.grey[700],
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        collection['name'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                            ? primaryColor
                                            : isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.2, end: 0);
                          },
                        ),
                      ),
                    
                    SizedBox(height: 12),
                    
                    if (_showNewCollectionField)
                      Container(
                        margin: EdgeInsets.only(bottom: 16, top: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newCollectionNameController,
                                decoration: InputDecoration(
                                  hintText: 'New collection name',
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                autofocus: true,
                              ),
                            ),
                            SizedBox(width: 8),
                            Material(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: _isSubmitting ? null : _createNewCollection,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    
                    // Action buttons
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          // New Collection Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _showNewCollectionField = !_showNewCollectionField;
                                      if (!_showNewCollectionField) {
                                        _newCollectionNameController.clear();
                                      }
                                    });
                                  },
                              icon: Icon(_showNewCollectionField ? Icons.close : Icons.add),
                              label: Text(_showNewCollectionField ? 'Cancel' : 'New Collection'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: _showNewCollectionField 
                                  ? Colors.grey[600]
                                  : Colors.blue[700],
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Close button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting
                                ? null
                                : _selectedCollectionIndex != null
                                  ? () => _addToCollection(_collections[_selectedCollectionIndex!]['id'])
                                  : () => Navigator.of(context).pop(),
                              child: Text(_selectedCollectionIndex != null ? 'Save' : 'Close'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: _selectedCollectionIndex != null
                                  ? Colors.green[600]
                                  : Colors.grey[500],
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_isSubmitting)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ).animate().fadeIn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show collection dialog
Future<bool?> showCollectionDialog(
  BuildContext context, {
  required String fileId,
  required String token,
  Function? onSuccess,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CollectionDialog(
      fileId: fileId,
      token: token,
      onSuccess: onSuccess,
    ),
  );
} 
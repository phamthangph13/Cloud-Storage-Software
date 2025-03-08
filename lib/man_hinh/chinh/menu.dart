import 'package:flutter/material.dart';
import './home_khach.dart';
import './tin_tuc.dart';
import './gioi_thieu.dart';
import './tim_kiem.dart';
import '../xac_thuc/dang_nhap.dart';
import './trang_chu.dart';
import './luu_tru.dart';
import './DashBoard.dart';
import './mua_dung_luong.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../API_Services/File_services.dart';
import '../../API_Services/Auth_services.dart';

class MenuScreen extends StatefulWidget {
  final bool isAuthenticated;
  const MenuScreen({super.key, this.isAuthenticated = false});

  @override 
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  String? _authToken;
  late List<Widget> _pages = _getDefaultPages();
  final AuthService _authService = AuthService();
  final FileService _fileService = FileService();

  List<Widget> _getDefaultPages() {
    return widget.isAuthenticated
        ? [
            const HomeScreen(),
            const StorageScreen(showBackButton: false),
            Container(), // Placeholder for upload options
            const StoragePurchasePage(),
            const DashBoard(), // No longer passing token
          ]
        : [
            const HomeKhachScreen(),
            const NewsScreen(),
            const SearchScreen(),
            const AboutUsScreen(),
            const AuthenticatorScreen(),
          ];
  }

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  } 

  Future<void> _loadAuthToken() async {
    try {
      if (!mounted) return;
      
      final token = await _authService.getToken();
      
      if (token == null || token.isEmpty) {
        // Only redirect to login if the widget is supposed to be authenticated
        if (widget.isAuthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthenticatorScreen()));
        }
        return;
      }
      
      setState(() {
        _authToken = token;
        // No need to update the DashBoard component with token anymore
      });
    } catch (e) {
      // Only redirect to login on error if the widget is supposed to be authenticated
      if (widget.isAuthenticated) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthenticatorScreen()));
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _showUploadOptions() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
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
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Tải lên',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildUploadTile(
            icon: Icons.image_outlined,
            title: 'Hình ảnh',
            subtitle: 'JPG, PNG, GIF, etc.',
            color: Colors.green,
            onTap: () => _pickAndUploadFiles(FileType.image),
          ),
          _buildUploadTile(
            icon: Icons.video_library_outlined,
            title: 'Video',
            subtitle: 'MP4, MOV, AVI, etc.',
            color: Colors.blue,
            onTap: () => _pickAndUploadFiles(FileType.video),
          ),
          _buildUploadTile(
            icon: Icons.insert_drive_file_outlined,
            title: 'Tài liệu',
            subtitle: 'PDF, DOC, XLS, etc.',
            color: Colors.orange,
            onTap: () => _pickAndUploadFiles(
              FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv', 'json', 'xml'],
            ),
          ),
          _buildUploadTile(
            icon: Icons.folder_outlined,
            title: 'Tạo bộ sưu tập',
            subtitle: 'Nhóm các file lại với nhau',
            color: Colors.purple,
            onTap: () {
              Navigator.pop(context);
              // Handle collection creation
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildUploadTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickAndUploadFiles(FileType type, {List<String>? allowedExtensions}) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: type,
    allowedExtensions: allowedExtensions,
    allowMultiple: true,
  );
  
  if (result != null) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    
    // Show confirmation dialog
    bool? shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xác nhận tải lên',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bạn đã chọn ${files.length} file',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final fileName = files[index].path.split('/').last;
                    final fileExtension = fileName.split('.').last.toLowerCase();
                    
                    IconData fileIcon;
                    Color iconColor;
                    
                    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
                      fileIcon = Icons.image;
                      iconColor = Colors.green;
                    } else if (['mp4', 'mov', 'avi', 'webm'].contains(fileExtension)) {
                      fileIcon = Icons.video_file;
                      iconColor = Colors.blue;
                    } else if (['pdf'].contains(fileExtension)) {
                      fileIcon = Icons.picture_as_pdf;
                      iconColor = Colors.red;
                    } else if (['doc', 'docx'].contains(fileExtension)) {
                      fileIcon = Icons.description;
                      iconColor = Colors.indigo;
                    } else if (['xls', 'xlsx', 'csv'].contains(fileExtension)) {
                      fileIcon = Icons.table_chart;
                      iconColor = Colors.green;
                    } else {
                      fileIcon = Icons.insert_drive_file;
                      iconColor = Colors.orange;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(fileIcon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${(files[index].lengthSync() / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Hủy bỏ'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Tải lên'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (shouldUpload == true) {
      try {
        // Show upload progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Đang tải lên...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng đợi trong khi chúng tôi tải lên ${files.length} file của bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
        
        // Determine appropriate tags based on file type
        List<String> tags = [];
        if (type == FileType.image) {
          tags.add('image');
        } else if (type == FileType.video) {
          tags.add('video');
        } else if (type == FileType.custom) {
          tags.add('document');
        }
        
        // Upload files
        List<Map<String, dynamic>> results = [];
        if (files.length == 1) {
          // Upload single file
          final result = await _fileService.uploadFile(
            files[0],
            tags: tags,
          );
          results.add(result);
        } else {
          // Upload multiple files
          results = await _fileService.uploadMultipleFiles(
            files,
            tags: tags,
          );
        }
        
        Navigator.of(context).pop(); // Dismiss loading dialog
        if (!mounted) return;
        
        // Show success or error dialog based on results
        bool hasErrors = results.any((result) => result['success'] == false);
        
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasErrors ? Icons.error_outline : Icons.check_circle_outline,
                    color: hasErrors ? Colors.red : Colors.green,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasErrors ? 'Tải lên thất bại' : 'Tải lên thành công',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasErrors 
                      ? 'Có lỗi xảy ra khi tải lên file. Vui lòng thử lại sau.'
                      : 'Tất cả ${files.length} file đã được tải lên thành công.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasErrors ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(hasErrors ? 'Đóng' : 'Hoàn thành'),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        // Handle any unexpected errors
        Navigator.of(context).pop(); // Dismiss loading dialog if still showing
        if (!mounted) return;
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lỗi không xác định',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đã xảy ra lỗi: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }
  if (Navigator.canPop(context)) {
    Navigator.pop(context); // Close the bottom sheet
  }
}

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2 && widget.isAuthenticated) {
            _showUploadOptions();
          } else {
            _onItemTapped(index);
          }
        },
        destinations: widget.isAuthenticated
            ? [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Storage',
                ),
                NavigationDestination(
                  icon: const SizedBox(
                    height: 50,
                    width: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.upload_outlined, color: Colors.white),
                    ),
                  ),
                  selectedIcon: const SizedBox(
                    height: 50,
                    width: 50, 
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.upload, color: Colors.white),
                    ),
                  ),
                  label: '',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.info_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_outlined),
                  label: 'Purchase',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outlined),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper),
                  label: 'News',
                ),
                NavigationDestination(
                  icon: const SizedBox(
                    height: 50,
                    width: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.search_outlined, color: Colors.white),
                    ),
                  ),
                  selectedIcon: const SizedBox(
                    height: 50,
                    width: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.info_outlined),
                  selectedIcon: Icon(Icons.info),
                  label: 'About',
                ),
                NavigationDestination(
                  icon: Icon(Icons.login_outlined),
                  selectedIcon: Icon(Icons.login),
                  label: 'Login',
                ),
              ],
      ),
    );
  }
}
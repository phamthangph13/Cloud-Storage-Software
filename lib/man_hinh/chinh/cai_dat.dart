import 'package:flutter/material.dart';
import '../../API_Services/Auth_services.dart';
import '../xac_thuc/dang_nhap.dart';
import './home_khach.dart'; // Import HomeKhachScreen
import './menu.dart'; // Import MenuScreen

class SettingsScreen extends StatefulWidget {
  final String token;

  const SettingsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  
  Future<void> _logout() async {
    // Show confirmation dialog first
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!shouldLogout) return;
    
    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Đang đăng xuất..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Clear auth token
      await _authService.clearToken();
      
      // If mounted, navigate to guest home screen
      if (!mounted) return;
      
      // Close loading dialog and navigate to MenuScreen with isAuthenticated=false
      Navigator.of(context).pop(); // Close loading dialog
      
      // Use pushAndRemoveUntil to clear navigation stack and set MenuScreen as root
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MenuScreen(isAuthenticated: false)),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // If there's an error, close the loading dialog and show error
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng xuất thất bại: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader('Tài khoản'),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Thông tin cá nhân'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Bảo mật'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to security settings
            },
          ),
          
          // Storage section
          _buildSectionHeader('Lưu trữ'),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.purple),
            title: const Text('Quản lý dung lượng'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to storage management
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.orange),
            title: const Text('Thùng rác'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to trash
            },
          ),
          
          // App settings section
          _buildSectionHeader('Ứng dụng'),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: const Text('Thông báo'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text('Ngôn ngữ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to language settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.amber),
            title: const Text('Giao diện'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to theme settings
            },
          ),
          
          // Others section
          _buildSectionHeader('Khác'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('Giới thiệu'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to about page
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.indigo),
            title: const Text('Trợ giúp'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to help page
            },
          ),
          
          // Logout button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 
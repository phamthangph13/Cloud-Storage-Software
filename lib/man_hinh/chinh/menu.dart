import 'package:flutter/material.dart';
import '../chinh/trang_chu.dart';
import '../chinh/luu_tru.dart';
import '../xac_thuc/dang_nhap.dart';
import '../chinh/nhan_ai.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(),
    const StorageScreen(showBackButton: false),
    const HomeScreen(), // Placeholder for upload button
    const NhanAIPage(),
    const AuthenticatorScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Show bottom sheet when + button is tapped
      _showUploadOptions();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload and Create',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildUploadOption(Icons.image, 'Upload Image', Colors.blue),
            _buildUploadOption(Icons.video_library, 'Upload Video', Colors.red),
            _buildUploadOption(Icons.description, 'Upload Document', Colors.green),
            _buildUploadOption(Icons.collections, 'Create Collection', const Color.fromARGB(255, 51, 20, 192)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUploadOption(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement upload functionality
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.folder_outlined),
                activeIcon: Icon(Icons.folder),
                label: 'Collection',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'AI Labeling',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Login',
              ),
            ],
            currentIndex: _selectedIndex == 2 ? 0 : _selectedIndex,
            selectedItemColor: Colors.blue.shade700,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: _onItemTapped,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

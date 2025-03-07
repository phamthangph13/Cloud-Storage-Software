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

class MenuScreen extends StatefulWidget {
  final bool isAuthenticated;
  const MenuScreen({super.key, this.isAuthenticated = false});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  String? _authToken;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
      _initializePages();
    });
  }

  void _initializePages() {
    _pages = widget.isAuthenticated
        ? [
            const HomeScreen(),
            const StorageScreen(showBackButton: false),
            Container(), // Placeholder for upload options
            const StoragePurchasePage(),
            DashBoard(token: _authToken ?? ''),
          ]
        : [
            const HomeKhachScreen(),
            const NewsScreen(),
            const SearchScreen(),
            const AboutUsScreen(),
            const AuthenticatorScreen(),
          ];
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload Image'),
              onTap: () {
                // Handle image upload
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Upload Video'),
              onTap: () {
                // Handle video upload
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Document'),
              onTap: () {
                // Handle document upload
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: const Text('Create Collection'),
              onTap: () {
                // Handle video upload
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
                  icon: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.upload_outlined, color: Colors.white),
                  ),
                  selectedIcon: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.upload, color: Colors.white),
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
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
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
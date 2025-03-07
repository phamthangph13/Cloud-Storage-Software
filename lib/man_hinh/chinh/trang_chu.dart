import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Anh.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Video.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Tai_Lieu.dart';
import '../chinh/luu_tru.dart';
import '../tien_ich/tai_xuong.dart';
import '../tien_ich/thong_bao.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Thung_Rac.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<String> adImages = [];
  late TabController filterTabController;
  bool _mounted = true;  // Add this line
  int selectedTabIndex = 0;
  final List<String> filterTabs = ['Tất cả', 'Đã xem', 'Đã lưu', 'Đã tải lên'];
  @override
  void initState() {
    super.initState();
    _loadAds();
    filterTabController = TabController(length: filterTabs.length, vsync: this);
  }
  Future<void> _loadAds() async {
    // Directly assign the ad image URLs
    setState(() {
      adImages = [
        "assets/img/img_1.jpg",
        "assets/img/img_2.jpg",
        "assets/img/img_4.jpg"
      ];
    });
  }
  @override
  void dispose() {
    _mounted = false;  // Add this line
    filterTabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Yune',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {
              showNotificationsSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black87),
            onPressed: () {
              showDownloadsSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm trong Yune',
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuItem(
                    icon: Icons.image,
                    label: 'Ảnh',
                    bgColor: Colors.blue[100]!,
                    iconColor: Colors.blue,
                  ),
                  _buildMenuItem(
                    icon: Icons.video_library,
                    label: 'Video',
                    bgColor: Colors.red[100]!,
                    iconColor: Colors.red,
                  ),
                  _buildMenuItem(
                    icon: Icons.description,
                    label: 'Tài liệu',
                    bgColor: Colors.green[100]!,
                    iconColor: Colors.green,
                  ),
                  _buildMenuItem(
                    icon: Icons.collections,
                    label: 'Collection',
                    bgColor: Colors.purple[100]!,
                    iconColor: Colors.purple,
                  ),
                  _buildMenuItem(
                    icon: Icons.restore_from_trash,
                    label: 'Thùng rác',
                    bgColor: Colors.brown,
                    iconColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              adImages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CarouselSlider.builder(
                      itemCount: adImages.length,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        autoPlayInterval: const Duration(seconds: 3),
                      ),
                      itemBuilder: (context, index, realIndex) {
                        if (!mounted) return Container();  // Add this check
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            adImages[index],
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Không tải được ảnh',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 30),
              _buildOtherContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Ảnh':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImageViewScreen(),
              ),
            );
            break;
          case 'Video':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VideoViewScreen(),
              ),
            );
            break;
          case 'Tài liệu':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocumentViewScreen(),
              ),
            );
            break;
          case 'Collection':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StorageScreen(showBackButton: true),
              ),
            );
            break;
          case 'Thùng rác':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrashScreen(showBackButton: true),
              ),
            );
            break;
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  Widget _buildOtherContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue[600],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Gần đây'),
                    Tab(text: 'Ưa thích'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 450,
                child: TabBarView(
                  children: [
                    _buildRecentTabContent(),
                    _buildFavoriteTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTabContent() {
    return Column(
      children: [
        Container(
          height: 45,
          margin: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(filterTabs.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildFilterButton(filterTabs[index], index == selectedTabIndex, index),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildImageContentItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteTabContent() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildImageContentItem(index, isFavorite: true);
      },
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContentItem(int index, {bool isFavorite = false}) {
    final colors = [
      Colors.blue[100],
      Colors.green[100],
      Colors.purple[100],
      Colors.orange[100],
      Colors.red[100],
      Colors.teal[100],
    ];
    final contentTypes = ['Ảnh', 'Video', 'Tài liệu', 'Collection'];
    final contentType = contentTypes[index % contentTypes.length];
    final icons = [
      Icons.image,
      Icons.video_library,
      Icons.description,
      Icons.collections,
    ];
    final icon = icons[index % icons.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icon,
                          size: 40,
                          color: Colors.black38,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black38,
                          size: 22,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: InkWell(
                          onTap: () {
                            _showOptionsSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$contentType ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '2 giờ trước',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildOptionItem(context, Icons.download, 'Tải xuống', Colors.blue),
              _buildOptionItem(context, Icons.delete, 'Xoá', Colors.red),
              _buildOptionItem(context, Icons.favorite, 'Yêu thích', Colors.pink),
              _buildOptionItem(
                  context, Icons.collections, 'Thêm vào Collection', Colors.purple),
              _buildOptionItem(context, Icons.edit, 'Đổi tên', Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
      BuildContext context, IconData icon, String label, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
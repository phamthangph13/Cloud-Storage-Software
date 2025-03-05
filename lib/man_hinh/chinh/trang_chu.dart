import 'package:flutter/material.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Anh.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Video.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Tai_Lieu.dart';
import '../chinh/luu_tru.dart';
import '../tien_ich/tai_xuong.dart';
import '../tien_ich/thong_bao.dart';
import 'package:cloudstorage/hien_thi/Hien_Thi_Thung_Rac.dart';
// Trang HomeScreen - Trang chủ
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Danh sách demo quảng cáo (sử dụng ảnh từ network)
  final List<String> adImages = [
    'https://via.placeholder.com/350x150?text=Ad+1',
    'https://via.placeholder.com/350x150?text=Ad+2',
    'https://via.placeholder.com/350x150?text=Ad+3',
  ];

  // Tab controller cho menu tùy chọn
  late TabController filterTabController;
  int selectedTabIndex = 0;

  // Tab labels for the filter options
  final List<String> filterTabs = ['Tất cả', 'Đã xem', 'Đã lưu', 'Đã tải lên'];

  @override
  void initState() {
    super.initState();
    filterTabController = TabController(length: filterTabs.length, vsync: this);
  }

  @override
  void dispose() {
    filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Màu nền tổng thể nhẹ nhàng
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

      // Sử dụng SingleChildScrollView để cuộn toàn bộ nội dung
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
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

              // Menu lựa chọn: Ảnh, Video, Tài liệu, Collection
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
              const SizedBox(height: 30),

              // Phần quảng cáo
              const Text(
                'Các quảng cáo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: adImages.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        adImages[index],
                        width: 350,
                        height: 150,
                        fit: BoxFit.cover,
                        // Thêm xử lý lỗi cho Flutter web (nếu ảnh không load được)
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 350,
                            height: 150,
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
              ),
              const SizedBox(height: 30),

              // Phần "Nội dung khác" được thiết kế lại
              _buildOtherContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tiện ích xây dựng các mục menu
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        // Xử lý điều hướng dựa trên label
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
              // Tab chính được thiết kế đẹp hơn (đã loại bỏ đường kẻ)
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
                  // Remove indicator padding to eliminate the line
                  indicatorPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  // Remove underline
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Gần đây'),
                    Tab(text: 'Ưa thích'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nội dung tab
              SizedBox(
                height: 450, // Tăng chiều cao để hiển thị đầy đủ nội dung
                child: TabBarView(
                  children: [
                    // Tab Gần đây với thiết kế mới
                    _buildRecentTabContent(),

                    // Tab Ưa thích
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

  // Widget cho tab Gần đây với thiết kế mới
  Widget _buildRecentTabContent() {
    return Column(
      children: [
        // Các nút lọc được thiết kế đẹp hơn và có thể chuyển qua lại
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

        // Nội dung Grid hiển thị các mục
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6, // Demo với 6 mục
            itemBuilder: (context, index) {
              return _buildImageContentItem(index);
            },
          ),
        ),
      ],
    );
  }

  // Widget cho tab Ưa thích
  Widget _buildFavoriteTabContent() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4, // Demo với 4 mục ưa thích
      itemBuilder: (context, index) {
        return _buildImageContentItem(index, isFavorite: true);
      },
    );
  }

  // Widget cho các nút filter có thể chuyển qua lại
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

  // Widget cho các mục nội dung dạng ảnh với góc bo tròn và menu 3 chấm
  Widget _buildImageContentItem(int index, {bool isFavorite = false}) {
    // Tạo màu ngẫu nhiên cho demo
    final colors = [
      Colors.blue[100],
      Colors.green[100],
      Colors.purple[100],
      Colors.orange[100],
      Colors.red[100],
      Colors.teal[100],
    ];

    // Các loại nội dung khác nhau
    final contentTypes = ['Ảnh', 'Video', 'Tài liệu', 'Collection'];
    final contentType = contentTypes[index % contentTypes.length];

    // Icon tương ứng với từng loại
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
        onTap: () {
          // Xử lý sự kiện khi người dùng chọn một mục
        },
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
              // Phần ảnh/thumbnail với góc bo tròn
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
                      // Icon yêu thích ở góc phải
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black38,
                          size: 22,
                        ),
                      ),
                      // Icon 3 chấm menu
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
              // Phần thông tin
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

  // Hiển thị bottom sheet với các tùy chọn
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

  // Widget cho mỗi mục tùy chọn trong sheet
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
        // Xử lý logic tương ứng với mỗi tùy chọn
      },
    );
  }
}
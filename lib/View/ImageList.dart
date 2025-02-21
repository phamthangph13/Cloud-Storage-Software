import 'package:flutter/material.dart';

class ImageList extends StatelessWidget {
  ImageList({super.key});

  // Danh sách các URL ảnh demo
  final List<String> imageUrls = [
    'https://picsum.photos/seed/1/600/400',
    'https://picsum.photos/seed/2/600/400',
    'https://picsum.photos/seed/3/600/400',
    'https://picsum.photos/seed/4/600/400',
    'https://picsum.photos/seed/5/600/400',
    'https://picsum.photos/seed/6/600/400',
    'https://picsum.photos/seed/7/600/400',
    'https://picsum.photos/seed/8/600/400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Nền nhẹ nhàng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Image List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: imageUrls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Hiển thị 2 cột
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 3, // Tỉ lệ phù hợp cho ảnh
          ),
          itemBuilder: (context, index) {
            return _buildImageCard(imageUrls[index]);
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(String url) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ảnh nền
          Positioned.fill(
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Icon(Icons.error, color: Colors.white, size: 40),
                );
              },
            ),
          ),
          // Overlay gradient tạo hiệu ứng đẹp mắt
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StorageScreen extends StatelessWidget {
  final bool showBackButton;
  
  const StorageScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: const Text(
          'My Collection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Collection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // TODO: Navigate to favorites screen
                },
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.2, end: 0),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Yêu Thích',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('các tập tin được yêu thích', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                leading: Icon(Icons.timelapse, color: Colors.blue.shade400, size: 28),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: const EdgeInsets.all(12),
                    children: [
                      _MediaItem(
                        type: 'image',
                        date: '20/03/2024',
                        thumbnail: 'https://picsum.photos/200',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 200.ms),
                      _MediaItem(
                        type: 'video',
                        date: '15/03/2024',
                        thumbnail: 'https://picsum.photos/201',
                        isFavorite: false,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 400.ms),
                      _MediaItem(
                        type: 'image',
                        date: '10/03/2024',
                        thumbnail: 'https://picsum.photos/202',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 600.ms),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '2024',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Hiện tại', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                leading: Icon(Icons.timelapse, color: Colors.blue.shade400, size: 28),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: const EdgeInsets.all(12),
                    children: [
                      _MediaItem(
                        type: 'image',
                        date: '20/03/2024',
                        thumbnail: 'https://picsum.photos/200',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 200.ms),
                      _MediaItem(
                        type: 'video',
                        date: '15/03/2024',
                        thumbnail: 'https://picsum.photos/201',
                        isFavorite: false,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 400.ms),
                      _MediaItem(
                        type: 'image',
                        date: '10/03/2024',
                        thumbnail: 'https://picsum.photos/202',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 600.ms),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.purple.shade700],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '2023',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                leading: Icon(Icons.timeline, color: Colors.purple.shade400, size: 28),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: const EdgeInsets.all(12),
                    children: [
                      _MediaItem(
                        type: 'video',
                        date: '25/12/2023',
                        thumbnail: 'https://picsum.photos/203',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 200.ms),
                      _MediaItem(
                        type: 'image',
                        date: '20/11/2023',
                        thumbnail: 'https://picsum.photos/204',
                        isFavorite: false,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 400.ms),
                      _MediaItem(
                        type: 'image',
                        date: '15/10/2023',
                        thumbnail: 'https://picsum.photos/205',
                        isFavorite: true,
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(delay: 600.ms),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  final String type;
  final String date;
  final String thumbnail;
  final bool isFavorite;

  const _MediaItem({
    required this.type,
    required this.date,
    required this.thumbnail,
    required this.isFavorite,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Sửa tên'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement rename functionality
              },
            ),
            ListTile(
              leading: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              title: Text(isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add/remove favorites
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Tải xuống'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xoá'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              if (isFavorite)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                    .scale(
                      duration: 800.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                    )
                    .then()
                    .scale(
                      duration: 800.ms,
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1, 1),
                    ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    type == 'video' ? Icons.play_circle : Icons.image,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

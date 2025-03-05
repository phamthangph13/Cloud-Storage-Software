import 'package:flutter/material.dart';

// Function to show the downloads sheet
void showDownloadsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DownloadSheetContent();
    },
  );
}

class DownloadSheetContent extends StatelessWidget {
  DownloadSheetContent({Key? key}) : super(key: key);

  // Sample download data
  final List<Map<String, dynamic>> downloads = [
    {
      'name': 'Project_Report.pdf',
      'size': '2.5 MB',
      'progress': 0.8,
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'name': 'Vacation_Photos.zip',
      'size': '15.7 MB',
      'progress': 0.45,
      'icon': Icons.photo_library,
      'color': Colors.blue,
    },
    {
      'name': 'Presentation.pptx',
      'size': '5.2 MB',
      'progress': 0.95,
      'icon': Icons.slideshow,
      'color': Colors.orange,
    },
    {
      'name': 'Budget_2023.xlsx',
      'size': '1.8 MB',
      'progress': 0.3,
      'icon': Icons.table_chart,
      'color': Colors.green,
    },
    {
      'name': 'Tutorial_Video.mp4',
      'size': '45.6 MB',
      'progress': 0.6,
      'icon': Icons.video_file,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      // Use MediaQuery to make the sheet take up to 70% of screen height
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar at top
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Đang tải về',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle pause all downloads
                  },
                  child: const Text('Tạm dừng tất cả'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Downloads list
          Expanded(
            child: downloads.isEmpty
                ? const Center(child: Text('Không có tệp đang tải về'))
                : ListView.builder(
                    itemCount: downloads.length,
                    itemBuilder: (context, index) {
                      final download = downloads[index];
                      return _buildDownloadItem(
                        name: download['name'],
                        size: download['size'],
                        progress: download['progress'],
                        icon: download['icon'],
                        color: download['color'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem({
    required String name,
    required String size,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    // Handle menu item selection
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pause',
                      child: Text('Tạm dừng'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Hủy'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
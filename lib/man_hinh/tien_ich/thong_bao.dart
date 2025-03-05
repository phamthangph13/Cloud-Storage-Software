import 'package:flutter/material.dart';

// Function to show the notifications sheet
void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return NotificationSheetContent();
    },
  );
} 

class NotificationSheetContent extends StatelessWidget {
  NotificationSheetContent({Key? key}) : super(key: key);

  // Sample notification data
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Tải lên hoàn tất',
      'message': 'Tệp "Project_Report.pdf" đã được tải lên thành công.',
      'time': '5 phút trước',
      'icon': Icons.cloud_upload,
      'color': Colors.green,
    },
    {
      'title': 'Chia sẻ mới',
      'message': 'Nguyễn Văn A đã chia sẻ thư mục "Photos" với bạn.',
      'time': '1 giờ trước',
      'icon': Icons.folder_shared,
      'color': Colors.blue,
    },
    {
      'title': 'Dung lượng lưu trữ',
      'message': 'Bạn đã sử dụng 80% dung lượng lưu trữ. Nâng cấp ngay!',
      'time': '3 giờ trước',
      'icon': Icons.storage,
      'color': Colors.orange,
    },
    {
      'title': 'Bảo mật',
      'message': 'Đã phát hiện đăng nhập mới trên thiết bị lạ.',
      'time': '1 ngày trước',
      'icon': Icons.security,
      'color': Colors.red,
    },
    {
      'title': 'Cập nhật ứng dụng',
      'message': 'Phiên bản mới đã sẵn sàng. Cập nhật ngay!',
      'time': '2 ngày trước',
      'icon': Icons.system_update,
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
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle mark all as read
                  },
                  child: const Text('Đánh dấu tất cả đã đọc'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Notification list
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('Không có thông báo'))
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(
                        title: notification['title'],
                        message: notification['message'],
                        time: notification['time'],
                        icon: notification['icon'],
                        color: notification['color'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {
            // Show options for this notification
          },
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}
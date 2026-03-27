import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  // Data notifikasi kita pindahkan ke dalam State agar bisa diubah
  List<Map<String, dynamic>> notifications = [
    {
      "title": "Booking Confirmed! 🎉",
      "message": "Your booking for Court #4 at PadelPro Center is confirmed for today at 18:30.",
      "time": "Just now",
      "icon": Icons.check_circle,
      "color": Colors.green,
      "isRead": false, // Ini yang bikin titik merahnya muncul
    },
    {
      "title": "Match Reminder ⏰",
      "message": "Don't forget! Your semi-final match at Club de Padel Madrid starts in 2 hours.",
      "time": "2 hours ago",
      "icon": Icons.sports_tennis,
      "color": const Color(0xFF0d59f2),
      "isRead": false, // Ini juga
    },
    {
      "title": "Summer Pro League Promo ☀️",
      "message": "Get 20% off your next booking this weekend. Claim your offer now!",
      "time": "1 day ago",
      "icon": Icons.local_offer,
      "color": Colors.orange,
      "isRead": true,
    },
    {
      "title": "System Update ⚙️",
      "message": "We've updated our app to provide you with a smoother booking experience.",
      "time": "3 days ago",
      "icon": Icons.system_update,
      "color": Colors.grey,
      "isRead": true,
    },
  ];

  // LOGIKA UNTUK MENGHAPUS SEMUA TITIK MERAH
  void markAllAsRead() {
    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = true; // Ubah semua status menjadi sudah dibaca
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            onPressed: () {
              // PANGGIL FUNGSINYA DI SINI KETIKA TOMBOL DIKLIK
              markAllAsRead();
              
              // Kasih notifikasi kecil di bawah layar kalau berhasil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications marked as read"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(primaryColor)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif['isRead'] ? Colors.white : const Color(0xFFF4F8FF), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif['isRead'] ? Colors.grey.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: notif['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notif['icon'], color: notif['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(
                        notif['time'],
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif['message'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif['isRead']) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "When you get updates or reminders,\nthey'll show up here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
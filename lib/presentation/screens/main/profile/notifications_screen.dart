import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'New Pet Available',
      'message': 'A new German Shepherd has been added to our list',
      'image': 'shephard.jpg',
      'timestamp': 'Today at 10:30 AM',
      'read': false,
    },
    {
      'id': 2,
      'title': 'Booking Confirmed',
      'message': 'Your booking for Kaali has been confirmed',
      'timestamp': 'Yesterday at 3:45 PM',
      'read': false,
    },
    {
      'id': 3,
      'title': 'Pet Adoption Success',
      'message': 'Congratulations! Gori has been adopted successfully',
      'timestamp': '2 days ago',
      'read': true,
    },
    {
      'id': 4,
      'title': 'Booking Reminder',
      'message': 'Remember your appointment with Khaire tomorrow at 2:00 PM',
      'timestamp': '3 days ago',
      'read': true,
    },
    {
      'id': 5,
      'title': 'Profile Update',
      'message': 'Your profile has been successfully updated',
      'timestamp': '1 week ago',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Afacad',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Mark all as read
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.done_all, color: Color(0xFFF67D2C)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F8),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Afacad',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Afacad',
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onDismiss: () {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  onTap: () {
                    setState(() {
                      notification['read'] = true;
                    });
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification['id'].toString()),
      onDismissed: (_) => onDismiss(),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification['read'] ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: notification['read']
              ? null
              : Border.all(
                  color: const Color(0xFFF67D2C).withValues(alpha: 0.2),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          onTap: onTap,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF67D2C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Color(0xFFF67D2C),
            ),
          ),
          title: Text(
            notification['title'] ?? 'Notification',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Afacad',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification['message'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: 'Afacad',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                notification['timestamp'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontFamily: 'Afacad',
                ),
              ),
            ],
          ),
          trailing: !notification['read']
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF67D2C),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

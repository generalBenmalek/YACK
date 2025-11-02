import 'package:flutter/material.dart';

import '../models/notification.dart';

class NotificationsPage extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationsPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        // foregroundColor: Colors.white,
        // elevation: 1,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Card(
            color: color.surface,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(n.icon, color: color.primary),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
              ),
              subtitle: Text(
                n.body,
                // style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                _formatDate(n.date),
                style: const TextStyle(
                  fontSize: 12,
                  // color: Colors.white60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 80, color: color.onSurface.withOpacity(0.8)),
          const SizedBox(height: 20),
          Text(
            "No notifications yet",
            style: TextStyle(
              color: color.onSurface.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

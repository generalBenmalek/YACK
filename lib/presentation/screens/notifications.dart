import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yack/main.dart';
import 'package:yack/data/db/models/notification.dart';
import 'package:yack/logic/services/translation_handler.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Selection state
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<AppNotification> notifications) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(notifications.map((n) => n.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelected() async {
    await isar.writeTxn(() async {
      await isar.appNotifications.deleteAll(_selectedIds.toList());
    });
    _clearSelection();
  }

  Future<void> _markSelectedAsRead() async {
    await isar.writeTxn(() async {
      for (final id in _selectedIds) {
        final notification = await isar.appNotifications.get(id);
        if (notification != null) {
          notification.isRead = true;
          await isar.appNotifications.put(notification);
        }
      }
    });
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selectedIds.length} ${TranslationHandler.get('selected')}'
              : TranslationHandler.get('notifications_title'),
          style: theme.textTheme.titleMedium,
        ),
        backgroundColor: Colors.transparent,
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _markSelectedAsRead,
                  tooltip: TranslationHandler.get('mark_as_read'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelected,
                  tooltip: TranslationHandler.get('delete'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelection,
                  tooltip: TranslationHandler.get('cancel'),
                ),
              ]
            : null,
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: isar.appNotifications.where().sortByCreatedAtDesc().watch(
          fireImmediately: true,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Select All button when in selection mode
              if (_selectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _selectAll(notifications),
                        icon: const Icon(Icons.select_all, size: 18),
                        label: Text(TranslationHandler.get('select_all')),
                      ),
                    ],
                  ),
                ),
              // Notifications list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final isSelected = _selectedIds.contains(n.id);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectionMode = true;
                          _selectedIds.add(n.id);
                        });
                      },
                      onTap: () {
                        if (_selectionMode) {
                          _toggleSelection(n.id);
                        } else {
                          // navigate to contract or mark as read
                          _markAsRead(n);
                        }
                      },
                      child: Card(
                        color: isSelected
                            ? color.primaryContainer
                            : (n.isRead ? color.surface : color.surfaceVariant),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(color: color.primary, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          leading: isSelected
                              ? Icon(Icons.check_circle, color: color.primary)
                              : Icon(
                                  n.isRead
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: n.isRead
                                      ? color.onSurface.withOpacity(0.5)
                                      : color.primary,
                                ),
                          title: Text(
                            n.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: n.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            n.body,
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            _formatDate(n.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: color.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      await isar.writeTxn(() async {
        notification.isRead = true;
        await isar.appNotifications.put(notification);
      });
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: color.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          Text(
            TranslationHandler.get('no_notifications'),
            style: TextStyle(
              color: color.onSurface.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

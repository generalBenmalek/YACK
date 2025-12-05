import 'package:isar/isar.dart';

part 'notification.g.dart';

@collection
class AppNotification {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;

  late DateTime createdAt;

  /// Optional: link which contract this notification refers to
  int? contractId;   // foreign key-like

  bool isRead = false;

}

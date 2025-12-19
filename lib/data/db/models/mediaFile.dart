import 'package:isar/isar.dart';

import 'contract.dart';

part 'mediaFile.g.dart';

@collection
class MediaFile {
  Id id = Isar.autoIncrement;

  @Index()
  late int contractId;     // foreign key (local Isar contract ID)

  // External MongoDB media ID for deduplication
  @Index(unique: true, replace: true)
  String? externalId;

  late String senderId;
  String? senderName;

  /// Original filename
  late String filename;

  /// Path to local storage file or remote URL
  late String path;

  /// MIME type (image/png, application/pdf, video/mp4, etc.)
  String? mimeType;

  late DateTime createdAt;

  final contract = IsarLink<Contract>();
}

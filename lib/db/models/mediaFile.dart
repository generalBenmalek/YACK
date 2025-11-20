import 'package:isar/isar.dart';

import 'contract.dart';

part 'mediaFile.g.dart';

@collection
class MediaFile {
  Id id = Isar.autoIncrement;

  late int contractId;     // foreign key
  late String senderId;

  /// Path to local storage file
  late String filePath;

  /// Image, PDF, Doc, Video, etc.
  late String type; // or enum

  late DateTime createdAt;

  final contract = IsarLink<Contract>();
}

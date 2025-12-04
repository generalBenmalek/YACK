import 'package:isar/isar.dart';

import 'message.dart';
import 'mediaFile.dart';

part 'contract.g.dart';

enum ContractStatus {
  pending,
  accepted,
  rejected,
  completed,
  onDispute,
}

@collection
class Contract {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? externalId; // for online DB synchronization (firebase)

  late String name;
  late String description;
  late double price;

  late String userA;
  String? userAName; // Display name for userA
  late String userB;
  String? userBName; // Display name for userB

  @enumerated
  late ContractStatus status;

  late DateTime createdAt;
  DateTime? updatedAt;

  // Links
  final messages = IsarLinks<Message>();
  final media = IsarLinks<MediaFile>();
}


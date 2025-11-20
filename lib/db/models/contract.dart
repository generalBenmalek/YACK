import 'package:isar/isar.dart';

import 'message.dart';
import 'mediaFile.dart';

part 'contract.g.dart';

enum ContractStatus {
  pending,
  accepted,
  rejected,
  completed,
}

@collection
class Contract {
  Id id = Isar.autoIncrement;

  late String name;
  late String description;
  late double price;

  late String userA;
  late String userB;

  @enumerated
  late ContractStatus status;

  late DateTime createdAt;
  DateTime? updatedAt;

  // Links
  final messages = IsarLinks<Message>();
  final media = IsarLinks<MediaFile>();
}


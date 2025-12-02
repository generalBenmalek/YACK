import 'package:isar/isar.dart';

import 'contract.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;

  late int contractId;      // foreign key (local Isar contract ID)
  late String senderId;     // userA or userB
  late String text;
  late DateTime createdAt;
  
  // Firebase message key for deduplication (Chadli)
  @Index()
  String? firebaseKey;

  final contract = IsarLink<Contract>();
}

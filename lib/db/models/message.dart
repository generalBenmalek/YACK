import 'package:isar/isar.dart';

import 'contract.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;

  late int contractId;      // foreign key
  late String senderId;     // userA or userB
  late String text;
  late DateTime createdAt;

  final contract = IsarLink<Contract>();
}

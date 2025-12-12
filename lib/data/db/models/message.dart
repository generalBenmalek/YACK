import 'package:isar/isar.dart';

import 'contract.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;

  @Index()
  late int contractId;      // foreign key (local Isar contract ID)

  // External MongoDB message ID for deduplication
  @Index(unique: true, replace: true)
  String? externalId;

  late String senderId;     // userA or userB user ID
  String? senderFirstName;
  String? senderLastName;

  // Encrypted content for the current user (decrypted locally)
  late String content;

  // SHA hash of plaintext message for verification
  String? contentHash;

  late DateTime createdAt;

  final contract = IsarLink<Contract>();
}

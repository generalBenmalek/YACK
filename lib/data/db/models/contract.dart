import 'package:isar/isar.dart';

import 'message.dart';
import 'mediaFile.dart';

part 'contract.g.dart';

enum ContractStatus {
  pending,
  active,
  accepted,
  rejected,
  completed,
  disputed,
}

@collection
class Contract {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? externalId; // MongoDB ObjectId from backend

  // Encrypted fields for the current user (decrypted locally)
  late String title;
  late String description;
  late String price;

  // Hash for verification (SHA256 of plaintext title+description+price)
  String? detailsHash;

  // User A (creator)
  late String userAId;
  String? userAName;
  String? userAPublicKey;

  // User B (joiner)
  String? userBId;
  String? userBName;
  String? userBPublicKey;

  // Status tracking
  @enumerated
  late ContractStatus status;

  bool userAAccepted = false;
  bool userBAccepted = false;
  bool userASigned = false;
  bool userBSigned = false;

  // Dispute info
  String? disputeReason;
  String? disputedBy;

  // Timestamps
  late DateTime createdAt;
  DateTime? updatedAt;

  // Links
  final messages = IsarLinks<Message>();
  final media = IsarLinks<MediaFile>();
}


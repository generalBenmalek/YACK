import 'package:isar/isar.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/data/db/models/message.dart';
import 'package:yack/data/db/models/mediaFile.dart';
import 'package:yack/data/db/models/notification.dart';
import 'package:yack/logic/services/contract/contract_list_service.dart';
import 'package:yack/logic/services/message/message_service.dart';
import 'package:yack/logic/services/media/media_service.dart';
import 'package:yack/main.dart';

// ============================================================================
// Contract Operations
// ============================================================================

/// Save or update a contract in Isar from API response
Future<Contract> saveContractToIsar({
  required String externalId,
  required String title,
  required String description,
  required String price,
  required String userAId,
  String? userAName,
  String? userAPublicKey,
  String? userBId,
  String? userBName,
  String? userBPublicKey,
  String? detailsHash,
  String status = 'pending',
  bool userAAccepted = false,
  bool userBAccepted = false,
  bool userASigned = false,
  bool userBSigned = false,
  String? disputeReason,
  String? disputedBy,
}) async {
  final existing = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (existing != null) {
    await isar.writeTxn(() async {
      existing.title = title;
      existing.description = description;
      existing.price = price;
      existing.userAId = userAId;
      existing.userAName = userAName;
      existing.userAPublicKey = userAPublicKey;
      existing.userBId = userBId;
      existing.userBName = userBName;
      existing.userBPublicKey = userBPublicKey;
      existing.detailsHash = detailsHash;
      existing.status = _mapStringToStatus(status);
      existing.userAAccepted = userAAccepted;
      existing.userBAccepted = userBAccepted;
      existing.userASigned = userASigned;
      existing.userBSigned = userBSigned;
      existing.disputeReason = disputeReason;
      existing.disputedBy = disputedBy;
      existing.updatedAt = DateTime.now();
      await isar.contracts.put(existing);
    });
    return existing;
  } else {
    final contract = Contract()
      ..externalId = externalId
      ..title = title
      ..description = description
      ..price = price
      ..userAId = userAId
      ..userAName = userAName
      ..userAPublicKey = userAPublicKey
      ..userBId = userBId
      ..userBName = userBName
      ..userBPublicKey = userBPublicKey
      ..detailsHash = detailsHash
      ..status = _mapStringToStatus(status)
      ..userAAccepted = userAAccepted
      ..userBAccepted = userBAccepted
      ..userASigned = userASigned
      ..userBSigned = userBSigned
      ..disputeReason = disputeReason
      ..disputedBy = disputedBy
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.contracts.put(contract);
    });
    return contract;
  }
}

/// Save contract from ContractListItem API response
Future<Contract> saveContractFromListItem(ContractListItem item, {String? currentUserId}) async {
  // Determine userA and userB based on isUserA flag
  String userAId;
  String? userAName;
  String? userAPublicKey;
  String? userBId;
  String? userBName;
  String? userBPublicKey;

  if (item.isUserA) {
    // Current user is userA (creator)
    userAId = currentUserId ?? '';
    userAName = null; // Current user, no need to store name
    userBId = item.otherUserId;
    userBName = item.otherUserName;
    userBPublicKey = item.otherUserPublicKey;
  } else {
    // Current user is userB (joiner)
    userAId = item.otherUserId ?? '';
    userAName = item.otherUserName;
    userAPublicKey = item.otherUserPublicKey;
    userBId = currentUserId;
    userBName = null; // Current user, no need to store name
  }

  return saveContractToIsar(
    externalId: item.id,
    title: item.title,
    description: item.description,
    price: item.price,
    userAId: userAId,
    userAName: userAName,
    userAPublicKey: userAPublicKey,
    userBId: userBId,
    userBName: userBName,
    userBPublicKey: userBPublicKey,
    detailsHash: item.detailsHash,
    status: item.status,
    userAAccepted: item.agreedUserA,
    userBAccepted: item.agreedUserB,
    userASigned: item.userASigned,
    userBSigned: item.userBSigned,
    disputeReason: item.disputedUserA || item.disputedUserB ? 'Disputed' : null,
    disputedBy: item.disputedUserA ? userAId : (item.disputedUserB ? userBId : null),
  );
}

/// Sync all contracts from API to Isar
Future<void> syncContractsFromApi(List<ContractListItem> contracts, {String? currentUserId}) async {
  for (final item in contracts) {
    await saveContractFromListItem(item, currentUserId: currentUserId);
  }
}

/// Get all contracts from Isar
Future<List<Contract>> getAllContractsFromIsar() async {
  return await isar.contracts.where().findAll();
}

/// Get a contract by external ID
Future<Contract?> getContractByExternalId(String externalId) async {
  return await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();
}

// Helper function to map string status to ContractStatus enum
ContractStatus _mapStringToStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return ContractStatus.pending;
    case 'active':
      return ContractStatus.active;
    case 'accepted':
      return ContractStatus.accepted;
    case 'completed':
    case 'closed':
      return ContractStatus.completed;
    case 'rejected':
    case 'declined':
      return ContractStatus.rejected;
    case 'disputed':
    case 'on dispute':
    case 'dispatched':
      return ContractStatus.disputed;
    default:
      return ContractStatus.pending;
  }
}

/// Update contract status in Isar
Future<void> updateContractStatusInIsar(String externalId, String status) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      contract.status = _mapStringToStatus(status);
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });
  }
}

/// Update contract acceptance status
Future<void> updateContractAcceptance({
  required String externalId,
  bool? userAAccepted,
  bool? userBAccepted,
}) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      if (userAAccepted != null) contract.userAAccepted = userAAccepted;
      if (userBAccepted != null) contract.userBAccepted = userBAccepted;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });
  }
}

/// Update contract dispute status
Future<void> updateContractDispute({
  required String externalId,
  required String disputedBy,
  String? reason,
}) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      contract.status = ContractStatus.disputed;
      contract.disputedBy = disputedBy;
      contract.disputeReason = reason;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });
  }
}

/// Delete a contract from Isar
Future<void> deleteContractFromIsar(String externalId) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      await isar.contracts.delete(contract.id);
    });
  }
}

// ============================================================================
// Message Operations
// ============================================================================

/// Save a message to Isar
Future<Message> saveMessageToIsar({
  required int contractId,
  required String externalId,
  required String senderId,
  String? senderFirstName,
  String? senderLastName,
  required String content,
  String? contentHash,
  DateTime? createdAt,
}) async {
  // Check if message already exists by external ID
  final existingById = await isar.messages
      .filter()
      .externalIdEqualTo(externalId)
      .findFirst();

  if (existingById != null) {
    return existingById;
  }

  // Only check for local duplicates when receiving a server message
  // This handles the case where we save locally first, then sync from server
  // We match by: same contract, same sender, same contentHash, and is a local message
  if (!externalId.startsWith('local_') && contentHash != null && contentHash.isNotEmpty) {
    final localMessages = await isar.messages
        .filter()
        .contractIdEqualTo(contractId)
        .senderIdEqualTo(senderId)
        .contentHashEqualTo(contentHash)
        .findAll();

    // Find a local message to update (one with local_ prefix)
    final localMessage = localMessages.where((m) => m.externalId?.startsWith('local_') == true).firstOrNull;

    if (localMessage != null) {
      // Update the local message with the real server ID
      await isar.writeTxn(() async {
        localMessage.externalId = externalId;
        await isar.messages.put(localMessage);
      });
      return localMessage;
    }
  }

  final message = Message()
    ..contractId = contractId
    ..externalId = externalId
    ..senderId = senderId
    ..senderFirstName = senderFirstName
    ..senderLastName = senderLastName
    ..content = content
    ..contentHash = contentHash
    ..createdAt = createdAt ?? DateTime.now();

  await isar.writeTxn(() async {
    await isar.messages.put(message);
  });

  return message;
}

/// Save messages from API response
Future<void> saveMessagesFromApi(int contractId, List<ContractMessage> messages) async {
  for (final msg in messages) {
    await saveMessageToIsar(
      contractId: contractId,
      externalId: msg.id,
      senderId: msg.senderId,
      senderFirstName: msg.senderFirstName,
      senderLastName: msg.senderLastName,
      content: msg.content,
      contentHash: msg.contentHash,
      createdAt: msg.createdAt,
    );
  }
}

/// Get all messages for a contract from Isar
Future<List<Message>> getMessagesForContract(int contractId) async {
  return await isar.messages
      .filter()
      .contractIdEqualTo(contractId)
      .sortByCreatedAt()
      .findAll();
}

// ============================================================================
// Media Operations
// ============================================================================

/// Save a media file to Isar
Future<MediaFile> saveMediaToIsar({
  required int contractId,
  required String externalId,
  required String senderId,
  String? senderName,
  required String originalFilename,
  required String content,
  required String url,
  String? mimeType,
  DateTime? createdAt,
}) async {
  // Check if media already exists by external ID
  final allMedia = await isar.mediaFiles.where().findAll();
  final existing = allMedia.where((m) => m.externalId == externalId).firstOrNull;

  if (existing != null) {
    return existing;
  }

  final media = MediaFile()
    ..contractId = contractId
    ..externalId = externalId
    ..senderId = senderId
    ..senderName = senderName
    ..originalFilename = originalFilename
    ..content = content
    ..url = url
    ..mimeType = mimeType
    ..createdAt = createdAt ?? DateTime.now();

  await isar.writeTxn(() async {
    await isar.mediaFiles.put(media);
  });

  return media;
}

/// Save media files from API response
Future<void> saveMediaFromApi(int contractId, List<ContractMedia> mediaList) async {
  for (final m in mediaList) {
    await saveMediaToIsar(
      contractId: contractId,
      externalId: m.id,
      senderId: m.senderId,
      senderName: m.senderName,
      originalFilename: m.originalFilename,
      content: m.content,
      url: m.url,
      mimeType: m.mimeType,
      createdAt: m.createdAt,
    );
  }
}

/// Get all media for a contract from Isar
Future<List<MediaFile>> getMediaForContract(int contractId) async {
  return await isar.mediaFiles
      .filter()
      .contractIdEqualTo(contractId)
      .sortByCreatedAt()
      .findAll();
}

// ============================================================================
// Notification Operations
// ============================================================================

/// Save a notification to Isar
Future<AppNotification> saveNotificationToIsar(AppNotification notification) async {
  await isar.writeTxn(() async {
    await isar.appNotifications.put(notification);
  });
  return notification;
}

/// Get all notifications from Isar
Future<List<AppNotification>> getAllNotificationsFromIsar() async {
  return await isar.appNotifications.where().sortByCreatedAtDesc().findAll();
}

/// Get unread notifications count
Future<int> getUnreadNotificationsCount() async {
  return await isar.appNotifications.filter().isReadEqualTo(false).count();
}

/// Mark notification as read
Future<void> markNotificationAsRead(int id) async {
  final notification = await isar.appNotifications.get(id);
  if (notification != null) {
    await isar.writeTxn(() async {
      notification.isRead = true;
      await isar.appNotifications.put(notification);
    });
  }
}

/// Mark all notifications as read
Future<void> markAllNotificationsAsRead() async {
  final notifications = await isar.appNotifications.filter().isReadEqualTo(false).findAll();
  await isar.writeTxn(() async {
    for (final notification in notifications) {
      notification.isRead = true;
      await isar.appNotifications.put(notification);
    }
  });
}

/// Delete a notification
Future<void> deleteNotificationFromIsar(int id) async {
  await isar.writeTxn(() async {
    await isar.appNotifications.delete(id);
  });
}

/// Clear all notifications
Future<void> clearAllNotifications() async {
  await isar.writeTxn(() async {
    await isar.appNotifications.clear();
  });
}

/// Clear all Isar data (for logout)
Future<void> clearAllIsarData() async {
  await isar.writeTxn(() async {
    await isar.contracts.clear();
    await isar.messages.clear();
    await isar.mediaFiles.clear();
    await isar.appNotifications.clear();
  });
}


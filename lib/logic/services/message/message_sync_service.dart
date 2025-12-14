import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/logic/services/message/message_service.dart';

/// Service to sync messages from backend to local Isar database.
/// Messages are stored DECRYPTED in Isar for easy display.
class MessageSyncService {
  MessageSyncService({
    MessageService? messageService,
  }) : _messageService = messageService ?? MessageService();

  final MessageService _messageService;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  /// Whether a sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Sync all messages for a specific contract from backend to Isar.
  /// Uses the already-decrypted private key from Hive.
  /// All messages are stored DECRYPTED in Isar.
  ///
  /// Returns the number of messages synced.
  Future<int> syncMessagesForContract({
    required String externalContractId,
    required int localContractId,
    int? limit,
  }) async {
    if (_isSyncing) {
      print('[MessageSyncService] Sync already in progress, skipping...');
      return 0;
    }

    _isSyncing = true;

    try {
      print('[MessageSyncService] Starting message sync for contract $externalContractId...');

      // Get decrypted private key from Hive
      final userBox = await Hive.openBox('user');
      final privateKeyBytes = _getDecryptedPrivateKeyFromCache(userBox);

      if (privateKeyBytes == null) {
        print('[MessageSyncService] No decrypted private key found. User must unlock account first.');
        _isSyncing = false;
        return 0;
      }

      // Fetch messages from backend
      final messages = await _messageService.getAll(
        contractId: externalContractId,
        limit: limit,
      );
      print('[MessageSyncService] Fetched ${messages.length} messages from backend');

      if (messages.isEmpty) {
        _lastSyncTime = DateTime.now();
        _isSyncing = false;
        return 0;
      }

      // Process each message - decrypt and store
      int syncedCount = 0;
      for (final msg in messages) {
        try {
          // Decrypt message content using private key
          String decryptedContent;
          try {
            decryptedContent = CryptoService.decryptWithPrivateKey(
              ciphertextBase64: msg.content,
              privateKeyBytes: privateKeyBytes,
            );
          } catch (e) {
            decryptedContent = '[Unable to decrypt message]';
            print('[MessageSyncService] Failed to decrypt message ${msg.id}: $e');
          }

          // Save decrypted message to Isar
          await saveMessageToIsar(
            contractId: localContractId,
            externalId: msg.id,
            senderId: msg.senderId,
            senderFirstName: msg.senderFirstName,
            senderLastName: msg.senderLastName,
            content: decryptedContent,
            contentHash: msg.contentHash,
            createdAt: msg.createdAt,
          );
          syncedCount++;

        } catch (e) {
          print('[MessageSyncService] Failed to sync message ${msg.id}: $e');
        }
      }

      _lastSyncTime = DateTime.now();
      print('[MessageSyncService] Sync complete. Synced $syncedCount messages.');

      return syncedCount;

    } catch (e) {
      print('[MessageSyncService] Sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync messages for all contracts
  Future<int> syncAllMessages() async {
    try {
      final contracts = await getAllContractsFromIsar();
      int totalSynced = 0;

      for (final contract in contracts) {
        if (contract.externalId != null) {
          final count = await syncMessagesForContract(
            externalContractId: contract.externalId!,
            localContractId: contract.id,
          );
          totalSynced += count;
        }
      }

      return totalSynced;
    } catch (e) {
      print('[MessageSyncService] Failed to sync all messages: $e');
      rethrow;
    }
  }

  /// Get the already-decrypted private key from Hive cache
  Uint8List? _getDecryptedPrivateKeyFromCache(Box userBox) {
    try {
      final cachedKey = userBox.get('decryptedPrivateKey');
      if (cachedKey == null) return null;

      if (cachedKey is Uint8List) {
        return cachedKey;
      } else if (cachedKey is List) {
        return Uint8List.fromList(cachedKey.cast<int>());
      }
      return null;
    } catch (e) {
      print('[MessageSyncService] Failed to get cached private key: $e');
      return null;
    }
  }
}


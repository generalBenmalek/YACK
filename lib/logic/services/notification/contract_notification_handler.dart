import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yack/data/repositories/isar_adapter.dart';

/// Events emitted by ContractNotificationHandler for UI to react
enum ContractNotificationType {
  contractJoin,
  contractSign,
  contractAccept,
  contractDispute,
  contractMessage,
  contractMedia,
}

/// Data payload for contract notifications
class ContractNotificationEvent {
  final ContractNotificationType type;
  final String? tempId;
  final String? contractId;
  final String? userId;
  final String? username;
  final String? reason;
  final String? mediaPath;
  final Map<String, dynamic> rawData;

  const ContractNotificationEvent({
    required this.type,
    this.tempId,
    this.contractId,
    this.userId,
    this.username,
    this.reason,
    this.mediaPath,
    required this.rawData,
  });

  factory ContractNotificationEvent.fromFcmData(Map<String, dynamic> data) {
    final typeStr = data['type']?.toString() ?? '';
    ContractNotificationType type;

    switch (typeStr) {
      case 'contractJoin':
        type = ContractNotificationType.contractJoin;
        break;
      case 'contractSign':
        type = ContractNotificationType.contractSign;
        break;
      case 'contractAccept':
        type = ContractNotificationType.contractAccept;
        break;
      case 'contractDispute':
        type = ContractNotificationType.contractDispute;
        break;
      case 'contractMessage':
        type = ContractNotificationType.contractMessage;
        break;
      case 'contractMedia':
        type = ContractNotificationType.contractMedia;
        break;
      default:
        type = ContractNotificationType.contractMessage;
    }

    return ContractNotificationEvent(
      type: type,
      tempId: data['tempId']?.toString(),
      contractId: data['contractId']?.toString(),
      userId: data['userId']?.toString(),
      username: data['username']?.toString(),
      reason: data['reason']?.toString(),
      mediaPath: data['mediaPath']?.toString(),
      rawData: data,
    );
  }
}

/// Centralized handler for contract-related Firebase notifications.
/// Provides a stream of events that screens can listen to.
class ContractNotificationHandler {
  static final ContractNotificationHandler _instance =
      ContractNotificationHandler._internal();
  factory ContractNotificationHandler() => _instance;
  ContractNotificationHandler._internal();

  final _eventController = StreamController<ContractNotificationEvent>.broadcast();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;

  /// Stream of contract notification events
  Stream<ContractNotificationEvent> get events => _eventController.stream;

  /// Stream filtered by tempId (for screens waiting on a specific contract)
  Stream<ContractNotificationEvent> eventsForTempContract(String tempId) {
    return _eventController.stream.where((e) => e.tempId == tempId);
  }

  /// Stream filtered by contractId
  Stream<ContractNotificationEvent> eventsForContract(String contractId) {
    return _eventController.stream.where((e) => e.contractId == contractId);
  }

  /// Initialize the handler and start listening
  void initialize() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();

    // Listen to foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);

    // Listen to background message taps
    _backgroundSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// Process incoming FCM message
  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return;

    print('[DEBUG ContractNotificationHandler] Received FCM message: $data');

    final typeStr = data['type']?.toString() ?? '';
    if (!_isContractNotification(typeStr)) {
      print('[DEBUG ContractNotificationHandler] Not a contract notification: $typeStr');
      return;
    }

    final event = ContractNotificationEvent.fromFcmData(data);
    print('[DEBUG ContractNotificationHandler] Emitting event: ${event.type}, tempId: ${event.tempId}, contractId: ${event.contractId}');
    _eventController.add(event);

    // Handle side effects based on notification type
    _handleSideEffects(event);
  }

  bool _isContractNotification(String type) {
    return [
      'contractJoin',
      'contractSign',
      'contractAccept',
      'contractDispute',
      'contractMessage',
      'contractMedia',
    ].contains(type);
  }

  /// Handle side effects like updating Isar when contract is signed
  Future<void> _handleSideEffects(ContractNotificationEvent event) async {
    switch (event.type) {
      case ContractNotificationType.contractSign:
        // When we get a contractSign notification, the other user signed
        // If contract is fully signed, the contractId will be provided
        if (event.contractId != null) {
          // Update contract status in Isar if it exists
          try {
            await updateContractStatusInIsar(event.contractId!, 'active');
          } catch (_) {}
        }
        break;

      case ContractNotificationType.contractAccept:
        if (event.contractId != null) {
          try {
            await updateContractStatusInIsar(event.contractId!, 'accepted');
          } catch (_) {}
        }
        break;

      case ContractNotificationType.contractDispute:
        if (event.contractId != null) {
          try {
            await updateContractStatusInIsar(event.contractId!, 'disputed');
          } catch (_) {}
        }
        break;

      default:
        break;
    }
  }

  /// Manually emit an event (for testing or local triggering)
  void emitEvent(ContractNotificationEvent event) {
    _eventController.add(event);
  }

  /// Clean up resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
    _eventController.close();
  }
}


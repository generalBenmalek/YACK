import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/message/message_service.dart';
import 'package:yack/logic/services/message/message_sync_service.dart';

import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit({
    MessageService? service,
    MessageSyncService? syncService,
  })  : _service = service ?? MessageService(),
        _syncService = syncService ?? MessageSyncService(),
        super(const MessageInitial());

  final MessageService _service;
  final MessageSyncService _syncService;
  String? _currentContractId;
  int? _currentLocalContractId;

  /// Load messages for a contract from API (encrypted)
  Future<void> loadMessages({
    required String contractId,
    int? limit,
  }) async {
    _currentContractId = contractId;
    emit(const MessageLoading());
    try {
      final messages = await _service.getAll(
        contractId: contractId,
        limit: limit,
      );
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  /// Sync messages for a contract from backend to Isar (decrypted)
  Future<void> syncMessages({
    required String externalContractId,
    required int localContractId,
    int? limit,
  }) async {
    _currentContractId = externalContractId;
    _currentLocalContractId = localContractId;
    emit(const MessageLoading());
    try {
      await _syncService.syncMessagesForContract(
        externalContractId: externalContractId,
        localContractId: localContractId,
        limit: limit,
      );
      emit(const MessageSynced());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  /// Sync messages for all contracts
  Future<void> syncAllMessages() async {
    emit(const MessageLoading());
    try {
      await _syncService.syncAllMessages();
      emit(const MessageSynced());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  /// Send an encrypted message to a contract
  Future<void> sendMessage({
    required String contractId,
    required String contentForSender,
    required String contentForRecipient,
    required String contentHash,
  }) async {
    emit(const MessageLoading());
    try {
      await _service.send(
        contractId: contractId,
        contentForSender: contentForSender,
        contentForRecipient: contentForRecipient,
        contentHash: contentHash,
      );
      emit(const MessageSent());

      // Optionally sync messages after sending if we have local contract ID
      if (_currentContractId == contractId && _currentLocalContractId != null) {
        await syncMessages(
          externalContractId: contractId,
          localContractId: _currentLocalContractId!,
        );
      }
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  /// Refresh messages for the current contract
  Future<void> refresh() async {
    if (_currentContractId != null && _currentLocalContractId != null) {
      await syncMessages(
        externalContractId: _currentContractId!,
        localContractId: _currentLocalContractId!,
      );
    } else if (_currentContractId != null) {
      await loadMessages(contractId: _currentContractId!);
    }
  }
}


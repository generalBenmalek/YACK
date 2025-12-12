import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/message/message_service.dart';

import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit({MessageService? service})
      : _service = service ?? MessageService(),
        super(const MessageInitial());

  final MessageService _service;
  String? _currentContractId;

  /// Load messages for a contract
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

      // Optionally reload messages after sending
      if (_currentContractId == contractId) {
        await loadMessages(contractId: contractId);
      }
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  /// Refresh messages for the current contract
  Future<void> refresh() async {
    if (_currentContractId != null) {
      await loadMessages(contractId: _currentContractId!);
    }
  }
}


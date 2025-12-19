import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/logic/services/contract/contract_list_service.dart';
import 'package:yack/logic/services/contract/contract_state_service.dart';
import 'package:yack/logic/services/contract/contract_verification_service.dart';
import 'package:yack/logic/services/contract/temp_contract_service.dart';
import 'package:yack/logic/services/message/message_service.dart';
import 'package:yack/logic/services/media/media_service.dart';
import 'package:yack/logic/services/network/http_handler.dart';
import 'dart:io';

/// Unified contract handler that coordinates all contract-related operations
/// and syncs data between the API and local Isar database.
class ContractHandler {
  ContractHandler({HttpHandler? httpHandler})
      : _tempContractService = TempContractService(httpHandler: httpHandler),
        _contractListService = ContractListService(httpHandler: httpHandler),
        _contractStateService = ContractStateService(httpHandler: httpHandler),
        _contractVerificationService = ContractVerificationService(httpHandler: httpHandler),
        _messageService = MessageService(httpHandler: httpHandler),
        _mediaService = MediaService(httpHandler: httpHandler);

  final TempContractService _tempContractService;
  final ContractListService _contractListService;
  final ContractStateService _contractStateService;
  final ContractVerificationService _contractVerificationService;
  final MessageService _messageService;
  final MediaService _mediaService;

  // ============================================================================
  // Temp Contract Operations
  // ============================================================================

  /// Create a new temporary contract
  Future<TempContractCreateResult> createContract({
    String? hash,
    required String titleUserA,
    required String descriptionUserA,
    required String priceUserA,
    required String detailsHash,
  }) async {
    final contract = await _tempContractService.create(
      hash: hash,
      titleUserA: titleUserA,
      descriptionUserA: descriptionUserA,
      priceUserA: priceUserA,
      detailsHash: detailsHash,
    );
    return TempContractCreateResult(tempId: contract.tempId);
  }

  /// Join a temporary contract as user B
  Future<TempContractJoinResult> joinContract({
    required String tempId,
    String? hash,
    required String titleUserB,
    required String descriptionUserB,
    required String priceUserB,
  }) async {
    return await _tempContractService.join(
      tempId: tempId,
      hash: hash,
      titleUserB: titleUserB,
      descriptionUserB: descriptionUserB,
      priceUserB: priceUserB,
    );
  }

  /// Sign a temporary contract
  Future<TempContractSignResult> signContract(String tempId) async {
    return await _tempContractService.sign(tempId);
  }

  // ============================================================================
  // Contract List Operations
  // ============================================================================

  /// Fetch all contracts from API and sync to Isar
  Future<List<Contract>> fetchAndSyncContracts() async {
    final apiContracts = await _contractListService.list();
    await syncContractsFromApi(apiContracts);
    return await getAllContractsFromIsar();
  }

  /// Get all contracts from local Isar database
  Future<List<Contract>> getLocalContracts() async {
    return await getAllContractsFromIsar();
  }

  // ============================================================================
  // Contract State Operations
  // ============================================================================

  /// Accept a contract and update local state
  Future<void> acceptContract(String contractId) async {
    await _contractStateService.accept(contractId);
    // Update local state after successful API call
    // The specific user acceptance will be determined by the backend
    await updateContractStatusInIsar(contractId, 'accepted');
  }

  /// Dispute a contract and update local state
  Future<void> disputeContract(String contractId, {String? reason}) async {
    await _contractStateService.dispute(contractId, reason: reason);
    await updateContractStatusInIsar(contractId, 'disputed');
  }

  // ============================================================================
  // Contract Verification
  // ============================================================================

  /// Verify contract hash
  Future<bool> verifyContractHash({
    required String contractId,
    required String hash,
  }) async {
    return await _contractVerificationService.verifyHash(
      contractId: contractId,
      hash: hash,
    );
  }

  // ============================================================================
  // Message Operations
  // ============================================================================

  /// Send a message to a contract
  Future<void> sendMessage({
    required String contractId,
    required String contentForSender,
    required String contentForRecipient,
    required String contentHash,
  }) async {
    await _messageService.send(
      contractId: contractId,
      contentForSender: contentForSender,
      contentForRecipient: contentForRecipient,
      contentHash: contentHash,
    );
  }

  /// Fetch messages for a contract and sync to Isar
  Future<List<ContractMessage>> fetchMessages({
    required String contractId,
    required int localContractId,
    int? limit,
  }) async {
    final messages = await _messageService.getAll(
      contractId: contractId,
      limit: limit,
    );
    await saveMessagesFromApi(localContractId, messages);
    return messages;
  }

  // ============================================================================
  // Media Operations
  // ============================================================================

  /// Upload media to a contract
  Future<ContractMedia> uploadMedia({
    required String contractId,
    required File file,
    String? filename,
  }) async {
    return await _mediaService.send(
      contractId: contractId,
      file: file,
      filename: filename,
    );
  }

  /// Fetch media for a contract and sync to Isar
  Future<List<ContractMedia>> fetchMedia({
    required String contractId,
    required int localContractId,
  }) async {
    final mediaList = await _mediaService.getAll(contractId: contractId);
    await saveMediaFromApi(localContractId, mediaList);
    return mediaList;
  }
}

/// Result of creating a temp contract
class TempContractCreateResult {
  final String tempId;

  const TempContractCreateResult({required this.tempId});
}


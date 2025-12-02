import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/db/models/notification.dart';
import 'package:yack/main.dart';
import 'package:yack/db/online.dart' as online_db;
import 'package:firebase_auth/firebase_auth.dart';

abstract class ContractState {}

class ContractLoading extends ContractState {}

class ContractLoaded extends ContractState {
  final Contract contract;
  ContractLoaded(this.contract);
}

class ContractError extends ContractState {
  final String message;
  ContractError(this.message);
}

// Cubit for contract state management (Chadli)
class ContractCubit extends Cubit<ContractState> {
  final int contractId;
  String? _cachedUserId;

  ContractCubit(this.contractId) : super(ContractLoading());

  // Get userId - prefer Firebase Auth, fallback to contract's userB (Chadli)
  Future<String> _getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;
    
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid != null && firebaseUid.isNotEmpty) {
      _cachedUserId = firebaseUid;
      return firebaseUid;
    }
    
    final contract = await isar.contracts.get(contractId);
    if (contract != null) {
      _cachedUserId = contract.userB.isNotEmpty ? contract.userB : contract.userA;
      return _cachedUserId!;
    }
    
    _cachedUserId = 'unknown_user';
    return _cachedUserId!;
  }

  // Load contract from Isar (Chadli)
  Future<void> loadContract() async {
    try {
      final contract = await isar.contracts.get(contractId);
      if (contract != null) {
        emit(ContractLoaded(contract));
      } else {
        emit(ContractError('Contract not found'));
      }
    } catch (e) {
      emit(ContractError('Failed to load contract: $e'));
    }
  }

  // Accept a pending contract (Chadli)
  Future<void> acceptContract() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.pending) return;

    await isar.writeTxn(() async {
      contract.status = ContractStatus.accepted;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      final notification = AppNotification()
        ..title = 'Contract Accepted'
        ..description = 'You have accepted the contract.'
        ..createdAt = DateTime.now()
        ..isRead = true
        ..contractId = contract.id;
      await isar.appNotifications.put(notification);
    });

    emit(ContractLoaded(contract));
  }

  // Reject a pending contract (Chadli)
  Future<void> rejectContract() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.pending) return;

    await isar.writeTxn(() async {
      contract.status = ContractStatus.rejected;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      final notification = AppNotification()
        ..title = 'Contract Rejected'
        ..description = 'You have rejected the contract.'
        ..createdAt = DateTime.now()
        ..isRead = true
        ..contractId = contract.id;
      await isar.appNotifications.put(notification);
    });

    emit(ContractLoaded(contract));
  }

  // Request contract completion - requires other party confirmation (Chadli)
  Future<void> completeContract() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.accepted) return;

    final userId = await _getUserId();

    if (contract.externalId != null && contract.externalId!.isNotEmpty) {
      try {
        final result = await online_db.closeContract(contract.externalId!, userId);
        
        // First party request - wait for confirmation (Chadli)
        if (result['message'] == 'Close request sent, waiting for confirmation') {
          await isar.writeTxn(() async {
            final notification = AppNotification()
              ..title = 'Completion Requested'
              ..description = 'Waiting for the other party to confirm completion.'
              ..createdAt = DateTime.now()
              ..isRead = false
              ..contractId = contract.id;
            await isar.appNotifications.put(notification);
          });
          return;
        }
      } catch (_) {}
    }

    // Complete locally (Chadli)
    await isar.writeTxn(() async {
      contract.status = ContractStatus.completed;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      final notification = AppNotification()
        ..title = 'Contract Completed'
        ..description = 'The contract has been successfully completed.'
        ..createdAt = DateTime.now()
        ..isRead = false
        ..contractId = contract.id;
      await isar.appNotifications.put(notification);
    });

    emit(ContractLoaded(contract));
  }

  // Raise a dispute on the contract (Chadli)
  Future<void> disputeContract() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;

    final userId = await _getUserId();

    if (contract.externalId != null && contract.externalId!.isNotEmpty) {
      try {
        await online_db.disputeContract(contract.externalId!, userId);
      } catch (_) {}
    }

    await isar.writeTxn(() async {
      contract.status = ContractStatus.onDispute;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      final notification = AppNotification()
        ..title = 'Contract Disputed'
        ..description = 'You have disputed this contract.'
        ..createdAt = DateTime.now()
        ..isRead = true
        ..contractId = contract.id;
      await isar.appNotifications.put(notification);
    });

    emit(ContractLoaded(contract));
  }

  // Simulate other party accepting - for testing (Chadli)
  Future<void> simulateOtherPartyAccept() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.pending) return;

    await isar.writeTxn(() async {
      contract.status = ContractStatus.accepted;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      await isar.appNotifications.put(
        AppNotification()
          ..title = 'Contract Accepted'
          ..description = 'The other party has accepted the contract.'
          ..createdAt = DateTime.now()
          ..isRead = false
          ..contractId = contractId,
      );
    });

    emit(ContractLoaded(contract));
  }

  // Simulate other party rejecting - for testing (Chadli)
  Future<void> simulateOtherPartyReject() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.pending) return;

    await isar.writeTxn(() async {
      contract.status = ContractStatus.rejected;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      await isar.appNotifications.put(
        AppNotification()
          ..title = 'Contract Rejected'
          ..description = 'The other party has rejected the contract.'
          ..createdAt = DateTime.now()
          ..isRead = false
          ..contractId = contractId,
      );
    });

    emit(ContractLoaded(contract));
  }

  // Simulate other party completing - for testing (Chadli)
  Future<void> simulateOtherPartyComplete() async {
    if (state is! ContractLoaded) return;
    final contract = (state as ContractLoaded).contract;
    if (contract.status != ContractStatus.accepted) return;

    await isar.writeTxn(() async {
      contract.status = ContractStatus.completed;
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });

    await isar.writeTxn(() async {
      await isar.appNotifications.put(
        AppNotification()
          ..title = 'Contract Completed'
          ..description = 'The other party has marked the job as complete.'
          ..createdAt = DateTime.now()
          ..isRead = false
          ..contractId = contractId,
      );
    });

    emit(ContractLoaded(contract));
  }
}

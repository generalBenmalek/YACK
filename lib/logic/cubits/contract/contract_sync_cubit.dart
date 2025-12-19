import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yack/logic/services/contract/contract_sync_service.dart';

// States
abstract class ContractSyncState extends Equatable {
  const ContractSyncState();

  @override
  List<Object?> get props => [];
}

class ContractSyncInitial extends ContractSyncState {
  const ContractSyncInitial();
}

class ContractSyncLoading extends ContractSyncState {
  const ContractSyncLoading();
}

class ContractSyncSuccess extends ContractSyncState {
  final int syncedCount;
  final DateTime syncTime;

  const ContractSyncSuccess({
    required this.syncedCount,
    required this.syncTime,
  });

  @override
  List<Object?> get props => [syncedCount, syncTime];
}

class ContractSyncError extends ContractSyncState {
  final String message;

  const ContractSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ContractSyncCubit extends Cubit<ContractSyncState> {
  ContractSyncCubit({ContractSyncService? service})
      : _service = service ?? ContractSyncService(),
        super(const ContractSyncInitial());

  final ContractSyncService _service;

  /// Sync contracts using the already-decrypted private key from Hive
  /// (set during account unlock)
  Future<void> sync() async {
    emit(const ContractSyncLoading());
    try {
      final count = await _service.syncContracts();
      emit(ContractSyncSuccess(
        syncedCount: count,
        syncTime: DateTime.now(),
      ));
    } catch (e) {
      emit(ContractSyncError(e.toString()));
    }
  }

  /// Check if sync is in progress
  bool get isSyncing => _service.isSyncing;

  /// Get last sync time
  DateTime? get lastSyncTime => _service.lastSyncTime;
}


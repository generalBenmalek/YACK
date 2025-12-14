import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:yack/logic/services/auth/auth_service.dart';
import 'package:yack/logic/services/contract/contract_sync_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final ContractSyncService _syncService = ContractSyncService();

  Future<void> checkAuth() async {
    emit(AuthChecking());

    // 1) Fast local read for quick app startup
    try {
      final localStatus = await AuthService.readLastAuthStatus();
      if (localStatus == true) {
        emit(Authenticated());
      } else if (localStatus == null) {
        emit(UnverifiedUser());
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      // If local read fails for any reason, just continue to online check
    }

    // 2) Online check to refresh real status when internet is available
    try {
      final isLoggedIn = await AuthService.isAuthenticated();

      if (isLoggedIn == true) {
        emit(Authenticated());
        // Sync contracts in background when authenticated
        _syncContractsInBackground();
      } else if (isLoggedIn == null) {
        // logged in but email not verified
        emit(UnverifiedUser());
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      // If online check fails (e.g. no internet), emit error
      emit(AuthError(e.toString()));

      // Schedule a retry after some delay (e.g. 5 seconds)
      Future.delayed(const Duration(seconds: 5), () {
        // Only retry if we are still in an error state to avoid
        // interfering with manual navigation changes
        if (state is AuthError) {
          checkOnlineAuth();
        }
      });
    }
  }

  /// Sync contracts in background (non-blocking)
  void _syncContractsInBackground() {
    // Run in background, don't await
    _syncService.syncContracts().then((count) {
      print('[AuthCubit] Synced $count contracts in background');
    }).catchError((e) {
      print('[AuthCubit] Background contract sync failed: $e');
    });
  }

  Future<void> checkOnlineAuth() async {
    try {
      final isLoggedIn = await AuthService.isAuthenticated();

      if (isLoggedIn == true) {
        emit(Authenticated());
        // Sync contracts in background
        _syncContractsInBackground();
      } else if (isLoggedIn == null) {
        // logged in but email not verified
        emit(UnverifiedUser());
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {}
  }

  void markAuthenticated() {
    emit(Authenticated());
    // Sync contracts when marked authenticated
    _syncContractsInBackground();
   }

  void markUnauthenticated() {
    emit(Unauthenticated());
  }
}

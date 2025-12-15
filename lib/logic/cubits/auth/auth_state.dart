import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class UnverifiedUser extends AuthState {}

class UncompletedUser extends AuthState {}

// New: user is authenticated, but account setup not complete (no keys etc.)
class AccountNotComplete extends AuthState {}

// New: user is authenticated, account complete, but no decryptedPrivateKey cached
class AccountCompleteButLocked extends AuthState {}

class AuthError extends AuthState {
  final String messageKey;
  AuthError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

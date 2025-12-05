import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial screen state
class PasswordResetInitial extends PasswordResetState {}

// Loading state (button spinner)
class PasswordResetLoading extends PasswordResetState {}

// Success (reset email sent)
class PasswordResetSuccess extends PasswordResetState {}

// Error (service threw a translation key)
class PasswordResetError extends PasswordResetState {
  final String messageKey; // translation key only

  PasswordResetError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

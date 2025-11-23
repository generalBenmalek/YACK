import 'package:equatable/equatable.dart';

abstract class SignupState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state when screen is first opened
class SignupInitial extends SignupState {}

// Loading while Firebase Auth is happening
class SignupLoading extends SignupState {}

// When login succeeds
class SignupSuccess extends SignupState {}

// When login fails
class SignupError extends SignupState {
  final String? message;

  SignupError([this.message]);

  @override
  List<Object?> get props => [message];
}

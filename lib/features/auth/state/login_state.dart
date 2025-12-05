import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state when screen is first opened
class LoginInitial extends LoginState {}

// Loading while Firebase Auth is happening
class LoginLoading extends LoginState {}

// When login succeeds
class LoginSuccess extends LoginState {}

// When login fails
class LoginError extends LoginState {
  final String? message;

  LoginError([this.message]);

  @override
  List<Object?> get props => [message];
}

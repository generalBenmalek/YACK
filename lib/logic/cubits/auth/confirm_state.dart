import 'package:equatable/equatable.dart';

abstract class ConfirmState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state when screen is first opened
class ConfirmInitial extends ConfirmState {}

// Loading while Firebase Auth is happening
class ConfirmLoading extends ConfirmState {}

// When Confirm succeeds
class ConfirmSuccess extends ConfirmState {}

// When not confirmed
class ConfirmUnverified extends ConfirmState {}

// When Confirm fails
class ConfirmError extends ConfirmState {
  final String? message;

  ConfirmError([this.message]);

  @override
  List<Object?> get props => [message];
}

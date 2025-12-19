import 'package:equatable/equatable.dart';
import 'package:yack/logic/services/user/user_service.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserProfileLoaded extends UserState {
  const UserProfileLoaded(this.profile);
  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class UserFinalizeSuccess extends UserState {
  const UserFinalizeSuccess();
}

class UserUpdateSuccess extends UserState {
  const UserUpdateSuccess();
}

class UserError extends UserState {
  const UserError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class UserDecryptSuccess extends UserState {
  const UserDecryptSuccess();
}

class UserDecryptError extends UserState {
  const UserDecryptError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

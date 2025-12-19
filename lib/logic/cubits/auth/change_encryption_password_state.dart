abstract class ChangeEncryptionPasswordState {}

class ChangeEncryptionPasswordInitial extends ChangeEncryptionPasswordState {}

class ChangeEncryptionPasswordLoading extends ChangeEncryptionPasswordState {}

class ChangeEncryptionPasswordSuccess extends ChangeEncryptionPasswordState {}

class ChangeEncryptionPasswordError extends ChangeEncryptionPasswordState {
  final String messageKey;
  ChangeEncryptionPasswordError(this.messageKey);
}


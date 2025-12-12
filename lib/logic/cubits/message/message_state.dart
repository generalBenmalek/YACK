import 'package:equatable/equatable.dart';
import 'package:yack/logic/services/message/message_service.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {
  const MessageInitial();
}

class MessageLoading extends MessageState {
  const MessageLoading();
}

class MessagesLoaded extends MessageState {
  const MessagesLoaded(this.messages);
  final List<ContractMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends MessageState {
  const MessageSent();
}

class MessageError extends MessageState {
  const MessageError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}


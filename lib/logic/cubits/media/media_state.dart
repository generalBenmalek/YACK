import 'package:equatable/equatable.dart';
import 'package:yack/logic/services/media/media_service.dart';

abstract class MediaState extends Equatable {
  const MediaState();

  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {
  const MediaInitial();
}

class MediaLoading extends MediaState {
  const MediaLoading();
}

class MediaListLoaded extends MediaState {
  const MediaListLoaded(this.mediaList);
  final List<ContractMedia> mediaList;

  @override
  List<Object?> get props => [mediaList];
}

class MediaLoaded extends MediaState {
  const MediaLoaded(this.media);
  final ContractMedia media;

  @override
  List<Object?> get props => [media];
}

class MediaUploaded extends MediaState {
  const MediaUploaded(this.media);
  final ContractMedia media;

  @override
  List<Object?> get props => [media];
}

class MediaError extends MediaState {
  const MediaError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

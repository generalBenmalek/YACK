import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/media/media_service.dart';

import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  MediaCubit({MediaService? service})
      : _service = service ?? MediaService(),
        super(const MediaInitial());

  final MediaService _service;
  String? _currentContractId;

  /// Load all media for a contract
  Future<void> loadMedia({required String contractId}) async {
    _currentContractId = contractId;
    emit(const MediaLoading());
    try {
      final mediaList = await _service.getAll(contractId: contractId);
      emit(MediaListLoaded(mediaList));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  /// Get a specific media by ID
  Future<void> getMedia({
    required String contractId,
    required String mediaId,
  }) async {
    emit(const MediaLoading());
    try {
      final media = await _service.get(
        contractId: contractId,
        mediaId: mediaId,
      );
      emit(MediaLoaded(media));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  /// Upload a media file to a contract
  Future<void> uploadMedia({
    required String contractId,
    required File file,
    String? filename,
  }) async {
    emit(const MediaLoading());
    try {
      final media = await _service.send(
        contractId: contractId,
        file: file,
        filename: filename,
      );
      emit(MediaUploaded(media));

      // Optionally reload media list after upload
      if (_currentContractId == contractId) {
        await loadMedia(contractId: contractId);
      }
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  /// Refresh media for the current contract
  Future<void> refresh() async {
    if (_currentContractId != null) {
      await loadMedia(contractId: _currentContractId!);
    }
  }
}

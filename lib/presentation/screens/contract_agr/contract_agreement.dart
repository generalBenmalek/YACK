import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/data/db/models/message.dart';
import 'package:yack/data/db/models/mediaFile.dart';
import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:yack/logic/cubits/contract/contract_state_cubit.dart';
import 'package:yack/logic/cubits/contract/contract_state_state.dart';
import 'package:yack/logic/cubits/message/message_cubit.dart';
import 'package:yack/logic/cubits/message/message_state.dart';
import 'package:yack/logic/cubits/media/media_cubit.dart';
import 'package:yack/logic/cubits/media/media_state.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/logic/services/contract/contract_sync_service.dart';
import 'package:yack/logic/services/notification/contract_notification_handler.dart';
import 'package:yack/logic/services/notification/notification_service.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/main.dart';

class ContractAgreement extends StatefulWidget {
  final int contractId;
  const ContractAgreement({super.key, required this.contractId});

  @override
  State<ContractAgreement> createState() => _ContractAgreementState();
}

class _ContractAgreementState extends State<ContractAgreement> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  String _currentUserId = '';
  String? _externalContractId;
  Uint8List? _privateKeyBytes;
  String? _otherUserPublicKey;

  StreamSubscription<ContractNotificationEvent>? _notificationSubscription;
  bool _isLoading = true;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadContractAndKeys();
    _subscribeToNotifications();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  /// Load contract from Isar and user keys from Hive
  Future<void> _loadContractAndKeys() async {
    try {
      // Load contract from Isar
      final contract = await isar.contracts.get(widget.contractId);
      if (contract == null) {
        setState(() => _isLoading = false);
        return;
      }

      _externalContractId = contract.externalId;

      // Get current user ID from Hive
      final userBox = await Hive.openBox('user');
      _currentUserId = userBox.get('userId')?.toString() ?? '';

      // Get decrypted private key from Hive (set during account unlock)
      final cachedKey = userBox.get('decryptedPrivateKey');
      if (cachedKey != null) {
        if (cachedKey is Uint8List) {
          _privateKeyBytes = cachedKey;
        } else if (cachedKey is List) {
          _privateKeyBytes = Uint8List.fromList(cachedKey.cast<int>());
        }
      }

      // Determine other user's public key
      final isUserA = contract.userAId == _currentUserId;
      _otherUserPublicKey = isUserA
          ? contract.userBPublicKey
          : contract.userAPublicKey;

      // Sync messages from backend
      await _syncMessages();

      setState(() => _isLoading = false);
    } catch (e) {
      print('[ContractAgreement] Error loading contract: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Subscribe to FCM notifications for real-time updates
  void _subscribeToNotifications() {
    final handler = NotificationService().contractHandler;

    _notificationSubscription = handler.events.listen((event) async {
      // Only process events for this contract
      if (_externalContractId == null) return;
      if (event.contractId != _externalContractId) return;

      print('[ContractAgreement] Received notification: ${event.type}, userId: ${event.userId}');

      switch (event.type) {
        case ContractNotificationType.contractAccept:
          SnackBarHandler.showSuccess(
            context,
            TranslationHandler.get('notification_other_accepted')
                .replaceAll('{name}', event.username ?? 'User'),
          );
          // Sync is handled by notification handler - UI will update via StreamBuilder
          break;

        case ContractNotificationType.contractDispute:
          SnackBarHandler.showError(
            context,
            TranslationHandler.get('notification_contract_disputed')
                .replaceAll('{name}', event.username ?? 'User'),
          );
          // Sync is handled by notification handler - UI will update via StreamBuilder
          break;

        case ContractNotificationType.contractMessage:
          // Sync messages from backend
          await _syncMessages();
          break;

        case ContractNotificationType.contractMedia:
          // Sync media from backend
          await _syncMedia();
          break;

        default:
          break;
      }
    });
  }


  /// Sync messages from backend and decrypt them
  Future<void> _syncMessages() async {
    if (_externalContractId == null || _privateKeyBytes == null) return;

    try {
      final messageCubit = context.read<MessageCubit>();
      await messageCubit.loadMessages(contractId: _externalContractId!);

      final state = messageCubit.state;
      if (state is MessagesLoaded) {
        // Decrypt and save messages to Isar
        for (final msg in state.messages) {
          String decryptedContent;
          try {
            decryptedContent = CryptoService.decryptWithPrivateKey(
              ciphertextBase64: msg.content,
              privateKeyBytes: _privateKeyBytes!,
            );
          } catch (e) {
            decryptedContent = '[Unable to decrypt]';
          }

          await saveMessageToIsar(
            contractId: widget.contractId,
            externalId: msg.id,
            senderId: msg.senderId,
            senderFirstName: msg.senderFirstName,
            senderLastName: msg.senderLastName,
            content: decryptedContent,
            contentHash: msg.contentHash,
            createdAt: msg.createdAt,
          );
        }

        _scrollToBottom();
      }
    } catch (e) {
      print('[ContractAgreement] Error syncing messages: $e');
    }
  }

  /// Sync media from backend
  Future<void> _syncMedia() async {
    if (_externalContractId == null) return;

    try {
      final mediaCubit = context.read<MediaCubit>();
      await mediaCubit.loadMedia(contractId: _externalContractId!);

      final state = mediaCubit.state;
      if (state is MediaListLoaded) {
        for (final media in state.mediaList) {
          await saveMediaToIsar(
            contractId: widget.contractId,
            externalId: media.id,
            senderId: media.senderId,
            senderName: media.senderName,
            originalFilename: media.originalFilename,
            content: media.content,
            url: media.url,
            mimeType: media.mimeType,
            createdAt: media.createdAt,
          );
        }
      }
    } catch (e) {
      print('[ContractAgreement] Error syncing media: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Send encrypted message to backend
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (_externalContractId == null) return;
    if (_privateKeyBytes == null || _otherUserPublicKey == null) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('error_encryption_keys_missing'),
      );
      return;
    }

    _messageController.clear();
    setState(() => _isSendingMessage = true);

    try {
      // Get sender's public key from Hive
      final userBox = await Hive.openBox('user');
      final myPublicKey = userBox.get('publicKey')?.toString();

      if (myPublicKey == null) {
        throw Exception('Sender public key not found');
      }

      // Encrypt message for sender (self) and recipient
      final contentForSender = CryptoService.encryptWithPublicKey(
        plaintext: text,
        publicKeyBase64: myPublicKey,
      );
      final contentForRecipient = CryptoService.encryptWithPublicKey(
        plaintext: text,
        publicKeyBase64: _otherUserPublicKey!,
      );

      // Create SHA256 hash of plaintext for verification
      final contentHash = sha256.convert(utf8.encode(text)).toString();

      // Send to backend
      await context.read<MessageCubit>().sendMessage(
        contractId: _externalContractId!,
        contentForSender: contentForSender,
        contentForRecipient: contentForRecipient,
        contentHash: contentHash,
      );

      // Sync messages from server to get all messages including the one we just sent
      await _syncMessages();

      _scrollToBottom();

    } catch (e) {
      print('[ContractAgreement] Error sending message: $e');
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('error_sending_message'),
      );
    } finally {
      setState(() => _isSendingMessage = false);
    }
  }

  /// Send media file to backend
  Future<void> _sendMedia(String filePath) async {
    if (_externalContractId == null) return;

    try {
      final file = File(filePath);
      final filename = filePath.split(Platform.pathSeparator).last;


      // Upload to backend
      await context.read<MediaCubit>().uploadMedia(
        contractId: _externalContractId!,
        file: file,
        filename: filename,
      );

      // Sync to get the real data from server
      await _syncMedia();

      SnackBarHandler.showSuccess(
        context,
        TranslationHandler.get('media_uploaded_success'),
      );
    } catch (e) {
      print('[ContractAgreement] Error sending media: $e');
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('error_uploading_media'),
      );
    }
  }

  /// Accept contract
  Future<void> _acceptContract() async {
    if (_externalContractId == null) return;

    try {
      await context.read<ContractStateCubit>().accept(_externalContractId!);

      SnackBarHandler.showSuccess(
        context,
        TranslationHandler.get('contract_accepted'),
      );

      // Sync from backend to get updated status
      await _syncContract();
    } catch (e) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('error_accepting_contract'),
      );
    }
  }

  /// Dispute contract
  Future<void> _disputeContract({String? reason}) async {
    if (_externalContractId == null) return;

    try {
      await context.read<ContractStateCubit>().dispute(
        _externalContractId!,
        reason: reason,
      );

      SnackBarHandler.showWarning(
        context,
        TranslationHandler.get('contract_disputed'),
      );

      // Sync from backend to get updated status
      await _syncContract();
    } catch (e) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('error_disputing_contract'),
      );
    }
  }

  /// Sync contract from backend
  Future<void> _syncContract() async {
    try {
      final syncService = ContractSyncService();
      await syncService.syncContracts();
      print('[ContractAgreement] Contract synced from backend');
    } catch (e) {
      print('[ContractAgreement] Error syncing contract: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<Contract?>(
      stream: isar.contracts.watchObject(
        widget.contractId,
        fireImmediately: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text(TranslationHandler.get('error_contract_not_found')),
            ),
          );
        }

        final contract = snapshot.data!;

        return _buildPage(context, contract);
      },
    );
  }

  Widget _buildPage(BuildContext context, Contract contract) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          contract.title,
          style: theme.textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: () => _showContractDetails(contract),
            icon: Icon(Icons.info_outline, size: 25, color: colors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusSection(context, contract),
            Expanded(child: _buildMessagesList()),
            _buildChatInputBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Contract contract) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Show status badges for terminal states
    if (contract.status == ContractStatus.disputed) {
      return _buildStatusBadge(
        colors,
        Colors.red,
        Icons.gavel,
        'status_disputed',
      );
    }
    if (contract.status == ContractStatus.completed) {
      return _buildStatusBadge(
        colors,
        Colors.green,
        Icons.check_circle,
        'status_completed',
      );
    }
    if (contract.status == ContractStatus.accepted) {
      return _buildStatusBadge(
        colors,
        Colors.green,
        Icons.check_circle,
        'status_accepted',
      );
    }
    if (contract.status == ContractStatus.rejected) {
      return _buildStatusBadge(
        colors,
        Colors.grey,
        Icons.cancel,
        'status_rejected',
      );
    }

    // Show pending acceptance status
    final isUserA = contract.userAId == _currentUserId;
    final myAccepted = isUserA ? contract.userAAccepted : contract.userBAccepted;
    final otherAccepted = isUserA ? contract.userBAccepted : contract.userAAccepted;

    if (myAccepted && !otherAccepted) {
      return _buildStatusBadge(
        colors,
        Colors.orange,
        Icons.hourglass_empty,
        'waiting_for_other_accept',
      );
    }

    // Show action buttons for active contracts
    return BlocListener<ContractStateCubit, ContractStateState>(
      listener: (context, state) {
        if (state is ContractStateError) {
          SnackBarHandler.showError(context, state.message);
        }
      },
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                TranslationHandler.get('dispute'),
                Icons.gavel,
                Colors.white,
                Colors.red,
                () => _showDisputeConfirmation(context),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                myAccepted
                    ? TranslationHandler.get('accepted')
                    : TranslationHandler.get('accept'),
                Icons.check_circle,
                Colors.white,
                myAccepted ? Colors.grey : Colors.green,
                myAccepted ? null : () => _showAcceptConfirmation(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    ColorScheme colors,
    Color statusColor,
    IconData icon,
    String statusKey,
  ) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: statusColor),
            const SizedBox(width: 8),
            Text(
              TranslationHandler.get(statusKey).toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationHandler.get('accept_contract')),
        content: Text(TranslationHandler.get('accept_contract_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationHandler.get('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _acceptContract();
            },
            child: Text(
              TranslationHandler.get('accept'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisputeConfirmation(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationHandler.get('dispute_contract')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TranslationHandler.get('dispute_contract_warning')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: TranslationHandler.get('dispute_reason_optional'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationHandler.get('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _disputeContract(reason: reasonController.text.trim());
            },
            child: Text(
              TranslationHandler.get('dispute'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color textColor,
    Color bgColor,
    VoidCallback? onPressed,
  ) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Refresh all data from backend
  Future<void> _onRefresh() async {
    await Future.wait([
      _syncContract(),
      _syncMessages(),
      _syncMedia(),
    ]);
  }

  /// Build messages list from Isar with real-time updates
  Widget _buildMessagesList() {
    return StreamBuilder<List<Message>>(
      stream: isar.messages
          .filter()
          .contractIdEqualTo(widget.contractId)
          .sortByCreatedAt()
          .watch(fireImmediately: true),
      builder: (context, msgSnapshot) {
        return StreamBuilder<List<MediaFile>>(
          stream: isar.mediaFiles
              .filter()
              .contractIdEqualTo(widget.contractId)
              .sortByCreatedAt()
              .watch(fireImmediately: true),
          builder: (context, mediaSnapshot) {
            final messages = msgSnapshot.data ?? [];
            final mediaFiles = mediaSnapshot.data ?? [];

            if (messages.isEmpty && mediaFiles.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          TranslationHandler.get('no_messages_yet'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Combine messages and media into a single sorted list
            final List<dynamic> allItems = [...messages, ...mediaFiles];
            allItems.sort((a, b) {
              final aTime = a is Message ? a.createdAt : (a as MediaFile).createdAt;
              final bTime = b is Message ? b.createdAt : (b as MediaFile).createdAt;
              return aTime.compareTo(bTime);
            });

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  print('[ContractAgreement] Building item at index $_currentUserId');
                  final item = allItems[index];
                  if (item is Message) {
                    return _buildMessageBubble(item, item.senderId == _currentUserId);
                  } else if (item is MediaFile) {
                    return _buildMediaBubble(item, item.senderId == _currentUserId);
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final colors = Theme.of(context).colorScheme;
    final senderName = _getSenderName(message);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.surfaceContainerHighest,
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 12, color: colors.onSurface),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                color: isMe ? colors.primary : colors.surface,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? colors.onPrimary : colors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMe
                          ? colors.onPrimary.withOpacity(0.7)
                          : colors.onSurface.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.primary,
              child: Text(
                'Me',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaBubble(MediaFile media, bool isMe) {
    final colors = Theme.of(context).colorScheme;
    final isUrl = media.url.startsWith('http');
    final isImage = media.mimeType?.startsWith('image') == true ||
        media.originalFilename.toLowerCase().endsWith('.png') ||
        media.originalFilename.toLowerCase().endsWith('.jpg') ||
        media.originalFilename.toLowerCase().endsWith('.jpeg');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.surfaceContainerHighest,
              child: Text(
                media.senderName?.isNotEmpty == true
                    ? media.senderName![0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 12, color: colors.onSurface),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isMe ? colors.primary : colors.surface,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isImage)
                      isUrl
                          ? Image.network(
                              media.url,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 150,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                          width: 200,
                                          height: 150,
                                          color: colors.surfaceContainerHighest,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                              errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(colors),
                            )
                          : Image.file(
                              File(media.content),
                              fit: BoxFit.cover,
                              width: 200,
                              height: 150,
                              errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(colors),
                            )
                    else
                      _buildFilePlaceholder(colors, media.originalFilename),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.originalFilename,
                            style: TextStyle(
                              color: isMe ? colors.onPrimary : colors.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(media.createdAt),
                            style: TextStyle(
                              color: isMe
                                  ? colors.onPrimary.withOpacity(0.7)
                                  : colors.onSurface.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.primary,
              child: Text(
                'Me',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrokenImagePlaceholder(ColorScheme colors) {
    return Container(
      width: 200,
      height: 150,
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image,
        color: colors.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildFilePlaceholder(ColorScheme colors, String filename) {
    final extension = filename.split('.').last.toLowerCase();
    IconData icon;

    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        break;
      case 'mp4':
      case 'mov':
      case 'avi':
        icon = Icons.videocam;
        break;
      default:
        icon = Icons.insert_drive_file;
    }

    return Container(
      width: 200,
      height: 100,
      color: colors.surfaceContainerHighest,
      child: Icon(icon, size: 40, color: colors.primary),
    );
  }

  Widget _buildChatInputBar(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: Icon(Icons.attach_file, color: colors.onSurface, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: TranslationHandler.get('type_your_message'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(color: colors.onSurface),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSendingMessage ? colors.surfaceContainerHighest : colors.primary,
            ),
            child: IconButton(
              onPressed: _isSendingMessage ? null : _sendMessage,
              icon: _isSendingMessage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : Icon(Icons.send, color: colors.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TranslationHandler.get('choose_file_type'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    Icons.photo_camera,
                    TranslationHandler.get('camera'),
                    _pickImageFromCamera,
                  ),
                  _buildAttachmentOption(
                    Icons.photo,
                    TranslationHandler.get('gallery'),
                    _pickImageFromGallery,
                  ),
                  _buildAttachmentOption(
                    Icons.videocam,
                    TranslationHandler.get('video'),
                    _pickVideo,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Function() onTap) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: colors.onPrimaryContainer, size: 24),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colors.onSurface)),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) await _sendMedia(image.path);
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _sendMedia(image.path);
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _sendMedia(video.path);
  }

  void _showContractDetails(Contract contract) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isUserA = contract.userAId == _currentUserId;
    final otherName = isUserA ? contract.userBName : contract.userAName;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: colors.surface,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: colors.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TranslationHandler.get('contract_details'),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getStatusText(contract.status)} • ${contract.createdAt.toString().split(' ')[0]}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  TranslationHandler.get('contract_title'),
                  contract.title,
                  Icons.title,
                ),
                _buildDetailRow(
                  TranslationHandler.get('other_party'),
                  otherName ?? TranslationHandler.get('unknown'),
                  Icons.person,
                ),
                _buildDetailRow(
                  TranslationHandler.get('price'),
                  '${contract.price} ${TranslationHandler.get('currency')}',
                  Icons.attach_money,
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationHandler.get('description'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    contract.description,
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(TranslationHandler.get('close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(ContractStatus status) {
    switch (status) {
      case ContractStatus.active:
        return TranslationHandler.get('status_active');
      case ContractStatus.accepted:
        return TranslationHandler.get('status_accepted');
      case ContractStatus.pending:
        return TranslationHandler.get('status_pending');
      case ContractStatus.disputed:
        return TranslationHandler.get('status_disputed');
      case ContractStatus.completed:
        return TranslationHandler.get('status_completed');
      case ContractStatus.rejected:
        return TranslationHandler.get('status_rejected');
    }
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSenderName(Message message) {
    if (message.senderId == _currentUserId) {
      return 'Me';
    }
    final first = message.senderFirstName ?? '';
    final last = message.senderLastName ?? '';
    return '$first $last'.trim().isNotEmpty ? '$first $last'.trim() : 'User';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


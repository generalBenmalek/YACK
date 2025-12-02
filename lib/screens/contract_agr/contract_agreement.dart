import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:io';
import 'package:yack/db/models/contract.dart';
import 'package:yack/db/models/message.dart' as db;
import 'package:yack/db/models/mediaFile.dart';
import 'package:yack/main.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/db/online.dart' as online_db;
import 'contract_cubit.dart';

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

  late String _currentUserId;
  String? _externalContractId;
  String? _contractKey;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _disputeSubscription;
  StreamSubscription? _closeSubscription;
  StreamSubscription? _completedSubscription;
  StreamSubscription? _mediaSubscription;
  
  bool _hasShownCompletionDialog = false;
  bool _hasShownDisputeDialog = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _loadExternalIdAndSubscribe();
  }

  // Load contract external ID and setup Firebase listeners (Chadli)
  Future<void> _loadExternalIdAndSubscribe() async {
    final contract = await isar.contracts.get(widget.contractId);
    if (contract != null) {
      // Set current user from contract if not from Firebase Auth (Chadli)
      if (_currentUserId.isEmpty) {
        _currentUserId = contract.userB.isNotEmpty ? contract.userB : contract.userA;
      }
      
      if (contract.externalId != null && contract.externalId!.isNotEmpty) {
        _externalContractId = contract.externalId;
      
      final keyResult = await online_db.getKey(_externalContractId!);
      if (keyResult['status'] == true) {
        _contractKey = keyResult['key'];
      }
      
      // Check if contract was completed while user was away (Chadli)
      await _checkCompletedStatus();
      
      _subscribeToFirebaseMessages();
      _subscribeToDisputeNotifications();
      _subscribeToCloseRequests();
      _subscribeToCompletedStatus();
      _subscribeToMediaFiles();
      }
    }
  }
  
  // One-time check for completed status on chat entry (Chadli)
  Future<void> _checkCompletedStatus() async {
    if (_externalContractId == null) return;
    
    final completedRef = FirebaseDatabase.instance.ref('completedContracts/$_externalContractId');
    final snapshot = await completedRef.get();
    
    if (snapshot.exists && snapshot.value != null) {
      await _updateLocalContractStatus(ContractStatus.completed);
    }
  }

  // Listen for contract completion in persistent node (Chadli)
  void _subscribeToCompletedStatus() {
    if (_externalContractId == null) return;
    
    final completedRef = FirebaseDatabase.instance.ref('completedContracts/$_externalContractId');
    _completedSubscription = completedRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data != null) {
        await _updateLocalContractStatus(ContractStatus.completed);
      }
    });
  }

  // Listen to Firebase supportDocs and sync media files (Chadli)
  void _subscribeToMediaFiles() {
    if (_externalContractId == null) return;
    
    final ref = FirebaseDatabase.instance.ref('contracts/$_externalContractId/supportDocs');
    _mediaSubscription = ref.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;
      
      if (data is List) {
        for (var doc in data) {
          if (doc is Map) await _syncMediaToIsar(doc);
        }
      }
    });
  }

  // Sync media file from Firebase to local Isar (Chadli)
  Future<void> _syncMediaToIsar(Map doc) async {
    final senderId = doc['userId']?.toString() ?? '';
    final type = doc['type']?.toString() ?? '';
    String content = doc['content']?.toString() ?? '';
    
    if (content.isEmpty || type == 'text') return;
    if (senderId == _currentUserId) return; // Skip own files (Chadli)
    
    // Decrypt the URL (Chadli)
    if (_contractKey != null) {
      try {
        content = online_db.decrypt(content, _contractKey!);
      } catch (_) { return; }
    }
    
    // Check if already synced (Chadli)
    final existing = await isar.mediaFiles
        .filter()
        .contractIdEqualTo(widget.contractId)
        .filePathEqualTo(content)
        .findFirst();
    
    if (existing == null) {
      await isar.writeTxn(() async {
        await isar.mediaFiles.put(
          MediaFile()
            ..contractId = widget.contractId
            ..senderId = senderId
            ..filePath = content // URL from Cloudinary (Chadli)
            ..type = type
            ..createdAt = DateTime.now(),
        );
      });
    }
  }

  // Listen to Firebase messages and sync to local Isar (Chadli)
  void _subscribeToFirebaseMessages() {
    if (_externalContractId == null) return;
    
    final ref = FirebaseDatabase.instance.ref('contracts/$_externalContractId/messages');
    _messagesSubscription = ref.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;
      
      // Firebase push() creates Map with unique keys (Chadli)
      if (data is Map) {
        for (var entry in data.entries) {
          final firebaseKey = entry.key.toString();
          final msg = entry.value;
          if (msg is Map) await _syncMessageToIsar(msg, firebaseKey);
        }
      } else if (data is List) {
        // Fallback for list format - use index as key (Chadli)
        for (int i = 0; i < data.length; i++) {
          final msg = data[i];
          if (msg is Map) await _syncMessageToIsar(msg, 'list_$i');
        }
      }
      _scrollToBottom();
    });
  }

  // Sync a single message from Firebase to Isar using firebaseKey (Chadli)
  Future<void> _syncMessageToIsar(Map msg, String firebaseKey) async {
    final senderId = msg['senderId']?.toString() ?? '';
    String text = msg['text']?.toString() ?? '';
    final timestamp = msg['timestamp'];
    final isEncrypted = msg['encrypted'] == true;
    
    if (text.isEmpty) return;
    
    if (isEncrypted && _contractKey != null) {
      try {
        text = online_db.decrypt(text, _contractKey!);
      } catch (_) {}
    }
    
    final msgTime = timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp is int ? timestamp : int.tryParse(timestamp.toString()) ?? 0)
        : DateTime.now();
    
    // Unique key combines contractId + firebaseKey (Chadli)
    final uniqueKey = '${widget.contractId}_$firebaseKey';
    
    // 1. Check if message already exists by unique key (Chadli)
    final existing = await isar.messages
        .filter()
        .firebaseKeyEqualTo(uniqueKey)
        .findFirst();
    
    if (existing != null) return;

    // 2. Check for local temporary message to update (Deduplication) (Chadli)
    // We look for a message with same sender, text and a local key
    final localMatch = await isar.messages
        .filter()
        .contractIdEqualTo(widget.contractId)
        .senderIdEqualTo(senderId)
        .textEqualTo(text)
        .firebaseKeyStartsWith('${widget.contractId}_local_')
        .sortByCreatedAt() // Pick oldest first to ensure correct FIFO matching
        .findFirst();

    if (localMatch != null) {
      // Update it with the real Firebase key.
      await isar.writeTxn(() async {
        localMatch.firebaseKey = uniqueKey;
        await isar.messages.put(localMatch);
      });
      return;
    }
    
    // 3. Insert new if not found
    await isar.writeTxn(() async {
        await isar.messages.put(
          db.Message()
            ..contractId = widget.contractId
            ..senderId = senderId
            ..text = text
            ..createdAt = msgTime
            ..firebaseKey = uniqueKey,
        );
    });
  }

  // Listen for dispute notifications from other party (Chadli)
  void _subscribeToDisputeNotifications() {
    if (_externalContractId == null) return;
    
    final disputeRef = FirebaseDatabase.instance.ref('dispute/$_externalContractId');
    _disputeSubscription = disputeRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;
      
      if (data is Map && !_hasShownDisputeDialog) {
        final disputedBy = data['disputedBy']?.toString() ?? '';
        
        if (disputedBy.isNotEmpty && disputedBy != _currentUserId) {
          _hasShownDisputeDialog = true;
          await _updateLocalContractStatus(ContractStatus.onDispute);
          if (mounted) _showDisputeNotificationDialog();
        }
      }
    });
  }

  // Listen for close requests from other party (Chadli)
  void _subscribeToCloseRequests() {
    if (_externalContractId == null) return;
    
    final closeRef = FirebaseDatabase.instance.ref('contracts/$_externalContractId/close');
    _closeSubscription = closeRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null || _hasShownCompletionDialog) return;
      
      if (data is String) {
        String requesterId = data;
        if (_contractKey != null) {
          try {
            requesterId = online_db.decrypt(data, _contractKey!);
          } catch (_) { return; }
        }
        
        // Show dialog only to OTHER party (Chadli)
        if (requesterId.isNotEmpty && requesterId != _currentUserId) {
          _hasShownCompletionDialog = true;
          if (mounted) _showCompletionConfirmationDialog();
        }
      }
    });
  }

  // Show dialog when other party raises a dispute (Chadli)
  void _showDisputeNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(TranslationHandler.get('dispute_raised')),
          ],
        ),
        content: const Text('The other party has raised a dispute against this contract.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show dialog when other party requests completion (Chadli)
  void _showCompletionConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(TranslationHandler.get('completion_request')),
          ],
        ),
        content: const Text('The other party wants to complete this contract. Do you confirm?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _hasShownCompletionDialog = false;
              // Decline the request (Chadli)
              if (_externalContractId != null) {
                await online_db.declineCompletion(_externalContractId!);
              }
            },
            child: Text(TranslationHandler.get('no')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              await online_db.closeContract(_externalContractId!, _currentUserId);
              await _updateLocalContractStatus(ContractStatus.completed);
            },
            child: Text(TranslationHandler.get('yes'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Update local contract status in Isar (Chadli)
  Future<void> _updateLocalContractStatus(ContractStatus newStatus) async {
    final contract = await isar.contracts.get(widget.contractId);
    if (contract != null && contract.status != newStatus) {
      await isar.writeTxn(() async {
        contract.status = newStatus;
        contract.updatedAt = DateTime.now();
        await isar.contracts.put(contract);
      });
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _disputeSubscription?.cancel();
    _closeSubscription?.cancel();
    _completedSubscription?.cancel();
    _mediaSubscription?.cancel();
    super.dispose();
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

  // Send text message with encryption (Chadli)
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final timestamp = DateTime.now();
    
    // Generate local key first, will be replaced by Firebase key after push (Chadli)
    final localKey = 'local_${timestamp.millisecondsSinceEpoch}_${_currentUserId.hashCode}';
    final uniqueKey = '${widget.contractId}_$localKey';
    
    await isar.writeTxn(() async {
      await isar.messages.put(
        db.Message()
          ..contractId = widget.contractId
          ..senderId = _currentUserId
          ..text = text
          ..createdAt = timestamp
          ..firebaseKey = uniqueKey,
      );
    });

    _scrollToBottom();
    
    if (_externalContractId != null) {
      try {
        final ref = FirebaseDatabase.instance.ref('contracts/$_externalContractId/messages');
        String messageToSend = text;
        bool isEncrypted = false;
        if (_contractKey != null) {
          messageToSend = online_db.encrypt(text, _contractKey!);
          isEncrypted = true;
        }
        
        // Push returns a reference with the generated key (Chadli)
        final newRef = ref.push();
        await newRef.set({
          'senderId': _currentUserId,
          'text': messageToSend,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'encrypted': isEncrypted,
        });
        
        // Update local message with Firebase key (Chadli)
        final firebaseUniqueKey = '${widget.contractId}_${newRef.key}';
        final localMsg = await isar.messages.filter().firebaseKeyEqualTo(uniqueKey).findFirst();
        if (localMsg != null) {
          await isar.writeTxn(() async {
            localMsg.firebaseKey = firebaseUniqueKey;
            await isar.messages.put(localMsg);
          });
        }
      } catch (_) {}
    }
  }

  // Send media file with upload to Cloudinary (Chadli)
  Future<void> _sendMedia(String filePath, String type) async {
    final timestamp = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.mediaFiles.put(
        MediaFile()
          ..contractId = widget.contractId
          ..senderId = _currentUserId
          ..filePath = filePath
          ..type = type
          ..createdAt = timestamp,
      );
    });
    
    final fileMessage = type == 'image' ? '📷 Shared an image' : '🎥 Shared a video';
    await isar.writeTxn(() async {
      await isar.messages.put(
        db.Message()
          ..contractId = widget.contractId
          ..senderId = _currentUserId
          ..text = fileMessage
          ..createdAt = timestamp,
      );
    });
    
    _scrollToBottom();
    
    if (_externalContractId != null) {
      try {
        final file = File(filePath);
        await online_db.addFile(_externalContractId!, _currentUserId, file, type);
        
        final ref = FirebaseDatabase.instance.ref('contracts/$_externalContractId/messages');
        String messageToSend = fileMessage;
        if (_contractKey != null) {
          messageToSend = online_db.encrypt(fileMessage, _contractKey!);
        }
        
        await ref.push().set({
          'senderId': _currentUserId,
          'text': messageToSend,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'encrypted': _contractKey != null,
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractCubit(widget.contractId)..loadContract(),
      child: BlocBuilder<ContractCubit, ContractState>(
        builder: (context, state) {
          if (state is ContractLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state is ContractError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          final contract = (state as ContractLoaded).contract;
          return _buildPage(context, contract);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, Contract contract) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(TranslationHandler.get('contract_agreement_title'), style: theme.textTheme.titleMedium),
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
    final cubit = context.read<ContractCubit>();

    if (contract.status == ContractStatus.pending) {
      return _buildStatusBadge(colors, Colors.orange, Icons.hourglass_empty, 'status_pending');
    }
    if (contract.status == ContractStatus.onDispute) {
      return _buildStatusBadge(colors, Colors.red, Icons.gavel, 'status_disputed');
    }
    if (contract.status == ContractStatus.completed) {
      return _buildStatusBadge(colors, Colors.green, Icons.check_circle, 'status_completed');
    }
    if (contract.status == ContractStatus.rejected) {
      return _buildStatusBadge(colors, Colors.grey, Icons.cancel, 'status_rejected');
    }

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              TranslationHandler.get('dispute'), Icons.gavel, Colors.white, Colors.red,
              () => _showDisputeConfirmation(context, cubit),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildActionButton(
              TranslationHandler.get('complete'), Icons.check_circle, Colors.white, Colors.green,
              () => _showCompleteConfirmation(context, cubit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colors, Color statusColor, IconData icon, String statusKey) {
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
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteConfirmation(BuildContext context, ContractCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationHandler.get('complete_contract')),
        content: Text(TranslationHandler.get('complete_contract_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationHandler.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.completeContract();
            },
            child: Text(TranslationHandler.get('complete')),
          ),
        ],
      ),
    );
  }

  void _showDisputeConfirmation(BuildContext context, ContractCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationHandler.get('dispute')),
        content: const Text('Are you sure you want to dispute this contract?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationHandler.get('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.disputeContract();
            },
            child: Text(TranslationHandler.get('dispute')),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color textColor, Color bgColor, VoidCallback onPressed) {
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
              Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  // Build messages list with media files support (Chadli)
  Widget _buildMessagesList() {
    return StreamBuilder<List<db.Message>>(
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
              return Center(
                child: Text(
                  TranslationHandler.get('no_messages_yet'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              );
            }

            // Combine messages and media into a single sorted list
            final List<dynamic> allItems = [...messages, ...mediaFiles];
            allItems.sort((a, b) {
              final aTime = a is db.Message ? a.createdAt : (a as MediaFile).createdAt;
              final bTime = b is db.Message ? b.createdAt : (b as MediaFile).createdAt;
              return aTime.compareTo(bTime);
            });

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                if (item is db.Message) {
                  return _buildMessageBubble(item, item.senderId == _currentUserId);
                } else if (item is MediaFile) {
                  return _buildMediaBubble(item, item.senderId == _currentUserId);
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(db.Message message, bool isMe) {
    final colors = Theme.of(context).colorScheme;

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
              child: Text(message.senderId.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 12, color: colors.onSurface)),
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
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: TextStyle(color: isMe ? colors.onPrimary : colors.onSurface, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: isMe ? colors.onPrimary.withOpacity(0.7) : colors.onSurface.withOpacity(0.5), fontSize: 10),
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
              child: Text('Me', style: TextStyle(fontSize: 10, color: colors.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  // Build media file bubble - supports local files and URLs (Chadli)
  Widget _buildMediaBubble(MediaFile media, bool isMe) {
    final colors = Theme.of(context).colorScheme;
    final isUrl = media.filePath.startsWith('http');

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
              child: Text(media.senderId.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 12, color: colors.onSurface)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isMe ? colors.primary : colors.surface,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (media.type == 'image')
                      isUrl
                          ? Image.network(
                              media.filePath,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 150,
                              loadingBuilder: (_, child, progress) => progress == null
                                  ? child
                                  : Container(
                                      width: 200,
                                      height: 150,
                                      color: colors.surfaceContainerHighest,
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                              errorBuilder: (_, __, ___) => Container(
                                width: 200,
                                height: 150,
                                color: colors.surfaceContainerHighest,
                                child: Icon(Icons.broken_image, color: colors.onSurface.withOpacity(0.5)),
                              ),
                            )
                          : Image.file(
                              File(media.filePath),
                              fit: BoxFit.cover,
                              width: 200,
                              height: 150,
                              errorBuilder: (_, __, ___) => Container(
                                width: 200,
                                height: 150,
                                color: colors.surfaceContainerHighest,
                                child: Icon(Icons.broken_image, color: colors.onSurface.withOpacity(0.5)),
                              ),
                            )
                    else
                      Container(
                        width: 200,
                        height: 150,
                        color: colors.surfaceContainerHighest,
                        child: Icon(Icons.videocam, size: 50, color: colors.primary),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${media.createdAt.hour}:${media.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: isMe ? colors.onPrimary.withOpacity(0.7) : colors.onSurface.withOpacity(0.5), fontSize: 10),
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
              child: Text('Me', style: TextStyle(fontSize: 10, color: colors.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatInputBar(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: colors.onPrimary, size: 20),
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(TranslationHandler.get('choose_file_type'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(Icons.photo_camera, TranslationHandler.get('camera'), _pickImageFromCamera),
                  _buildAttachmentOption(Icons.photo, TranslationHandler.get('gallery'), _pickImageFromGallery),
                  _buildAttachmentOption(Icons.videocam, TranslationHandler.get('video'), _pickVideo),
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
          decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
          child: IconButton(onPressed: onTap, icon: Icon(icon, color: colors.onPrimaryContainer, size: 24), padding: const EdgeInsets.all(12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colors.onSurface)),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) await _sendMedia(image.path, 'image');
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _sendMedia(image.path, 'image');
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _sendMedia(video.path, 'video');
  }

  void _showContractDetails(Contract contract) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.assignment, color: colors.onPrimaryContainer, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(TranslationHandler.get('contract_details'), style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('${_getStatusText(contract.status)} • ${contract.createdAt.toString().split(' ')[0]}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(TranslationHandler.get('contract_name'), contract.name, Icons.badge),
                _buildDetailRow(TranslationHandler.get('price'), '${contract.price} ${TranslationHandler.get('currency')}', Icons.attach_money),
                _buildDetailRow(TranslationHandler.get('client'), contract.userAName ?? contract.userA, Icons.person),
                const SizedBox(height: 10),
                Text(TranslationHandler.get('description'), style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(contract.description, style: TextStyle(color: colors.onSurface.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      case ContractStatus.accepted: return TranslationHandler.get('status_active');
      case ContractStatus.pending: return TranslationHandler.get('status_pending');
      case ContractStatus.onDispute: return TranslationHandler.get('status_disputed');
      case ContractStatus.completed: return TranslationHandler.get('status_completed');
      case ContractStatus.rejected: return TranslationHandler.get('status_rejected');
    }
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: colors.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

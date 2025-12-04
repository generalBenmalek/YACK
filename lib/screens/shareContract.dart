import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../db/models/contract.dart';
import '../db/online.dart' as online_db;
import '../db/isar_adapter.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/translation_handler.dart';
import 'sign_contract.dart';

class ShareContractScreen extends StatefulWidget {
  final Contract contract;

  const ShareContractScreen({super.key, required this.contract});

  @override
  State<ShareContractScreen> createState() => _ShareContractScreenState();
}

class _ShareContractScreenState extends State<ShareContractScreen> {
  late String contractId;
  late String link;
  late String _userDisplayName; // Store user's display name for contract saving
  late String _currentUserId; // Store current user's Firebase UID
  bool _isWaiting = false;
  bool _isAccepted = false;
  String? _error;
  bool _contractSaved = false; // Track if contract was saved to Isar

  @override
  void initState() {
    super.initState();
    // Generate unique contract ID
    contractId = widget.contract.externalId ?? const Uuid().v4();

    // Get current user's Firebase UID
    final currentUser = FirebaseAuth.instance.currentUser;
    _currentUserId =
        currentUser?.uid ??
        'test_user_${DateTime.now().millisecondsSinceEpoch}';

    // Get user's actual name from Hive, fallback to Firebase displayName
    final userBox = Hive.box('user');
    final firstName = userBox.get('firstName', defaultValue: '') ?? '';
    final lastName = userBox.get('lastName', defaultValue: '') ?? '';
    _userDisplayName = [
      firstName,
      lastName,
    ].where((s) => s.isNotEmpty).join(' ').trim();

    // Fallback to Firebase displayName if Hive name is empty
    if (_userDisplayName.isEmpty) {
      _userDisplayName = currentUser?.displayName ?? '';
    }

    // Final fallback to 'Unknown' - don't use email as it may look like a hash
    if (_userDisplayName.isEmpty) _userDisplayName = 'Unknown';

    // Build QR data with current user's UID and display name (Chadli - fixed)
    final jsonString = json.encode({
      'id': contractId,
      'name': widget.contract.name,
      'price': widget.contract.price,
      'description': widget.contract.description,
      'userA': _currentUserId, // Use current Firebase UID directly
      'userAName': _userDisplayName, // Add display name
    });
    final encodedData = base64Url.encode(utf8.encode(jsonString));
    link = "yack://contract?data=$encodedData";
  }

  Future<void> _startInvitation() async {
    setState(() {
      _isWaiting = true;
      _error = null;
    });

    try {
      // DON'T save as pending - only save after acceptance (Chadli - fixed)
      // The contract should NOT be saved until the other user scans and accepts
      _contractSaved = false;

      // Call invite and wait for acceptance (5 min timeout)
      final result = await online_db.invite(
        contractId,
        widget.contract.name,
        widget.contract.description,
        widget.contract.price,
        _currentUserId,
      );

      if (result['status'] == true) {
        // Get userB info from result (Chadli)
        final userB = result['userB']?.toString() ?? '';
        final userBName = result['userBName']?.toString();

        // Contract accepted! Now save to Isar with userB info
        await saveContractToIsar(
          externalId: contractId,
          name: widget.contract.name,
          description: widget.contract.description,
          price: widget.contract.price,
          userA: _currentUserId,
          userAName: _userDisplayName,
          userB: userB,
          userBName: userBName,
          status: 'accepted',
        );
        _contractSaved = true;

        setState(() {
          _isAccepted = true;
          _isWaiting = false;
        });

        if (mounted) {
          SnackBarHandler.showSuccess(
            context,
            TranslationHandler.get('contract_accepted'),
          );

          // Navigate to sign screen or go back
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pop(true); // Return success
          }
        }
      } else {
        // Timeout or error or cancelled - no contract was saved, just cleanup Firebase
        await online_db.cancelInvitation(contractId);
        setState(() {
          _isWaiting = false;
          _error =
              result['error'] ?? TranslationHandler.get('invitation_timeout');
        });
      }
    } catch (e) {
      // Error occurred - cleanup Firebase invitation
      await online_db.cancelInvitation(contractId);
      setState(() {
        _isWaiting = false;
        _error = e.toString();
      });
    }
  }

  /// Delete the pending contract from Isar and cancel Firebase invitation (Chadli)
  Future<void> _deletePendingContract() async {
    try {
      // Always cancel Firebase invitation when user navigates away
      await online_db.cancelInvitation(contractId);

      // Only delete from Isar if it was actually saved (which now only happens after acceptance)
      if (_contractSaved) {
        await deleteContractFromIsar(contractId);
        _contractSaved = false;
      }
    } catch (_) {}
  }

  Future<void> _cancelInvitation() async {
    // Cancel the invitation and cleanup
    await _deletePendingContract();
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Delete pending contract if user navigates away
        await _deletePendingContract();
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            TranslationHandler.get('share_contract'),
            style: theme.textTheme.titleMedium,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        backgroundColor: color.surface,
        body: Stack(
          children: [
            // Hidden button for signing simulation (top-left corner)
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignContractScreen(),
                    ),
                  );
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contract container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: color.outline.withOpacity(0.5),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: color.surface,
                        boxShadow: [
                          BoxShadow(
                            color: color.shadow.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // QR Code
                          QrImageView(
                            data: link,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 20),

                          // Status indicator: Chadli
                          if (_isWaiting) ...[
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              TranslationHandler.get('waiting_for_acceptance'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else if (_isAccepted) ...[
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              TranslationHandler.get('contract_accepted'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else if (_error != null) ...[
                            Icon(
                              Icons.error_outline,
                              color: color.error,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            Text(
                              TranslationHandler.get('scan_contract_prompt'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: color.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),
                          const Divider(thickness: 1, height: 10),
                          const SizedBox(height: 20),

                          Text(
                            TranslationHandler.get('share_warning'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Buttons
                  if (!_isWaiting && !_isAccepted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startInvitation,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(TranslationHandler.get('start_sharing')),
                      ),
                    ),
                  ] else if (_isWaiting) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelInvitation,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: color.error,
                        ),
                        child: Text(TranslationHandler.get('cancel')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:yack/logic/cubits/contract/temp_contract_cubit.dart';
import 'package:yack/logic/cubits/contract/temp_contract_state.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/presentation/screens/scan_contract.dart';
import 'package:yack/presentation/screens/shareContract.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/logic/services/snackBarHandler.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Generate SHA256 hash of contract details for verification
  String _generateDetailsHash(String title, String description, String price) {
    final combined = '$title|$description|$price';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get user's public key from Hive cache
  Future<String?> _getUserPublicKey() async {
    try {
      final box = await Hive.openBox('user');
      return box.get('publicKey')?.toString();
    } catch (_) {
      return null;
    }
  }

  void _onCreateContract() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      SnackBarHandler.showError(context, TranslationHandler.get('title_required'));
      return;
    }

    // Validate price is a valid number
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    if (priceText.isEmpty || price == null || price < 0) {
      SnackBarHandler.showError(context, TranslationHandler.get('invalid_price'));
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priceStr = price.toStringAsFixed(2);

    // Get user's public key
    final publicKey = await _getUserPublicKey();
    if (publicKey == null || publicKey.isEmpty) {
      SnackBarHandler.showError(context, TranslationHandler.get('missing_public_key'));
      return;
    }

    // Generate details hash for verification
    final detailsHash = _generateDetailsHash(title, description, priceStr);

    // Encrypt fields for user A (creator) using their own public key
    final titleUserA = CryptoService.encryptWithPublicKey(
      plaintext: title,
      publicKeyBase64: publicKey,
    );
    final descriptionUserA = CryptoService.encryptWithPublicKey(
      plaintext: description,
      publicKeyBase64: publicKey,
    );
    final priceUserA = CryptoService.encryptWithPublicKey(
      plaintext: priceStr,
      publicKeyBase64: publicKey,
    );

    // Create temp contract on backend
    context.read<TempContractCubit>().create(
      titleUserA: titleUserA,
      descriptionUserA: descriptionUserA,
      priceUserA: priceUserA,
      detailsHash: detailsHash,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TempContractCubit, TempContractState>(
      listener: (context, state) {
        if (state is TempContractSuccess) {
          // Navigate to share screen with the temp contract
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShareContractScreen(
                tempContract: state.contract,
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                price: double.tryParse(_priceController.text.trim()) ?? 0,
              ),
            ),
          );
        } else if (state is TempContractError) {
          SnackBarHandler.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: Text(TranslationHandler.get('new_contract'),
              style: theme.textTheme.titleMedium),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),
            Text(
              TranslationHandler.get('title'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              maxLines: 1,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: TranslationHandler.get('title_hint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              TranslationHandler.get('description'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: TranslationHandler.get('description_hint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              TranslationHandler.get('price'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: TranslationHandler.get('price_hint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 8),
                  child: Text(
                    TranslationHandler.get('currency'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Add spacing to push buttons down
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            // Buttons at the bottom of ListView
            BlocBuilder<TempContractCubit, TempContractState>(
              builder: (context, state) {
                final isLoading = state is TempContractLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _onCreateContract,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add, size: 20),
                    label: Text(TranslationHandler.get('add_contract')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanContractScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, size: 22),
                label: Text(TranslationHandler.get('scan_contract_qr')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
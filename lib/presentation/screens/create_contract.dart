import 'package:flutter/material.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/presentation/screens/scan_contract.dart';
import 'package:yack/presentation/screens/shareContract.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: TranslationHandler.get('price_hint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 8),
                  child: Text(
                    'DA',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
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

                  final currentUser = FirebaseAuth.instance.currentUser;
                  final currentUserId = currentUser?.uid ?? 'Unknown';

                  final contract = Contract()
                    ..name = _titleController.text.trim()
                    ..description = _descriptionController.text.trim()
                    ..price = price
                    ..userA = currentUserId
                    ..userB = ''
                    ..status = ContractStatus.pending
                    ..createdAt = DateTime.now();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShareContractScreen(contract: contract),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(TranslationHandler.get('add_contract')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                icon: const Icon(Icons.grid_view_rounded, size: 22),
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
    );
  }
}
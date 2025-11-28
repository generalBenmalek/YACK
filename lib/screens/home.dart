import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../theme/theme.dart';
import 'create_contract.dart';
import '../db/models/contract.dart';
import 'package:yack/utils/translation_handler.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = Isar.getInstance();

    if (isar == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          TranslationHandler.get('contracts'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StreamBuilder<List<Contract>>(
              stream: isar.contracts.where().watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data;

                if (data == null || data.isEmpty) {
                  return Center(
                    child: Text(
                      'No contracts yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                final activeContracts = data
                    .where((c) => c.status == ContractStatus.accepted || c.status == ContractStatus.pending)
                    .toList();
                final pastContracts = data
                    .where((c) => c.status == ContractStatus.completed || c.status == ContractStatus.rejected)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  children: [
                    if (activeContracts.isNotEmpty)
                      _SectionHeader(
                          title: TranslationHandler.get('active_section')),
                    ...activeContracts
                        .map((c) => ContractCard(contract: c, isar: isar)),
                    if (activeContracts.isNotEmpty && pastContracts.isNotEmpty)
                      const SizedBox(height: 24),
                    if (pastContracts.isNotEmpty)
                      _SectionHeader(
                          title: TranslationHandler.get('past_section')),
                    ...pastContracts
                        .map((c) => ContractCard(contract: c, isar: isar)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.all(10),
        alignment: TranslationHandler.isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateContractScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.yackGreen,
          tooltip: TranslationHandler.get('add_contract'),
          child: const Icon(Icons.add, color: AppTheme.yackWhite, size: 28),
        ),
      ),
    ],
    ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.yackGray,
        ),
      ),
    );
  }
}

class ContractCard extends StatelessWidget {
  final Contract contract;
  final Isar isar;

  const ContractCard({
    super.key,
    required this.contract,
    required this.isar,
  });

  Future<void> _deleteContract(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contract?'),
        content: const Text(
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(TranslationHandler.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await isar.writeTxn(() async {
        await isar.contracts.delete(contract.id);
      });
    }
  }

  String _getStatusLabel() {
    switch (contract.status) {
      case ContractStatus.accepted:
        return TranslationHandler.get('status_active');
      case ContractStatus.completed:
        return TranslationHandler.get('status_completed');
      default:
        return contract.status.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.yackGreenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description, color: AppTheme.yackGreen),
        ),
        title: Text(
          contract.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${contract.price} DA'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: contract.status == ContractStatus.accepted
                    ? AppTheme.yackGreenLight
                    : AppTheme.yackGrayLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: contract.status == ContractStatus.accepted
                      ? AppTheme.yackGreen
                      : AppTheme.yackGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (contract.status == ContractStatus.completed || contract.status == ContractStatus.rejected)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteContract(context),
              ),
          ],
        ),
      ),
    );
  }
}

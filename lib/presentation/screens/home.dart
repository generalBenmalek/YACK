import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yack/presentation/screens/create_contract.dart';
import 'package:yack/presentation/theme/theme.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/logic/services/translation_handler.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = Isar.getInstance();

    if (isar == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          TranslationHandler.get('contracts'),
          style: Theme.of(context).textTheme.titleMedium,
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
                        .where(
                          (c) =>
                              c.status == ContractStatus.active ||
                              c.status == ContractStatus.accepted ||
                              c.status == ContractStatus.pending ||
                              c.status == ContractStatus.disputed,
                        )
                        .toList();
                    final pastContracts = data
                        .where(
                          (c) =>
                              c.status == ContractStatus.completed ||
                              c.status == ContractStatus.rejected,
                        )
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      children: [
                        if (activeContracts.isNotEmpty)
                          _SectionHeader(
                            title: TranslationHandler.get('active_section'),
                          ),
                        ...activeContracts.map(
                          (c) => ContractCard(contract: c, isar: isar),
                        ),
                        if (activeContracts.isNotEmpty &&
                            pastContracts.isNotEmpty)
                          const SizedBox(height: 24),
                        if (pastContracts.isNotEmpty)
                          _SectionHeader(
                            title: TranslationHandler.get('past_section'),
                          ),
                        ...pastContracts.map(
                          (c) => ContractCard(contract: c, isar: isar),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            alignment: TranslationHandler.isRTL
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
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

  const ContractCard({super.key, required this.contract, required this.isar});

  Future<void> _deleteContract(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationHandler.get('dialog_delete_contract_title')),
        content:
            Text(TranslationHandler.get('dialog_delete_contract_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(TranslationHandler.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child:
                Text(TranslationHandler.get('dialog_delete_contract_confirm')),
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
      case ContractStatus.active:
        return TranslationHandler.get('status_active');
      case ContractStatus.accepted:
        return TranslationHandler.get('status_active');
      case ContractStatus.completed:
        return TranslationHandler.get('status_completed');
      case ContractStatus.disputed:
        return TranslationHandler.get('status_disputed');
      case ContractStatus.pending:
        return TranslationHandler.get('status_pending');
      case ContractStatus.rejected:
        return TranslationHandler.get('status_rejected');
    }
  }

  Color _getStatusColor() {
    switch (contract.status) {
      case ContractStatus.active:
      case ContractStatus.accepted:
        return AppTheme.yackGreen;
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.disputed:
        return Colors.red;
      case ContractStatus.completed:
        return Colors.blue;
      case ContractStatus.rejected:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (contract.status) {
      case ContractStatus.active:
      case ContractStatus.accepted:
        return AppTheme.yackGreenLight;
      case ContractStatus.pending:
        return Colors.orange.withValues(alpha: 0.15);
      case ContractStatus.disputed:
        return Colors.red.withValues(alpha: 0.15);
      case ContractStatus.completed:
        return Colors.blue.withValues(alpha: 0.15);
      case ContractStatus.rejected:
        return AppTheme.yackGrayLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use root navigator to avoid nested navigator issues with persistent_bottom_nav_bar
        Navigator.of(context, rootNavigator: true).pushNamed('/contract/view', arguments: contract.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.yackGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: AppTheme.yackGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contract.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${contract.price} ${TranslationHandler.get('currency')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.yackGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Description
              if (contract.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  contract.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Other user name
              if (contract.userAName != null || contract.userBName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contract.userAName ?? contract.userBName ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
              // Delete button for completed/rejected contracts
              if (contract.status == ContractStatus.completed ||
                  contract.status == ContractStatus.rejected) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _deleteContract(context),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: Text(
                      TranslationHandler.get('delete'),
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

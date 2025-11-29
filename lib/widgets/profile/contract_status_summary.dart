import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/widgets/profile/status_count_tile.dart';

class ContractStatusSummary extends StatelessWidget {
  const ContractStatusSummary({super.key});

  Map<ContractStatus, int> _buildCounts(List<Contract> contracts) {
    final counts = <ContractStatus, int>{
      ContractStatus.accepted: 0,
      ContractStatus.pending: 0,
      ContractStatus.completed: 0,
      ContractStatus.rejected: 0,
    };

    for (final contract in contracts) {
      counts.update(contract.status, (value) => value + 1, ifAbsent: () => 1);
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final isar = Isar.getInstance();
    final theme = Theme.of(context);

    if (isar == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<List<Contract>>(
        stream: isar.contracts.where().watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contracts = snapshot.data ?? [];
          final counts = _buildCounts(contracts);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final tiles = [
                StatusCountTile(
                  label: TranslationHandler.get('status_active'),
                  count: counts[ContractStatus.accepted] ?? 0,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                StatusCountTile(
                  label: TranslationHandler.get('status_pending'),
                  count: counts[ContractStatus.pending] ?? 0,
                  color: Colors.orange,
                  icon: Icons.hourglass_bottom,
                ),
                StatusCountTile(
                  label: TranslationHandler.get('status_completed'),
                  count: counts[ContractStatus.completed] ?? 0,
                  color: Colors.blue,
                  icon: Icons.task_alt,
                ),
                StatusCountTile(
                  label: TranslationHandler.get('status_rejected'),
                  count: counts[ContractStatus.rejected] ?? 0,
                  color: Colors.redAccent,
                  icon: Icons.cancel_outlined,
                ),
              ];

              if (isWide) {
                return Row(
                  children: tiles
                      .map(
                        (tile) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: tile,
                          ),
                        ),
                      )
                      .toList(),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: tiles
                    .map(
                      (tile) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: tile,
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}

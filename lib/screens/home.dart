import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'create_contract.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // Toggle theme (to be implemented and added to all pages)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active Section
                Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.yackGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContractCard(
                  context,
                  title: 'Consulting Agreement',
                  amount: '12000 DA',
                  status: 'Active',
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildContractCard(
                  context,
                  title: 'Freelance Contract',
                  amount: '5000 DA',
                  status: 'Active',
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildContractCard(
                  context,
                  title: 'Service Agreement',
                  amount: '8000 DA',
                  status: 'Active',
                  isActive: true,
                ),
                const SizedBox(height: 24),

                // Past Section
                Text(
                  'PAST',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.yackGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContractCard(
                  context,
                  title: 'Past Contract',
                  amount: '3000 DA',
                  status: 'Completed',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateContractScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.yackGreen,
        icon: const Icon(Icons.add, color: AppTheme.yackWhite),
        label: const Text(
          'Add New Contract',
          style: TextStyle(
            color: AppTheme.yackWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContractCard(
    BuildContext context, {
    required String title,
    required String amount,
    required String status,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.yackDivider, width: 1),
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
          child: const Icon(
            Icons.description,
            color: AppTheme.yackGreen,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(amount, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.yackGreenLight : AppTheme.yackGrayLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isActive ? AppTheme.yackGreen : AppTheme.yackGray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

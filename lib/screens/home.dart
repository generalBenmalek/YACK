import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'create_contract.dart';
import 'package:yack/utils/translation_handler.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationHandler.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(TranslationHandler.get('contracts'),
            style: Theme.of(context).textTheme.titleMedium),
      ),

      body: Stack(children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Section
                  Text(
                    TranslationHandler.get('active_section'),
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
                    title: TranslationHandler.get('consulting_agreement'),
                    amount: '12000 DA',
                    status: TranslationHandler.get('status_active'),
                    isActive: true,
                  ),
                  const SizedBox(height: 12),
                  _buildContractCard(
                    context,
                    title: TranslationHandler.get('freelance_contract'),
                    amount: '5000 DA',
                    status: TranslationHandler.get('status_active'),
                    isActive: true,
                  ),
                  const SizedBox(height: 12),
                  _buildContractCard(
                    context,
                    title: TranslationHandler.get('service_agreement'),
                    amount: '8000 DA',
                    status: TranslationHandler.get('status_active'),
                    isActive: true,
                  ),
                  const SizedBox(height: 24),

                  // Past Section
                  Text(
                    TranslationHandler.get('past_section'),
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
                    title: TranslationHandler.get('past_contract'),
                    amount: '3000 DA',
                    status: TranslationHandler.get('status_completed'),
                    isActive: false,
                  ),
                  const SizedBox(height: 70),

                ],
              ),
            ),
          ],),
        Container(
          margin: EdgeInsetsGeometry.all(10),
          alignment: Alignment.bottomRight,
          child:FloatingActionButton(
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

        )

      ])
    );
      },
    );
  }

  Widget _buildContractCard(
    BuildContext context, {
    required String title,
    required String amount,
    required String status,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        // todo: implement correctly later
        Navigator.of(context, rootNavigator: true).pushNamed('/contract/view');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: AppTheme.yackDivider, width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
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
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ) ;
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/widgets/profile/contract_status_summary.dart';
import 'package:yack/widgets/profile/user_info_header.dart';
import 'package:yack/widgets/settingWidgets/sectionHeader.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          TranslationHandler.get('profile'),
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('user').listenable(keys: ['firstName', 'lastName']),
        builder: (context, box, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: TranslationHandler.get('profile_information'),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const UserInfoHeader(),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: TranslationHandler.get('contracts_summary'),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const ContractStatusSummary(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yack/logic/utils/profile_name_dialog.dart';
import 'package:yack/logic/services/translation_handler.dart';

class UserInfoHeader extends StatelessWidget {
  const UserInfoHeader({super.key});

  String _buildInitial(String? firstName) {
    if (firstName == null || firstName.trim().isEmpty) return '?';
    return firstName.trim().characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable:
            Hive.box('user').listenable(keys: ['firstName', 'lastName']),
        builder: (context, box, _) {
          final firstName = box.get('firstName', defaultValue: '') as String?;
          final lastName = box.get('lastName', defaultValue: '') as String?;

          final name = [firstName, lastName]
              .where((value) => value != null && value.toString().isNotEmpty)
              .join(' ')
              .trim();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Text(
                  _buildInitial(firstName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty
                          ? name
                          : TranslationHandler.get('profile_name_placeholder'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? TranslationHandler.get('email'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: colorScheme.primary,
                      ),
                      onPressed: () => showEditNameDialog(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(TranslationHandler.get('edit_name')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

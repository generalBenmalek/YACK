import 'package:flutter/material.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/widgets/secondaryActionButtonAutoLoading.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/providers/contract/accept_contract_cubit.dart';
import 'package:yack/providers/contract/accept_contract_state.dart';

class AcceptDeclineContractScreen extends StatelessWidget {
  final String title;
  final double price;
  final String? description;
  final String userAFullName;
  final String userBFullName;
  final String tempId; // backend tempID

  const AcceptDeclineContractScreen({
    super.key,
    required this.title,
    required this.price,
    required this.userAFullName,
    required this.userBFullName,
    required this.tempId,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationHandler.get('contract_review'),
          style: theme.textTheme.titleMedium,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: color.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Contract Container
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender info
                    Row(
                      children: [
                        const Icon(Icons.person, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          TranslationHandler.resolve('from_user',
                              params: {'name': '$userAFullName $userBFullName'}),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: color.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 25, thickness: 1),

                    // Centered Contract Title
                    Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 25, thickness: 1),

                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          description ??
                              TranslationHandler.get('accept_decline_description'),
                          textAlign: TextAlign.justify,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.onSurface.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price aligned bottom-right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "${TranslationHandler.get('price_label')}: ${price.toStringAsFixed(2)} ${TranslationHandler.get('currency')}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Warning / status + buttons area follows cubit
            BlocConsumer<AcceptContractCubit, AcceptContractState>(
              listener: (context, state) {
                if (state is AcceptContractCompleted) {
                  SnackBarHandler.showSuccess(
                    context,
                    TranslationHandler.get('contract_accepted'),
                  );
                  Navigator.pop(context, {
                    'status': true,
                    'contract': Contract()
                    ..mongoId = state.finalContractId
                    ..description = description?? ""
                    ..name = title
                    ..price = price
                    ..userA = userAFullName
                    ..userB = userBFullName
                  });

                } else if (state is AcceptContractSigned) {
                  // user signed, waiting for the other
                  SnackBarHandler.showMessage(
                    context,
                    TranslationHandler.get(state.messageKey),
                  );
                } else if (state is AcceptContractError) {
                  SnackBarHandler.showError(
                    context,
                    TranslationHandler.get(state.messageKey),
                  );
                }
              },
              builder: (context, state) {
                final bool isLoading = state is AcceptContractLoading;
                final bool isSignedWaiting = state is AcceptContractSigned;

                return Column(
                  children: [
                    // Warning / waiting message
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (isSignedWaiting
                                ? color.primaryContainer
                                : color.errorContainer)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (isSignedWaiting ? color.primary : color.error)
                              .withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isSignedWaiting
                                ? Icons.hourglass_bottom
                                : Icons.warning_amber_rounded,
                            color:
                                isSignedWaiting ? color.primary : color.error,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isSignedWaiting
                                  ? TranslationHandler.get(
                                      'contract_waiting_other_user')
                                  : TranslationHandler.get('binding_warning'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSignedWaiting
                                    ? color.primary
                                    : color.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accept / Decline buttons
                    PrimaryActionButtonAutoReload(
                      action: TranslationHandler.get('accept_contract'),
                      onClick: isLoading || isSignedWaiting
                          ? () async {}
                          : () async {
                              await context
                                  .read<AcceptContractCubit>()
                                  .acceptContract(tempId);
                            },
                    ),
                    const SizedBox(height: 5),

                    // Decline button disappears after user has signed
                    if (!isSignedWaiting)
                      SecondaryActionButtonAutoReload(
                        action: TranslationHandler.get('decline_contract'),
                        onClick: () {
                          SnackBarHandler.showError(
                            context,
                            TranslationHandler.get('contract_declined'),
                          );
                          Navigator.pop(context, false);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

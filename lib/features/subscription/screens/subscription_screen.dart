import 'package:flutter/material.dart';
import 'package:yack/core/utils/translation_handler.dart';
import 'package:yack/core/theme/theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 1; // default to Pro plan

  final List<_SubscriptionPlan> _plans = [
    _SubscriptionPlan(
      name: 'basic',
      price: '0',
      period: 'free',
      features: [
        'feature_5_contracts',
        'feature_basic_support',
        'feature_local_storage',
      ],
      isPopular: false,
    ),
    _SubscriptionPlan(
      name: 'pro',
      price: '2000',
      period: 'month',
      features: [
        'feature_25_contracts',
        'feature_priority_support',
        'feature_cloud_backup',
        'feature_contract_templates',
      ],
      isPopular: true,
    ),
    _SubscriptionPlan(
      name: 'unlimited',
      price: '10000',
      period: 'month',
      features: [
        'feature_unlimited_contracts',
        'feature_vip_support',
        'feature_cloud_sync',
        'feature_contract_templates',
        'feature_advanced_analytics',
        'feature_team_collaboration',
      ],
      isPopular: false,
    ),
  ];

  void _simulateSubscription() {
    final selectedPlan = _plans[_selectedPlanIndex];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationHandler.get('subscription_success')),
        content: Text(
          '${TranslationHandler.get('subscribed_to')} ${TranslationHandler.get('plan_${selectedPlan.name}')}!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true); // Return success
            },
            child: Text(TranslationHandler.get('done')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          TranslationHandler.get('subscription'),
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.yackGreenLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      size: 48,
                      color: AppTheme.yackGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    TranslationHandler.get('choose_your_plan'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TranslationHandler.get('unlock_premium_features'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Plans
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final isSelected = _selectedPlanIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlanIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryContainer
                            : colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      TranslationHandler.get(
                                          'plan_${plan.name}'),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? colors.onPrimaryContainer
                                            : colors.onSurface,
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? colors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.outline,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color: colors.onPrimary,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${plan.price} ${TranslationHandler.get('currency')}',
                                      style:
                                          theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? colors.onPrimaryContainer
                                            : colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (plan.period != 'free')
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '/${TranslationHandler.get(plan.period)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: isSelected
                                                ? colors.onPrimaryContainer
                                                    .withOpacity(0.7)
                                                : colors.onSurface
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...plan.features.map((feature) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: isSelected
                                                ? colors.primary
                                                : AppTheme.yackGreen,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              TranslationHandler.get(feature),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? colors.onPrimaryContainer
                                                    : colors.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          // Popular badge
                          if (plan.isPopular)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.yackGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  TranslationHandler.get('popular'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Subscribe button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _simulateSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yackGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        TranslationHandler.get('subscribe_now'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    TranslationHandler.get('cancel_anytime'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPlan {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  _SubscriptionPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
  });
}

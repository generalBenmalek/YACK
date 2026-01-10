import 'package:flutter/material.dart';
import 'package:yack/logic/services/notification/contract_notification_handler.dart';

class NotificationRouterService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void initialize() {
    ContractNotificationHandler().events.listen(_handleNotificationNavigation);
  }

  static void _handleNotificationNavigation(ContractNotificationEvent event) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('[NotificationRouter] No context available for navigation');
      return;
    }

    print('[NotificationRouter] Routing notification: ${event.type}');

    switch (event.type) {
      case ContractNotificationType.contractJoin:
      case ContractNotificationType.contractSign:
        if (event.tempId != null) {
          _navigateToRoute(context, '/contract_review', arguments: {'tempId': event.tempId});
        }
      case ContractNotificationType.contractAccept:
      case ContractNotificationType.contractDispute:
      case ContractNotificationType.contractMessage:
      case ContractNotificationType.contractMedia:
        if (event.contractId != null) {
          _navigateToContractAgreement(context, event.contractId!);
        }
    }
  }

  static void _navigateToRoute(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    try {
      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    } catch (_) {}
  }

  static void _navigateToContractAgreement(BuildContext context, String externalContractId) {
    try {
      Navigator.of(context).pushNamed('/contract_agreement', arguments: {'externalContractId': externalContractId});
    } catch (_) {}
  }

  static Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    _handleNotificationNavigation(ContractNotificationEvent.fromFcmData(data));
  }

  static void navigateTo(String routeName, {Map<String, dynamic>? arguments}) {
    final context = navigatorKey.currentContext;
    if (context != null) _navigateToRoute(context, routeName, arguments: arguments);
  }

  static void navigateToContract(String externalContractId) {
    final context = navigatorKey.currentContext;
    if (context != null) _navigateToContractAgreement(context, externalContractId);
  }
}

import 'package:flutter/material.dart';


class NotificationModel {
  final String title;
  final String body;
  final DateTime date;
  final IconData icon;

  NotificationModel({
    required this.title,
    required this.body,
    required this.date,
    this.icon = Icons.notifications,
  });
}
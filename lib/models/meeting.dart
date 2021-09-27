import 'package:flutter/material.dart';

class Meeting {
  String eventName;
  String? orderId;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  Meeting({
    required this.eventName,
    this.orderId,
    required this.from,
    required this.to,
    required this.background,
    this.isAllDay = false,
  });
}

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
    required this.isAllDay,
  });

  @override
  String toString() {
    return 'Meeting{eventName: $eventName, orderId: $orderId, from: $from, to: $to, background: $background, isAllDay: $isAllDay}';
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      eventName: json['eventName'],
      orderId: json['orderId'],
      from: json['from'].toDate(),
      to: json['to'].toDate(),
      background: Color(json['background']),
      isAllDay: json['isAllDay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': this.eventName,
      'orderId': this.orderId,
      'from': this.from,
      'to': this.to,
      'background': this.background.value,
      'isAllDay': this.isAllDay,
    };
  }
}

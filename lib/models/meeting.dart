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

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      eventName: json['eventName'],
      orderId: json['orderId'],
      from: json['from'],
      to: json['to'],
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

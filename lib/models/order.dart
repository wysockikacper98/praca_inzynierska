import 'package:flutter/material.dart';

import 'address.dart';

enum Status {
  PENDING,
  PROCESSING,
  COMPLETED,
}

class Order {
  String firmID;
  String firmName;
  String firmAvatar;
  String userID;
  String userName;
  String userAvatar;
  String title;
  Status status;
  bool isCommentEnable;
  String category;
  String description;

  //TODO: Dodać informacje odnoście dat
  Address address;

  Order({
    @required this.firmID,
    @required this.firmName,
    @required this.firmAvatar,
    @required this.userID,
    @required this.userName,
    @required this.userAvatar,
    @required this.title,
    @required this.status,
    this.isCommentEnable,
    @required this.category,
    this.description,
    @required this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      firmID: json['firmID'] ?? '',
      firmName: json['firmName'] ?? '',
      firmAvatar: json['firmAvatar'] ?? '',
      userID: json['userID'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      isCommentEnable: json['isCommentEnable'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      address: Address.fromJson(json['address']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firmID': this.firmID,
      'firmName': this.firmName,
      'firmAvatar': this.firmAvatar,
      'userID': this.userID,
      'userName': this.userName,
      'userAvatar': this.userAvatar,
      'title': this.title,
      'status': this.status.toString().split('.').last,
      'isCommentEnable': this.isCommentEnable,
      'category': this.category,
      'description': this.description,
      'address': this.address.toJson(),
    };
  }
}

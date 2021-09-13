import 'package:flutter/material.dart';

import 'address.dart';

enum Status {
  PENDING_CONFIRMATION,
  CONFIRMED,
  IN_PROGRESS,
  TERMINATE,
  DONE,
}

class Order {
  String firmID;
  String firmName;
  String userID;
  String userName;
  String title;
  Status status;
  String category;
  String description;
  //TODO: Dodać informacje odnoście dat
  Address address;

  Order({
    @required this.firmID,
    @required this.firmName,
    @required this.userID,
    @required this.userName,
    @required this.title,
    @required this.status,
    @required this.category,
    this.description,
    @required this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json){
    return Order(
      firmID: json['firmID'] ?? '',
      firmName: json['firmName'] ?? '',
      userID: json['userID'] ?? '',
      userName: json['userName'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      address: Address.fromJson(json['address']) ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'firmID': this.firmID,
      'firmName': this.firmName,
      'userID': this.userID,
      'userName': this.userName,
      'title': this.title,
      'status': this.status.toString().split('.').last,
      'category': this.category,
      'description': this.description,
      'address': this.address.toJson(),
    };
  }

}

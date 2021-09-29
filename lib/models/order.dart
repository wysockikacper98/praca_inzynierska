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
  bool? canUserComment;
  bool? canFirmComment;
  String category;
  String? description;
  DateTime? dateFrom;
  DateTime? dateTo;
  Address address;

  Order({
    required this.firmID,
    required this.firmName,
    required this.firmAvatar,
    required this.userID,
    required this.userName,
    required this.userAvatar,
    required this.title,
    required this.status,
    this.canUserComment,
    this.canFirmComment,
    required this.category,
    this.description,
    this.dateFrom,
    this.dateTo,
    required this.address,
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
      status: json['status'],
      canUserComment: json['canUserComment'],
      canFirmComment: json['canFirmComment'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      dateFrom: json['dateFrom'] ?? '',
      dateTo: json['dateTo'] ?? '',
      address: Address.fromJson(json['address']),
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
      'canUserComment': this.canUserComment,
      'canFirmComment': this.canFirmComment,
      'category': this.category,
      'description': this.description,
      'dateFrom': this.dateFrom,
      'dateTo': this.dateTo,
      'address': this.address.toJson(),
    };
  }
}

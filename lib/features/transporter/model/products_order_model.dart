import 'package:pharma_supply/features/transporter/model/transporter_model.dart';

class ProductOrderModel {
  final String orderId;
  final int orderNumber;
  final String clientId;
  final String clientName;
  final String manufacturerId;
  final String manufacturerName;
  final String registrationNumber;
  final List<String> orderContentsList;
  final DateTime orderDate;
  final TransporterModel assignedTransporter;
  final String deliveryStatus;
  final String deliveryStatusId;

  ProductOrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.manufacturerId,
    required this.manufacturerName,
    required this.registrationNumber,
    required this.orderContentsList,
    required this.orderDate,
    required this.assignedTransporter,
    required this.deliveryStatus,
    required this.deliveryStatusId,
  });

  // Factory constructor to create an instance from JSON
  factory ProductOrderModel.fromJson(Map<String, dynamic> json) {
    return ProductOrderModel(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as int,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      manufacturerId: json['manufacturerId'] as String,
      manufacturerName: json['manufacturerName'] as String,
      registrationNumber: json['registrationNumber'] as String,
      orderContentsList: List<String>.from(json['orderContentsList']),
      orderDate: DateTime.parse(json['orderDate']),
      assignedTransporter: TransporterModel.fromJson(json['assignedTransporter']),
      deliveryStatus: json['deliveryStatus'] as String,
      deliveryStatusId: json['deliveryStatusId'] as String,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'clientId': clientId,
      'clientName': clientName,
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerName,
      'registrationNumber': registrationNumber,
      'orderContentsList': orderContentsList,
      'orderDate': orderDate.toIso8601String(),
      'assignedTransporter': assignedTransporter.toJson(),
      'deliveryStatus': deliveryStatus,
      'deliveryStatusId': deliveryStatusId,
    };
  }
}
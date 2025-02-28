import 'dart:convert';

import 'package:crypto/crypto.dart';

class OrderBlock {
  final int index;
  final String previousHash;
  final int nonce;
  final String hash;
  final String timeStamp;
  final String order;
  final String label;
  final String by;
  final String to;

  OrderBlock({
    required this.index,
    required this.previousHash,
    required this.nonce,
    required this.hash,
    required this.timeStamp,
    required this.order,
    required this.label,
    required this.by,
    required this.to,
  });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'previousHash': previousHash,
      'nonce': nonce,
      'hash': hash,
      'timeStamp': timeStamp,
      'order': order,
      'label': label,
      'by': by,
      'to': to,
    };
  }

  factory OrderBlock.fromJson(Map<String, dynamic> json) {
    return OrderBlock(
      index: json['index'],
      previousHash: json['previousHash'],
      nonce: json['nonce'],
      hash: json['hash'],
      timeStamp: json['timeStamp'],
      order: json['order'],
      label: json['label'],
      by: json['by'],
      to: json['to'],
    );
  }

  // Calculate hash using SHA-256
  static String calculateHash(
      int index, String previousHash, int nonce, String data) {
    final String input = '$index$previousHash$nonce$data';
    return sha256.convert(utf8.encode(input)).toString();
  }

  // Mine a block (find a nonce that satisfies difficulty)
  static OrderBlock mineBlock(int index, String previousHash, String order,
      int difficulty, String label, String by, String to) {
    int nonce = 0;
    String hash;
    final String data = order;
    final String timeStamp = DateTime.now().toString();

    do {
      nonce++;
      hash = calculateHash(index, previousHash, nonce, data);
    } while (!hash.startsWith('0' * difficulty));

    return OrderBlock(
      index: index,
      previousHash: previousHash,
      nonce: nonce,
      hash: hash,
      timeStamp: timeStamp,
      order: order,
      label: label,
      by: by,
      to: to,
    );
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';

class Block {
  final int index;
  final String previousHash;
  final int nonce;
  final String hash;
  final String timeStamp;
  final String product;
  // final String label;

  Block(
      {required this.index,
      required this.previousHash,
      required this.nonce,
      required this.hash,
      required this.timeStamp,
      required this.product,
      // required this.label,
      });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'previousHash': previousHash,
      'nonce': nonce,
      'hash': hash,
      'timeStamp': timeStamp,
      'product': product,
      // 'label': label,
    };
  }

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      index: json['index'],
      previousHash: json['previousHash'],
      nonce: json['nonce'],
      hash: json['hash'] ?? '',
      timeStamp: json['timeStamp'],
      product: json['product'],
      // label: json['label'],
    );
  }

  // Calculate hash using SHA-256
  static String calculateHash(
      int index, String previousHash, int nonce, String data) {
    final String input = '$index$previousHash$nonce$data';
    return sha256.convert(utf8.encode(input)).toString();
  }

  // Mine a block (find a nonce that satisfies difficulty)
  static Block mineBlock(int index, String previousHash, String product,
      int difficulty) {
    int nonce = 0;
    String hash;
    final String data = product;
    final String timeStamp = DateTime.now().toString();

    do {
      nonce++;
      hash = calculateHash(index, previousHash, nonce, data);
    } while (!hash.startsWith('0' * difficulty));

    return Block(
      index: index,
      previousHash: previousHash,
      nonce: nonce,
      hash: hash,
      timeStamp: timeStamp,
      product: product,
      // label: label,
    );
  }
}

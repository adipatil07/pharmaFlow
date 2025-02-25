class TransporterModel {
  final String transporterId;
  final String transporterName;
  final String transporterContact;

  TransporterModel({
    required this.transporterId,
    required this.transporterName,
    required this.transporterContact,
  });

  // Factory constructor to create an instance from JSON
  factory TransporterModel.fromJson(Map<String, dynamic> json) {
    return TransporterModel(
      transporterId: json['transporterId'] as String,
      transporterName: json['transporterName'] as String,
      transporterContact: json['transporterContact'] as String,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'transporterId': transporterId,
      'transporterName': transporterName,
      'transporterContact': transporterContact,
    };
  }
}

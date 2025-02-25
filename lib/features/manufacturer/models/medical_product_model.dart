class MedicalProduct {
  final String productName;
  final String batchNumber;
  final String composition;
  final List<String> ingredients;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final String dosageForm;
  final String packagingType;
  final String storageConditions;
  final String directionsForUse;
  final String indications;
  final List<String> contraindications;
  final List<String> precautions;
  final List<String> sideEffects;
  final String manufacturerName;
  final String manufacturerAddress;
  final String regulatoryApprovalNumber;
  String barcode;
  final double netWeight;
  final String color;
  final String shape;
  String serialNumber;
  final String manufacturerId;

  MedicalProduct({
    required this.productName,
    required this.batchNumber,
    required this.composition,
    required this.ingredients,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.dosageForm,
    required this.packagingType,
    required this.storageConditions,
    required this.directionsForUse,
    required this.indications,
    required this.contraindications,
    required this.precautions,
    required this.sideEffects,
    required this.manufacturerName,
    required this.manufacturerAddress,
    required this.regulatoryApprovalNumber,
    required this.barcode,
    required this.netWeight,
    required this.color,
    required this.shape,
    required this.serialNumber,
    required this.manufacturerId,
  });

  // Factory method to create an instance from JSON
  factory MedicalProduct.fromJson(Map<String, dynamic> json) {
    return MedicalProduct(
      productName: json['productName'] as String,
      batchNumber: json['batchNumber'] as String,
      composition: json['composition'] as String,
      ingredients: List<String>.from(json['ingredients']),
      manufacturingDate: DateTime.parse(json['manufacturingDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      dosageForm: json['dosageForm'] as String,
      packagingType: json['packagingType'] as String,
      storageConditions: json['storageConditions'] as String,
      directionsForUse: json['directionsForUse'] as String,
      indications: json['indications'] as String,
      contraindications: List<String>.from(json['contraindications']),
      precautions: List<String>.from(json['precautions']),
      sideEffects: List<String>.from(json['sideEffects']),
      manufacturerName: json['manufacturerName'] as String,
      manufacturerAddress: json['manufacturerAddress'] as String,
      regulatoryApprovalNumber: json['regulatoryApprovalNumber'] as String,
      barcode: json['barcode'] as String,
      netWeight: (json['netWeight'] as num).toDouble(),
      color: json['color'] as String,
      shape: json['shape'] as String,
      serialNumber: json['serialNumber'] as String,
      manufacturerId: json['manufacturerId'] as String,
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'batchNumber': batchNumber,
      'composition': composition,
      'ingredients': ingredients,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'dosageForm': dosageForm,
      'packagingType': packagingType,
      'storageConditions': storageConditions,
      'directionsForUse': directionsForUse,
      'indications': indications,
      'contraindications': contraindications,
      'precautions': precautions,
      'sideEffects': sideEffects,
      'manufacturerName': manufacturerName,
      'manufacturerAddress': manufacturerAddress,
      'regulatoryApprovalNumber': regulatoryApprovalNumber,
      'barcode': barcode,
      'netWeight': netWeight,
      'color': color,
      'shape': shape,
      'serialNumber': serialNumber,
      'manufacturerId': manufacturerId,
    };
  }

  // Method to convert the object to a string for easy display
  @override
  String toString() {
    return '''
    Product Name: $productName
    Batch Number: $batchNumber
    Composition: $composition
    Ingredients: ${ingredients.join(', ')}
    Manufacturing Date: ${manufacturingDate.toLocal()}
    Expiry Date: ${expiryDate.toLocal()}
    Dosage Form: $dosageForm
    Packaging Type: $packagingType
    Storage Conditions: $storageConditions
    Directions for Use: $directionsForUse
    Indications: $indications
    Contraindications: ${contraindications.join(', ')}
    Precautions: ${precautions.join(', ')}
    Side Effects: ${sideEffects.join(', ')}
    Manufacturer Name: $manufacturerName
    Manufacturer Address: $manufacturerAddress
    Regulatory Approval Number: $regulatoryApprovalNumber
    Barcode: $barcode
    Net Weight: $netWeight g
    Color: $color
    Shape: $shape
    Serial Number: $serialNumber
    Manufacturer ID: $manufacturerId
    ''';
  }
}
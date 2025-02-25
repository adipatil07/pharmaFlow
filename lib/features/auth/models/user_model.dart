class UserModel {
  String id;
  String type;
  String name;
  String email;
  String phone;
  String password; // This should ideally be hashed before storage
  bool isActive;

  UserModel({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.isActive,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'isActive': isActive,
    };
  }

  // Create a UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      isActive: map['isActive'],
    );
  }
}
